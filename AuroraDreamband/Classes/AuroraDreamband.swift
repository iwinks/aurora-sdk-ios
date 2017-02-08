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
            completion { return result }
        }.catch { error in
            completion { throw error }
        }

    }
    
    public func sessionFolders(completion: @escaping (() throws -> String) -> Void) {
        execute(command: "sd-dir-read sessions *@*").then { result in
            completion { return result }
        }.catch { error in
            completion { throw error }
        }

    }
    
    public func profileList(completion: @escaping (() throws -> String) -> Void) {
        execute(command: "sd-file-read profiles/_profiles.list").then { result in
            completion { return result }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func help(completion: @escaping (() throws -> String) -> Void) {
        execute(command: "help").then { result in
            completion { return result }
        }.catch { error in
            completion { throw error }
        }
    }
    
    public func buzz(note: Int, duration: Int, completion: @escaping (() throws -> Void) -> Void) {
        execute(command: "buzz-note \(note) \(duration)").then { void in
            completion { return void }
        }.catch { error in
            completion { throw error }
        }
    }
    
    internal func execute<T>(command: String) -> Promise<T> {
        return async {
            guard let peripheral = self.peripheral,
                let helper = self.helper else {
                throw AuroraErrors.notConnected
            }
            
            print("Executing command \(command)")
            
            //write the status byte, indicating start of command
            try await(helper.write(data: TransferState.idle.rawValue.data, to: AuroraService.events.transferStatus))
            
            //write the actual command string as ascii (max 128bytes)
            try await(helper.write(data: command.data, to: AuroraService.events.transferData))
            
            //write the status byte, indicating end of command
            try await(helper.write(data: TransferState.cmdExecute.rawValue.data, to: AuroraService.events.transferStatus))
            
            return try await(Promise<T> { resolve, reject in
                reject(AuroraErrors.unknownReadError)
            })
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
            
            helper.charSubscribe(to: AuroraService.events.streamData, updateHandler: self.transferStreamHandler).then { char in
                print("Subscribed succesfully to streamData")
            }.catch { error in
                print("Failed to subscribe streamData with error \(error)")
            }
            
            helper.charSubscribe(to: AuroraService.events.transferStatus, updateHandler: self.transferStatusHandler).then { char -> Void in
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
    
    var cmdOutputBuffers = Data()
    var cmdResponseLines = [String]()
    
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
            
            print("transferStatusHandler state \(state)")
            
            switch (state) {
                
            //is this the end of a command? i.e now idle
            case TransferState.idle:
                
                //non-zero status[1] indicates command error
                if (status[1] != 0) {
                    print("CMD ERROR: ", status[1])
                }
                
                if (self.cmdOutputBuffers.count > 0) {
                    
                    print("CMD OUTPUT:")
                    print(String(data: self.cmdOutputBuffers))
                    self.cmdOutputBuffers = Data()
                }
                
                if (self.cmdResponseLines.count > 0) {
                    
                    print("CMD RESPONSE:")
                    print(self.cmdResponseLines.joined(separator: "\n"))
                    self.cmdResponseLines = [];
                }
                
            //do we have a response to receive
            case TransferState.cmdRespReady:
                
                let count = Int(status[1])
                print("\(self.cmdResponseLines.count) lines + \(count) bytes")
                
                //second status byte is number of bytes available to read
                let responseLineBuffer = try await(helper.read(from: AuroraService.events.transferData, count: count))
                
                if let lineString = String(data: responseLineBuffer, encoding: .utf8) {
                    self.cmdResponseLines.append(lineString)
                }
                else {
                    print("Failed to convert \(responseLineBuffer) into a String")
                }
                
            //output to receive?
            case TransferState.cmdOutputReady:
                
                let count = Int(status[1])
                print("\(self.cmdOutputBuffers.count) + \(count) bytes")
                
                //second status byte is number of bytes available to read
                let outputBuffer = try await(helper.read(from: AuroraService.events.transferData, count: count))
                self.cmdOutputBuffers.append(outputBuffer)
                
            //command waiting for input
            case TransferState.cmdInputRequested:
                
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
