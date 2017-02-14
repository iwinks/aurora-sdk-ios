//
//  AuroraDreamband.swift
//  Pods
//
//  Created by Rafael Nobre on 25/01/17.
//
//

import UIKit
import RZBluetooth
import PromiseKit
import AwaitKit

public class AuroraDreamband: NSObject, RZBPeripheralConnectionDelegate {
    
    public static let shared = AuroraDreamband()
    
    public var centralManager = RZBCentralManager()
    
    public var connected = false
    
    public var loggingEnabled = false {
        didSet {
            _loggingEnabled = loggingEnabled
        }
    }
    
    var peripheral: RZBPeripheral?
    
    var helper: BleHelper?
    
    private var commandQueue = CommandQueue()
    
    internal override init() {
        super.init()
    }

    public func connect() {
        log("CONNECTING...")
        centralManager.scanForPeripherals(withServices: [AuroraService.uuid], options: nil) { scanInfo, error in
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
    
    public func disconnect() {
        centralManager.stopScan()
        if let peripheral = peripheral {
            centralManager.coreCentralManager.cancelPeripheralConnection(peripheral.corePeripheral)
        }
        connected = false
        log("DISCONNECTED")
    }
    
    public func clockDisplay(completion: @escaping (() throws -> String) -> Void) {
        execute(command: "clock-display").then { result in
            completion { return try result.responseString() }
        }.catch { error in
            completion { throw error }
        }

    }
    
    public func sessionFolders(completion: @escaping (() throws -> String) -> Void) {
        execute(command: "sd-dir-read sessions *@*").then { result in
            completion { return try result.responseString() }
        }.catch { error in
            completion { throw error }
        }

    }
    
    public func readProfile(completion: @escaping (() throws -> Data) -> Void) {
        execute(command: "sd-file-read profiles/_profiles.list").then { result in
            completion { return try result.outputBuffer() }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func write(profile data: Data, completion: @escaping (() throws -> String) -> Void) {
        execute(command: "sd-file-write profiles/_profiles.list_test 0", data: data).then { result in
            completion { return try result.responseString() }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func help(completion: @escaping (() throws -> String) -> Void) {
        execute(command: "help").then { result in
            completion { return try result.responseString() }
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
                
                let command = Command(data: data)
                
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
            log("AURORA CONNECTED")
            connected = true
            
            let helper = BleHelper(peripheral: peripheral)
            
            self.helper = helper
            self.peripheral = peripheral
            
            helper.subscribe(to: AuroraService.events.streamData, updateHandler: self.transferStreamHandler).then { char in
                log("Subscribed succesfully to streamData")
            }.catch { error in
                log("Failed to subscribe streamData with error \(error)")
            }
            
            helper.subscribe(to: AuroraService.events.transferStatus, updateHandler: self.transferStatusHandler).then { char -> Void in
                log("Subscribed succesfully to transferStatus")
            }.catch { error in
                log("Failed to subscribe transferStatus with error \(error)")
            }
        }
        else {
            log("AURORA DISCONNECTED")
            connected = false
            // The device is disconnected. maintainConnection will attempt a connection event
            // immediately after this. This default maintainConnection behavior may not be
            // desired for your application. A backoff timer or other behavior could be
            // implemented here.
        }
    }
    
    private func transferStatusHandler(_ updateHandler: @escaping () throws -> Data) {
        return async {
            let status = try updateHandler()
            
            guard let peripheral = self.peripheral,
                let helper = self.helper else {
                throw AuroraErrors.notConnected
            }
            guard let state = TransferState(rawValue: status[0]) else {
                throw AuroraErrors.unknownStateError
            }
            
            guard let command = self.commandQueue.current else {
                throw AuroraErrors.commandNotFound
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
    
    private var pendingOperations = 0 {
        didSet {
            if pendingOperations == 0 && finished {
                log("finished command after last response came in")
                handleFinish()
            }
        }
    }
    private var response = [String]()
    private var output = Data()
    private var status: UInt8 = 0
    private var finished = false
    
    init(data: Data? = nil) {
        self.data = data
    }
    
    var successHandler: ((Command) -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func responseString() throws -> String {
        if !finished {
            throw AuroraErrors.commandNotFinished
        }
        return response.joined(separator: "\n")
    }
    
    func outputBuffer() throws -> Data {
        if !finished {
            throw AuroraErrors.commandNotFinished
        }
        return output
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
