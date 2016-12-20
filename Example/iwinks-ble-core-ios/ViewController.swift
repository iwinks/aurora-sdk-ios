//
//  ViewController.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 11/17/2016.
//  Copyright (c) 2016 Rafael Nobre. All rights reserved.
//

import UIKit
import RZBluetooth
import iwinks_ble_core_ios

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    let centralManager = RZBCentralManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        centralManager.scanForPeripherals(withServices: [CBUUID.rzb_UUIDForHeartRateService()], options: nil) { scanInfo, error in
            guard let peripheral = scanInfo?.peripheral else {
                print("ERROR: \(error!)")
                return
            }
            self.centralManager.stopScan()
            peripheral.addHeartRateObserver({ measurement, error in
                guard let heartRate = measurement?.heartRate else { return }
                print("HEART RATE: \(heartRate)")
                }, completion: { error in
                    guard let error = error else { return }
                    print("ERROR: \(error)")
            })
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
    
}

