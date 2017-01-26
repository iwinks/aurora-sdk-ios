//
//  AuroraDreamband.swift
//  Pods
//
//  Created by Rafael Nobre on 25/01/17.
//
//

import UIKit
import RZBluetooth

public class AuroraDreamband: NSObject {
    
    public static let shared = AuroraDreamband()
    
    public var centralManager = RZBCentralManager()
    
    public var connected = false
    
    internal override init() {
        super.init()
    }

    public func connect() {
        centralManager.scanForPeripherals(withServices: [AuroraService.uuid], options: nil) { scanInfo, error in
            guard let peripheral = scanInfo?.peripheral else {
                print("ERROR: \(error!)")
                return
            }
            self.centralManager.stopScan()
            
            //signal
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.streamData, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                print("UPDATED CHAR STREAM_DATA with data \(char?.value) and error \(error)")
            }, completion: { (char, error) in
                print("OBSERVING STREAM_DATA with error \(error)")
            })
            
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.buttonMonitor, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                print("UPDATED CHAR BUTTON_MONITOR with data \(char!.value! as NSData) and error \(error)")
            }, completion: { (char, error) in
                print("OBSERVING BUTTON_MONITOR with error \(error)")
            })

            
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.transferStatus, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                print("UPDATED TRANSFER_STATUS with data \(char?.value) and error \(error)")
            }, completion: { (char, error) in
                print("OBSERVING TRANSFER_STATUS with error \(error)")
            })
        }
    }
}
