//
//  AuroraDreamband.swift
//  Pods
//
//  Created by Rafael Nobre on 25/01/17.
//
//

import Foundation
import UIKit
import RZBluetooth
import PromiseKit
import AwaitKit

// Definition:
public extension Notification.Name {
    public static let auroraDreambandConnected = Notification.Name("auroraDreambandConnected")
    public static let auroraDreambandDisconnected = Notification.Name("auroraDreambandDisconnected")
}

public class AuroraDreamband: NSObject, RZBPeripheralConnectionDelegate {
    
    public static let shared = AuroraDreamband()
    
    public var centralManager = RZBCentralManager()
    
    public var isConnected = false
    
    public var loggingEnabled = false {
        didSet {
            _loggingEnabled = loggingEnabled
        }
    }
    
    private var peripheral: RZBPeripheral?
    
    private var helper: BleHelper?
    
    private var commandQueue = CommandQueue()
    
    private var pendingHandlers = [() -> Void]()
    
    private var eventObserverHandler: ((_ event: UInt8, _ flags: UInt32) -> Void)?
    
    private var _isConnected = false
    
    internal override init() {
        super.init()
    }
    
    // MARK: - Public API

    // MARK: - Connection
    public func connect() {
        if _isConnected {
            log("ALREADY CONNECTED")
            return
        }
        log("CONNECTING...")
        RZBUserInteraction.setTimeout(300)
        RZBUserInteraction.perform {
            self.centralManager.scanForPeripherals(withServices: [AURORA_SERVICE_UUID], options: nil) { scanInfo, error in
                guard let peripheral = scanInfo?.peripheral else {
                    log("ERROR: \(error!)")
                    return
                }
                self.peripheral = peripheral
                self.centralManager.stopScan()
                peripheral.maintainConnection = true
                peripheral.connectionDelegate = self
            }
        }
    }
    
    public func disconnect() {
        centralManager.stopScan()
        if let peripheral = peripheral {
            peripheral.cancelConnection()
        }
    }
    
    public func afterConnected(handler: @escaping () -> Void) {
        if isConnected {
            handler()
        }
        else {
            pendingHandlers.append(handler)
        }
    }
    
    // MARK: - Commands
    
    /**
     Returns the number of unsynced sessions in the Aurora.
     
     - parameter completion: handler with an inner closure that returns the number of sessions, or throws in case of errors
     */
    public func unsyncedSessionCount(completion: @escaping (() throws -> Int) -> Void) {
        execute(command: "sd-dir-read sessions 0 *@*").then { result in
            completion { return try result.responseTable().count }
        }.catch { error in
            completion { throw error }
        }
    }
    
    /**
     Returns text files with the contents of all unsynced sessions in the Aurora.
     
     - parameter completion: handler with an inner closure that returns an array of session Data, or throws in case of errors
     */
    public func unsyncedSessions(completion: @escaping (() throws -> [(name: String, data: Data)]) -> Void) {
        firstly {
            // List all unsynced sessions
            execute(command: "sd-dir-read sessions 0 *@*")
        }.then { sessionDirs in
            when(fulfilled: try sessionDirs.responseTable().flatMap { $0["Name"] }.map { self.execute(command: "sd-file-info session.txt \($0)") }.makeIterator(), concurrently: 1)
        }.then { sessionSizeCommands -> Promise<[Command]> in
            // Copy the session files < 1MB, and delete the others which might be corrupt
            let promises = sessionSizeCommands.flatMap { sizeCommand -> Promise<Command>? in
                guard let sizeString = (try? sizeCommand.responseObject()["Size"]) ?? nil,
                    let size = Int(sizeString) else { return nil }
                guard let path = (try? sizeCommand.responseObject()["File"]) ?? nil else { return nil }
                
                if size < 1_048_576 {
                    return self.execute(command: "sd-file-read \(path) / 1", compressionEnabled: true)
                }
                else {
                    return self.execute(command: "sd-dir-del \((path as NSString).deletingLastPathComponent)")
                }
            }
            return when(fulfilled: promises.makeIterator(), concurrently: 1)
        }.then { result in
            // When all reads finish, return their output as an array
            completion { return result.flatMap { response in
                    guard let syncedName = response.command.slice(from: "sd-file-read sessions/", to: "/session.txt") else { return nil }
                    return (syncedName, response.output)
                }
            }
        }.catch { error in
            // Or thow an error if anything fails along the way
            completion { throw error }
        }
    }
    
