//
//  AuroraDreamband.swift
//  Pods
//
//  Created by Rafael Nobre on 25/01/17.
//
//

import UIKit
import RZBluetooth

public class AuroraDreamband: NSObject, RZBPeripheralConnectionDelegate {
    
    public static let shared = AuroraDreamband()
    
    public var centralManager = RZBCentralManager()
    
    public var connected = false
    
    internal override init() {
        super.init()
    }
    

    public func peripheral(_ peripheral: RZBPeripheral, connectionEvent event: RZBPeripheralStateEvent, error: Error?) {
        print("Peripheral \(peripheral), event \(event), error \(error)")
    }

    public func connect() {
        print("CONNECTING...")
        centralManager.scanForPeripherals(withServices: [AuroraService.uuid], options: nil) { scanInfo, error in
            guard let peripheral = scanInfo?.peripheral else {
                print("ERROR: \(error!)")
                return
            }
            self.centralManager.stopScan()
            peripheral.maintainConnection = true
            peripheral.connectionDelegate = self
            print("CONNECTED to Aurora Dreamband.")
            
            peripheral.fetchBatteryLevel({ (level, error) in
                print("BATTERY_LEVEL \(level) error \(error).")
            })
            
            //signal
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.streamData, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                print("UPDATED CHAR STREAM_DATA with data \(char?.value) and error \(error)")
            }, completion: { (char, error) in
                print("OBSERVING STREAM_DATA with error \(error)")
            })
            
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.buttonMonitor, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                guard let data = char?.value
                    else {
                        print("UPDATED CHAR BUTTON_MONITOR with no data and error \(error)")
                        return
                }
                let value: Int32 = data.scanValue(start: 0, length: 1)
                print("UPDATED CHAR BUTTON_MONITOR with rawData \(data as NSData), value \(value) and error \(error)")
            }, completion: { (char, error) in
                print("OBSERVING BUTTON_MONITOR with error \(error)")
            })
            
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.usbMonitor, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                print("UPDATED CHAR USB_MONITOR with data \(char!.value! as NSData) and error \(error)")
            }, completion: { (char, error) in
                print("OBSERVING USB_MONITOR with error \(error)")
            })
            
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.batteryMonitor, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                guard let data = char?.value
                     else {
                    print("UPDATED CHAR BATTERY_MONITOR with no data and error \(error)")
                        return
                }
                let value: Int32 = data.scanValue(start: 0, length: 1)
                print("UPDATED CHAR BATTERY_MONITOR with rawData \(data as NSData), value \(value) and error \(error)")
                
            }, completion: { (char, error) in
                print("OBSERVING BATTERY_MONITOR with error \(error)")
            })

            
            peripheral.enableNotify(forCharacteristicUUID: AuroraService.events.transferStatus, serviceUUID: AuroraService.uuid, onUpdate: { (char, error) in
                print("UPDATED TRANSFER_STATUS with data \(char?.value) and error \(error)")
            }, completion: { (char, error) in
                print("OBSERVING TRANSFER_STATUS with error \(error)")
            })
        }
    }
}
