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
    
    public var connected = false
    
    public var loggingEnabled = false {
        didSet {
            _loggingEnabled = loggingEnabled
        }
    }
    
    private var peripheral: RZBPeripheral?
    
    private var helper: BleHelper?
    
    private var commandQueue = CommandQueue()
    
    private var pendingHandlers = [() -> Void]()
    
    internal override init() {
        super.init()
    }
    
    // MARK: - Public API

    // MARK: - Connection
    public func connect() {
        if connected {
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
            peripheral.cancelConnection()        }
    }
    
    public func afterConnected(handler: @escaping () -> Void) {
        if connected {
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
        }.then { result -> Promise<[Command]> in
            // For each unsynced session, read its session.txt file
            when(fulfilled: try result.responseTable().flatMap { $0["Name"] }.map { self.execute(command: "sd-file-read session.txt \($0) 1", compressionEnabled: true) }.makeIterator(), concurrently: 1)
        }.then { result in
            // When all reads finish, return their output as an array
            completion { return result.map { ($0.command.slice(from: "sd-file-read session.txt sessions/", to: " 1")!, $0.output) } }
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
    
    public func readProfile(completion: @escaping (() throws -> Data) -> Void) {
        execute(command: "sd-file-read profiles/_profiles.list").then { result in
            completion { return result.output }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func write(profile data: Data, completion: @escaping (() throws -> String) -> Void) {
        execute(command: "sd-file-write _profiles.list_test profiles 0 1 250 1", data: data, compressionEnabled: true).then { result in
            completion { return result.responseString() }
        }.catch { error in
            completion { throw error }
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
    
    private func execute(command string: String, data: Data? = nil, compressionEnabled: Bool = false) -> Promise<Command> {
        return Promise<Command> { resolve, reject in
            async {
                guard let peripheral = self.peripheral,
                    let helper = self.helper else {
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
            
            var requiredSubscriptions = [Promise<CBCharacteristic>]()
            requiredSubscriptions.append(helper.subscribe(to: AuroraChars.commandStatus, updateHandler: self.commandStatusHandler))
            requiredSubscriptions.append(helper.subscribe(to: AuroraChars.commandOutputIndicated, updateHandler: self.commandOutputHandler))
            requiredSubscriptions.append(helper.subscribe(to: AuroraChars.eventIndicated, updateHandler: self.eventHandler))
            requiredSubscriptions.append(helper.subscribe(to: AuroraChars.streamDataIndicated, updateHandler: self.streamHandler))
            
            when(fulfilled: requiredSubscriptions).then { _ in
                return self.execute(command: "prof-unload")
            }.then { _ in
                return self.execute(command: "clock-set \(self.clockSetTime())")
            }.then { _ in
                return self.execute(command: "event-output-enable \(EventIds([.batteryMonitor]).rawValue) 16")
            }.then { eventMask -> Void in
                log("AURORA CONNECTED")
                self.connected = true
                NotificationCenter.default.post(name: .auroraDreambandConnected, object: nil)
                self.pendingHandlers.forEach { $0() }
                self.pendingHandlers.removeAll()
            }.catch { error in
                log("Failed to subscribe characteristics with error \(error)")
            }
        }
        else {
             log("AURORA DISCONNECTED")
            connected = false
            NotificationCenter.default.post(name: .auroraDreambandDisconnected, object: nil)
            // The device is disconnected. maintainConnection will attempt a connection event
            // immediately after this. This default maintainConnection behavior may not be
            // desired for your application. A backoff timer or other behavior could be
            // implemented here.
        }
    }
    
    private func clockSetTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd A"
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
            let event: Int8 = data.scanValue(start: 0, length: 1)
            let flags: Int32 = data.scanValue(start: 1, length: 4)
            log("Char event \(event)")
            log("Char flags \(flags)")
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