    /**
     Renames the session specified from Aurora
     
     - parameter id:         session id received by the rest API after syncing the session
     - parameter name:       name of the session in the Aurora file system
     - parameter completion: handler with an inner closure that returns the session is renamed, or throws in case of errors
     */
    public func renameSyncedSession(id: String, name: String, completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "sd-rename sessions/\(name) sessions/\(id)").then { result in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    /**
     Removes the session specified from Aurora
     
     - parameter name:       name of the session in the Aurora file system
     - parameter completion: handler with an inner closure that returns, or throws in case of errors
     */
    public func removeEmptySession(name: String, completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "sd-dir-del sessions/\(name)").then { result in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func osVersion(completion: @escaping (() throws -> Int) -> Void) {
        execute(command: "os-info").then { result -> Void in
            guard let version = try result.responseObject()["Version"] else {
                throw AuroraErrors.unparseableCommandResult
            }
            let intVersion = Int(version) ?? (version == "1.4.2" ? 10402 : 10401)
            completion { return intVersion }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func batteryLevel(completion: @escaping (() throws -> Int) -> Void) {
        execute(command: "os-info").then { result -> Void in
            guard let levelString = try result.responseObject()["Battery Level"]?.replacingOccurrences(of: "%", with: "") else {
                throw AuroraErrors.unparseableCommandResult
            }
            guard let level = Int(levelString) else {
                throw AuroraErrors.unparseableCommandResult
            }            
            completion { return level }
        }.catch { error in
                completion { throw error }
        }
    }
    
    public func batteryLevel() -> Promise<Int> {
        return Promise { resolve, reject in
            self.batteryLevel { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    public func isProfileLoaded(completion: @escaping (() throws -> Bool) -> Void) {
        execute(command: "os-info").then { result -> Void in
            guard let profileString = try result.responseObject()["Profile"] else {
                throw AuroraErrors.unparseableCommandResult
            }
            completion { return profileString != "NO" }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func isProfileLoaded() -> Promise<Bool> {
        return Promise { resolve, reject in
            self.isProfileLoaded { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    public func shutdown(completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "os-shutdown").then { result -> Void in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    /**
     Updates the Aurora with the provided firmware file
     
     - parameter data:       the contents of an Aurora's hex firmware file
     - parameter completion: handler with an inner closure that returns when the update is finished, or throws in case of errors
     */
    public func osUpdate(firmware data: Data, completion: @escaping (() throws -> Void) -> Void) {
        firstly {
            return self.execute(command: "sd-file-write aurora.hex_test / 0 1 250 1", data: data, compressionEnabled: true)
        }.then { result in
            return self.execute(command: "os-info")
        }.then { result in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func observeEvents(_ events: EventIds, eventHandler: @escaping ((_ event: UInt8, _ flags: UInt32) -> Void), completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "event-output-enable \(events.rawValue) 16").then { result -> Void in
            self.eventObserverHandler = eventHandler
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func observeEvents(_ events: EventIds, eventHandler: @escaping ((_ event: UInt8, _ flags: UInt32) -> Void)) -> Promise<Void> {
        return Promise { resolve, reject in
            self.observeEvents(events, eventHandler: eventHandler) { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    public func loadProfile(named profile: String = auroraDreambandDefaultProfile, completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "prof-load \(profile)").then { result in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func loadProfile(named profile: String = auroraDreambandDefaultProfile) -> Promise<Void> {
        return Promise { resolve, reject in
            self.loadProfile(named: profile) { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    public func unloadProfile(completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "prof-unload").then { _ in
            return after(seconds: 3)
        }.then { _ in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func unloadProfile() -> Promise<Void> {
        return Promise { resolve, reject in
            self.unloadProfile() { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    public func listProfiles(completion: @escaping (() throws -> [String]) -> Void) {
        execute(command: "sd-dir-read profiles 1 *.prof").then { result in
            completion { return try result.responseTable().flatMap { $0["Name"] } }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func readProfile(named profile: String = auroraDreambandDefaultProfile, completion: @escaping (() throws -> Data) -> Void) {
        execute(command: "sd-file-read \(profile) profiles 1", compressionEnabled: true).then { result in
            completion { return result.output }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func readProfile(named profile: String = auroraDreambandDefaultProfile) -> Promise<Data> {
        return Promise { resolve, reject in
            self.readProfile(named: profile) { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    public func writeProfile(named profile: String = auroraDreambandDefaultProfile, data: Data, completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "sd-file-write \(profile) profiles 0 1 250 1", data: data, compressionEnabled: true).then { result in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func writeProfile(named profile: String = auroraDreambandDefaultProfile, data: Data) -> Promise<Void> {
        return Promise { resolve, reject in
            self.writeProfile(named: profile, data: data) { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    
    /**
     Updates a profile with the given name, apply the given settings and write it back to the Aurora.
     
     - parameter profile:    name of the profile to update
     - parameter settings:   array of settings to apply
     - parameter completion: handler with an inner closure that returns when the update is finished, or throws in case of errors
     */
    public func updateProfile(named profile: String = auroraDreambandDefaultProfile, with settings: [ProfileSetting], completion: @escaping (() throws -> Void) -> Void) {
        firstly {
            self.readProfile(named: profile)
        }.then { data -> Promise<Void> in
            let existingSettings = try self.parseProfileSettings(from: data)
            let existingSet = Set(existingSettings)
            let proposedSet = Set(settings)
            if proposedSet.isSubset(of: existingSet) {
                return self.continuation()
            }
            return self.writeProfile(named: profile, data: try self.applyProfileSettings(settings, to: data))
        }.then {
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    private func continuation() -> Promise<Void> {
        return Promise { resolve, reject in
            resolve()
        }
    }
    
    public func updateProfile(named profile: String = auroraDreambandDefaultProfile, with settings: [ProfileSetting]) -> Promise<Void> {
        return Promise { resolve, reject in
            self.updateProfile(named: profile, with: settings) { response in
                do { resolve(try response()) } catch { reject(error) }
            }
        }
    }
    
    public func help(completion: @escaping (() throws -> String) -> Void) {
        execute(command: "help").then { result in
            completion { return result.responseString() }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func buzz(note: Int, duration: Int, completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "buzz-note \(note) \(duration)").then {_ in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func parseProfileSettings(from profile: Data) throws -> [ProfileSetting] {
        guard var profileString = String(data: profile) else { throw AuroraErrors.unknownReadError }
        
        let settingsGroups = try profileString.matchingStrings(regex: "\\{(\\S+)\\s*:\\s*(.*)\\}")
        
        var settings = [ProfileSetting]()
        
        for group in settingsGroups {
            if group.count > 2 {
                settings.append(ProfileSetting(key: group[1], value: group[2]))                
            }
        }
        
        return settings
    }
    
    public func applyProfileSettings(_ settings: [ProfileSetting], to profile: Data) throws -> Data {
        guard var profileString = String(data: profile) else { throw AuroraErrors.unknownReadError }
        
        let settingsGroups = try profileString.matchingStrings(regex: "\\{(\\S+):(.*)\\}")
        
        for group in settingsGroups {
            if group.count > 2 {
                let match = settings.filter { $0.key == group[1] }.first
                if let match = match {
                    profileString = profileString.replacingOccurrences(of: group[0], with: match.config)
                }
            }
        }
        
        return profileString.data
    }
    
    private func execute(command string: String, data: Data? = nil, compressionEnabled: Bool = false) -> Promise<Command> {
        return Promise<Command> { resolve, reject in
            async {
                guard let peripheral = self.peripheral,
                    let helper = self.helper,
                    self._isConnected else {
                    reject(AuroraErrors.notConnected)
                    throw AuroraErrors.notConnected
                }
                
                log("Executing command \(string)")
                
                let command = Command(string, data: data, compressionEnabled: compressionEnabled)
                
                command.errorHandler = { error in
                    defer {
                        self.commandQueue.dequeue(command: command)
                    }
                    reject(error)
                }
                command.successHandler = { command in
                    defer {
                        self.commandQueue.dequeue(command: command)
                    }
                    
                    do {
                        try command.integrityCheck()
                    }
                    catch {
                        reject(error)
                    }
                    
                    resolve(command)
                }

                self.commandQueue.enqueue(command: command) {
                    do {
                        //write the status byte, indicating start of command
                        try await(helper.write(data: CommandState.idle.rawValue.data, to: AuroraChars.commandStatus))
                        
                        //write the actual command string as ascii (max 128bytes)
                        try await(helper.write(data: string.data, to: AuroraChars.commandData))
                        
                        //write the status byte, indicating end of command
                        try await(helper.write(data: CommandState.execute.rawValue.data, to: AuroraChars.commandStatus))
                    }
                    catch {
                        reject(error)
                    }
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: RZBPeripheral, connectionEvent event: RZBPeripheralStateEvent, error: Error?) {
        if event == .connectSuccess {
            // perform any connection set up here that should occur on every connection
            let helper = BleHelper(peripheral: peripheral)
            
            self.helper = helper
            self.peripheral = peripheral
            self._isConnected = true
            
            var requiredSubscriptions = [Promise<CBCharacteristic>]()
            requiredSubscriptions.append(helper.subscribe(to: AuroraChars.commandStatus, updateHandler: self.commandStatusHandler))
            requiredSubscriptions.append(helper.subscribe(to: AuroraChars.commandOutputIndicated, updateHandler: self.commandOutputHandler))
            requiredSubscriptions.append(helper.subscribe(to: AuroraChars.eventNotified, updateHandler: self.eventHandler))
            
            when(fulfilled: requiredSubscriptions).then { _ in
                return self.execute(command: "clock-set \(self.clockSetTime())")
            }.then { eventMask -> Void in
                log("AURORA CONNECTED")
                self.isConnected = true
                NotificationCenter.default.post(name: .auroraDreambandConnected, object: nil)
                self.pendingHandlers.forEach { $0() }
                self.pendingHandlers.removeAll()
            }.catch { error in
                log("Failed to subscribe characteristics with error \(error)")
            }
        }
        else {
             log("AURORA DISCONNECTED")
            commandQueue.reset()
            // Only broadcast a disconnection if we were connected in the first place
            if isConnected {
                NotificationCenter.default.post(name: .auroraDreambandDisconnected, object: nil)
            }
            _isConnected = false
            isConnected = false
            // The device is disconnected. maintainConnection will attempt a connection event
            // immediately after this. This default maintainConnection behavior may not be
            // desired for your application. A backoff timer or other behavior could be
            // implemented here.
        }
    }
    
    private func clockSetTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy M d A"
        return formatter.string(from: Date())
    }
    
    private func commandStatusHandler(_ updateHandler: @escaping () throws -> Data) {
        guard let command = self.commandQueue.current else {
            log("Command not found, aborting transferStatusHandler")
            return
        }
        
        async {
            let status = try updateHandler()
            
            guard let peripheral = self.peripheral,
                let helper = self.helper else {
                throw AuroraErrors.notConnected
            }
            guard let state = CommandState(rawValue: status[0]) else {
                throw AuroraErrors.unknownStateError
            }
            
            log("transferStatusHandler state \(state)")
            
            switch (state) {
                
            // End of current command
            case .idle:
                log(">>>> IDLE")
                                
                command.finish(status: status[1])
                
                log("<<<< IDLE")
                
            // Received response line(s)
            case .responseTableReady, .responseObjectReady:
                log(">>>> READ RESPONSE")
                
                // Second status byte is number of bytes available to read
                let count = Int(status[1])
                // Append line to current command's response
                try command.append(response: { () throws -> Data in
                    try await(helper.read(from: AuroraChars.commandData, count: count))
                })
                
                log("<<<< READ RESPONSE")
                
            // Command waiting for input
            case .inputRequested:
                log(">>>> INPUT REQUEST")
                
                if let data = command.data {
                    log("Writing data with \(data.count) bytes")
                    command.data = nil
                    let start = Date()
                    try await(helper.write(data: data, to: AuroraChars.commandData, acknowledged: true))
                    let elapsed = start.timeIntervalSinceNow * -1
                    print("\(elapsed * 1000)ms elapsed to write \(data.count) bytes. Throughput: \(Double(data.count)/elapsed)bytes/s")
                    log("Finished writing data")
                }
                else {
                    log("No data to write.")
                }
                
                log("<<<< INPUT REQUEST")
                
            default:
                break
            }
        }.catch { error in
            log("Error processing transferStatusHandler: \(error.localizedDescription)")
            command.error = error
        }
    }
    
    private func commandOutputHandler(_ updateHandler: @escaping () throws -> Data) {
        log("commandOutputHandler")
        guard let command = self.commandQueue.current else {
            log("Command not found, aborting commandOutputHandler")
            return
        }
        
        async {
            // Append chunk to current command's output
            try command.append(output: updateHandler)
            
            log("<<<< READ OUTPUT")
        }.catch { error in
            log("Error processing commandOutputHandler: \(error.localizedDescription)")
            command.error = error
        }
    }
    
    private func eventHandler(_ updateHandler: @escaping () throws -> Data) {
        log("eventHandler")
        do {
            let data = try updateHandler()
            let event: UInt8 = data.scanValue(start: 0, length: 1)
            let flags: UInt32 = data.scanValue(start: 1, length: 4)
            self.eventObserverHandler?(event, flags)
        }
        catch {
            log("Error! \(error)")
        }
    }
    
    private func streamHandler(_ updateHandler: () throws -> Data) {
        log("streamHandler")
        do {
            let data = try updateHandler()
            log("Char data \(data)")
        }
        catch {
            log("Error! \(error)")
        }
    }
    
}
