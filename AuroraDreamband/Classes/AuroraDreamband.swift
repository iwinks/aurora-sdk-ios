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

public class AuroraDreamband: NSObject {
    
    public static let shared = AuroraDreamband()
    
    public var centralManager = RZBCentralManager()
    
    public var connected = false
    
    var peripheral: RZBPeripheral?
    
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
            self.connected = true
            peripheral.maintainConnection = true
            print("CONNECTED to Aurora Dreamband.")
            
            let helper = BleHelper(peripheral: peripheral)
            
            helper.charSubscribe(to: AuroraService.events.streamData) { updateHandler in
                print("updateHandler")
                do {
                    let characteristic = try updateHandler()
                    print("Char update \(characteristic)")
                }
                catch {
                    print("Error! \(error)")
                }
            }.then { char in
                print("Subscribed succesfully to streamData")
            }.catch { error in
                print("Failed to subscribe streamData with error \(error)")
            }
            
            helper.charSubscribe(to: AuroraService.events.transferStatus) { updateHandler in
                print("updateHandler")
                do {
                    let characteristic = try updateHandler()
                    print("Char update \(characteristic)")
                }
                catch {
                    print("Error! \(error)")
                }
            }.then { char -> Void in
                print("Subscribed succesfully to transferStatus")
                self.execute(command: "clock-display")
            }.catch { error in
                print("Failed to subscribe transferStatus with error \(error)")
            }
            
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
    
    func execute(command: String) -> Promise<Void> {
        return async {
            guard let peripheral = self.peripheral else {
                throw AuroraErrors.notConnected
            }
            
            print("Executing command \(command)")

            let helper = BleHelper(peripheral: peripheral)
            
            //write the status byte, indicating start of command
            try await(helper.write(data: TransferState.idle.rawValue.data, to: AuroraService.events.transferStatus))
            
            //write the actual command string as ascii (max 128bytes)
            try await(helper.write(data: command.data, to: AuroraService.events.transferData))
            
            //write the status byte, indicating end of command
            try await(helper.write(data: TransferState.cmdExecute.rawValue.data, to: AuroraService.events.transferStatus))            
        }

    }

}
