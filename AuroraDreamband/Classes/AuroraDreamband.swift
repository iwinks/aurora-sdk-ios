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
            self.centralManager.scanForPeripherals(withServices: [AuroraService.uuid], options: nil) { scanInfo, error in
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
        execute(command: "sd-dir-read sessions *@*").then { result in
            completion { return result.response.count }
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
            execute(command: "sd-dir-read sessions *@*")
        }.then { result in
            // For each unsynced session, read its session.txt file
            when(fulfilled: result.response.map { self.execute(command: "sd-file-read session.txt sessions/\($0)") })
        }.then { result in
            // When all reads finish, return their output as an array
            completion { return result.map { ($0.command.replacingOccurrences(of: "sd-file-read session.txt ", with: ""), $0.output) } }
        }.catch { error in
            // Or thow an error if anything fails along the way
            completion { throw error }
        }
    }
    
    /**
     Erases the session specified from the Aurora
     
     - parameter id:         session id received by the rest API after syncing the session
     - parameter name:       name of the session in the Aurora file system
     - parameter completion: handler with an inner closure that returns the session is erased, or throws in case of errors
     */
    public func eraseSyncedSession(id: String, name: String, completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "sd-dir-del \(name)").then { result in
            completion { }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func osVersion(completion: @escaping (() throws -> Int) -> Void) {
        execute(command: "os-info").then { result -> Void in
            guard let version = result.responseString().components(separatedBy: "\n").first?.replacingOccurrences(of: "Version: ", with: "") else {
                throw AuroraErrors.unparseableCommandResult
            }
            let intVersion = Int(version) ?? (version == "1.4.2" ? 10402 : 10401)
            completion { return intVersion }
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
        execute(command: "sd-file-write profiles/_profiles.list_test 0", data: data).then { result in
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
    
    private func execute(command string: String, data: Data? = nil) -> Promise<Command> {
        return Promise<Command> { resolve, reject in
            async {
                guard let peripheral = self.peripheral,
                    let helper = self.helper else {
                    throw AuroraErrors.notConnected
                }
                
                log("Executing command \(string)")
                
                let command = Command(string, data: data)
                
                command.errorHandler = { error in
                    self.commandQueue.dequeue(command: command)
                    reject(error)
                }
                command.successHandler = { command in
                    self.commandQueue.dequeue(command: command)
                    resolve(command)
                }

                self.commandQueue.enqueue(command: command) {
                    do {
                        //write the status byte, indicating start of command
                        try await(helper.write(data: TransferState.idle.rawValue.data, to: AuroraService.events.transferStatus))
                        
                        //write the actual command string as ascii (max 128bytes)
                        try await(helper.write(data: string.data, to: AuroraService.events.transferData))
                        
                        //write the status byte, indicating end of command
                        try await(helper.write(data: TransferState.cmdExecute.rawValue.data, to: AuroraService.events.transferStatus))
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
            
            let streamDataSubscription = helper.subscribe(to: AuroraService.events.streamData, updateHandler: self.transferStreamHandler)
            let transferStatusSubscription = helper.subscribe(to: AuroraService.events.transferStatus, updateHandler: self.transferStatusHandler)
            
            when(fulfilled: streamDataSubscription, transferStatusSubscription).then { _,_ -> Void in
                log("AURORA CONNECTED")
                self.connected = true
                NotificationCenter.default.post(name: .auroraDreambandConnected, object: nil)
                self.pendingHandlers.forEach { $0() }
                self.pendingHandlers.removeAll()
            }
            .catch { error in
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
    
    private func transferStatusHandler(_ updateHandler: @escaping () throws -> Data) {
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
            guard let state = TransferState(rawValue: status[0]) else {
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
            case .cmdRespReady:
                log(">>>> READ RESPONSE")
                
                // Second status byte is number of bytes available to read
                let count = Int(status[1])
                // Append line to current command's response
                try command.append(response: { () throws -> Data in
                    try await(helper.read(from: AuroraService.events.transferData, count: count))
                })
                
                log("<<<< READ RESPONSE")
                
            // Received binary output
            case .cmdOutputReady:
                log(">>>> READ OUTPUT")
                
                // Second status byte is number of bytes available to read
                let count = Int(status[1])
                // Append chunk to current command's output
                try command.append(output: { () throws -> Data in
                    try await(helper.read(from: AuroraService.events.transferData, count: count))
                })
                
                log("<<<< READ OUTPUT")
                
            // Command waiting for input
            case .cmdInputRequested:
                log(">>>> INPUT REQUEST")
                
                var data = Data()
                if let input = command.data {
                    data.append(input)
                }
                data.append("\r\r\r\r".data)
                try await(helper.write(data: data, to: AuroraService.events.transferData))
                try await(helper.write(data: TransferState.cmdInputReady.rawValue.data, to: AuroraService.events.transferStatus));
                
                log("<<<< INPUT REQUEST")
                
            default:
                break
            }
        }.catch { error in
            log("Error processing transferStatusHandler: \(error.localizedDescription)")
            command.error = error
        }
    }
    
    private func transferStreamHandler(_ updateHandler: () throws -> Data) {
        log("transferStreamHandler")
        do {
            let data = try updateHandler()
            log("Char data \(data)")
        }
        catch {
            log("Error! \(error)")
        }
    }
    
    
}

private class Command: NSObject {
    
    private(set) var data: Data?
    
    private(set) var command: String
    
    var error: Error?
    
    private var pendingOperations = 0 {
        didSet {
            if pendingOperations == 0 && finished {
                log("finished command after last response came in")
                handleFinish()
            }
        }
    }
    private var status: UInt8 = 0
    private var finished = false
    
    init(_ command: String, data: Data? = nil) {
        self.command = command
        self.data = data
    }
    
    override var description: String {
        get {
            return "Command: \(command), completed: \(finished && pendingOperations == 0), response: \(try? responseString())"
        }
    }
    
    var successHandler: ((Command) -> Void)?
    var errorHandler: ((Error) -> Void)?
    var response = [String]()
    var output = Data()
    
    func responseString() -> String {
        return response.joined(separator: "\n")
    }
    
    func append(response handler: () throws -> Data) throws {
        pendingOperations += 1
        
        let data = try handler()
        if let line = String(data: data, encoding: .utf8) {
            response.append(line)
        }
        else {
            throw AuroraErrors.unparseableCommandResult
        }
        log("Appended response line with \(data.count) bytes. Total lines \(response.count)")
        
        pendingOperations -= 1
    }
    
    func append(output handler: () throws -> Data) throws {
        pendingOperations += 1
        
        let data = try handler()
        output.append(data)
        log("Appended output chunk with \(data.count) bytes. Total bytes \(output.count)")
        
        pendingOperations -= 1
    }
    
    func finish(status: UInt8) {
        finished = true
        self.status = status
        
        if pendingOperations == 0 {
            log("finished command")
            handleFinish()
            
        }
        else {
            log("finished command while busy, waiting for last response to come in...")
        }
    }
    
    private func handleFinish() {
        if status != 0 {
            errorHandler?(AuroraErrors.commandError(code: status, message: try? responseString()))
        }
        else if let error = error {
            errorHandler?(error)
        }
        else {
            successHandler?(self)
        }
    }
}

private class CommandQueue {
    
    var current: Command? {
        get {
            return commands.first
        }
    }
    private var commands = [Command]()
    private var handlers = [() -> Void]()

    func enqueue(command: Command, readyHandler: @escaping () -> Void) {
        commands.append(command)
        handlers.append(readyHandler)
        if commands.count == 1 {
            readyHandler()
        }
    }
    
    func dequeue(command: Command) {
        if let index = commands.index(of: command) {
            commands.remove(at: index)
            let _ = handlers.remove(at: index)
        }
        handlers.first?()
    }
}
