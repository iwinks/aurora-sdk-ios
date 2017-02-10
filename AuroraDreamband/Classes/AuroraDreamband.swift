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
    
    var peripheral: RZBPeripheral?
    
    var helper: BleHelper?
    
    private var commands = [Command]()
    
    internal override init() {
        super.init()
    }

    public func connect() {
        print("CONNECTING...")
        centralManager.scanForPeripherals(withServices: [AuroraService.uuid], options: nil) { scanInfo, error in
            guard let peripheral = scanInfo?.peripheral else {
                print("ERROR: \(error!)")
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
        print("DISCONNECTED")
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
    
    public func profileList(completion: @escaping (() throws -> Data) -> Void) {
        execute(command: "sd-file-read profiles/_profiles.list").then { result in
            completion { return try result.outputBuffer() }
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
    
    private func execute(command string: String) -> Promise<Command> {
        return Promise<Command> { resolve, reject in
            async {
                guard let peripheral = self.peripheral,
                    let helper = self.helper else {
                    throw AuroraErrors.notConnected
                }
                
                print("Executing command \(string)")
                
                let command = Command()
                
                command.errorHandler = { error in
                    reject(error)
                }
                command.successHandler = { command in
                    resolve(command)
                }
                
//                if let currentCommand = self.commands.last {
//                    
//                }
                
                self.commands.append(command)
                
                //write the status byte, indicating start of command
                try await(helper.write(data: TransferState.idle.rawValue.data, to: AuroraService.events.transferStatus))
                
                //write the actual command string as ascii (max 128bytes)
                try await(helper.write(data: string.data, to: AuroraService.events.transferData))
                
                //write the status byte, indicating end of command
                try await(helper.write(data: TransferState.cmdExecute.rawValue.data, to: AuroraService.events.transferStatus))
                
            }
        }
    }
    
    public func peripheral(_ peripheral: RZBPeripheral, connectionEvent event: RZBPeripheralStateEvent, error: Error?) {
        if event == .connectSuccess {
            // perform any connection set up here that should occur on every connection
            print("AURORA CONNECTED")
            connected = true
            
            let helper = BleHelper(peripheral: peripheral)
            
            self.helper = helper
            self.peripheral = peripheral
            
            helper.subscribe(to: AuroraService.events.streamData, updateHandler: self.transferStreamHandler).then { char in
                print("Subscribed succesfully to streamData")
            }.catch { error in
                print("Failed to subscribe streamData with error \(error)")
            }
            
            helper.subscribe(to: AuroraService.events.transferStatus, updateHandler: self.transferStatusHandler).then { char -> Void in
                print("Subscribed succesfully to transferStatus")
            }.catch { error in
                print("Failed to subscribe transferStatus with error \(error)")
            }
        }
        else {
            print("AURORA DISCONNECTED")
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
            
            guard let command = self.commands.last else {
                throw AuroraErrors.commandNotFound
            }
            
            print("transferStatusHandler state \(state)")
            
            switch (state) {
                
            // End of current command
            case .idle:
                
                var error: Error?
                //non-zero status[1] indicates command error
                if (status[1] != 0) {
                    error = AuroraErrors.commandError(code: status[1], message: try? command.responseString())
                }
                command.finish(error: error)
                
            // Received response line(s)
            case .cmdRespReady:
                //second status byte is number of bytes available to read
                let count = Int(status[1])
                // Append line to current command's response
                try command.append(response: try await(helper.read(from: AuroraService.events.transferData, count: count)))
                
            // Received binary output
            case .cmdOutputReady:
                let count = Int(status[1])
                // Second status byte is number of bytes available to read
                // Append chunk to current command's output
                command.append(output: try await(helper.read(from: AuroraService.events.transferData, count: count)))
                
            // Command waiting for input
            case .cmdInputRequested:
                
                try await(helper.write(data: "ABCDEFGHIJKLMNOPQRSTUVWXWZ123456789abcdefghijklmnopqrstuvwxyz\r\r\r\r".data, to: AuroraService.events.transferData))
                try await(helper.write(data: TransferState.cmdInputReady.rawValue.data, to: AuroraService.events.transferData));
                
            default:
                break
            }
        }
    }
    
    private func transferStreamHandler(_ updateHandler: () throws -> Data) {
        print("transferStreamHandler")
        do {
            let data = try updateHandler()
            print("Char data \(data)")
        }
        catch {
            print("Error! \(error)")
        }
    }

}

private class Command {
    private var response = [String]()
    private var output = Data()
    private var error: Error?
    private var finished = false
    
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
    
    func append(response data: Data) throws {
        if let line = String(data: data, encoding: .utf8) {
            response.append(line)
        }
        else {
            throw AuroraErrors.unparseableCommandResult
        }
        print("Appended response line with \(data.count) bytes. Total lines \(response.count)")
    }
    
    func append(output data: Data) {
        output.append(data)
        print("Appended output chunk with \(data.count) bytes. Total bytes \(output.count)")
    }
    
    func finish(error: Error?) {
        finished = true
        if let error = error {
            errorHandler?(error)
        }
        else {
            successHandler?(self)
        }
    }
}
