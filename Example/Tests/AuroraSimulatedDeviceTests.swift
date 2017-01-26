//
//  SimulatedAuroraDeviceTests.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 07/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import RZBluetooth
import AuroraDreamband

class AuroraSimulatedDeviceTests: RZBSimulatedTestCase {
    
    override class func simulatedDeviceClass() -> AnyClass! {
        return AuroraSimulatedDevice.self
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDiscoverService() {
        var discovered = true
        
        centralManager.scanForPeripherals(withServices: [AuroraService.uuid], options: nil) { (scanInfo, error) in
            if let _ = scanInfo {
                discovered = true
            }
            if let error = error {
                print("Error: \(error)")
            }
        }
        
        waitForQueueFlush()
        expect(discovered)
    }
    
    func testAwakening() {
        var awakened = false
        guard let _ = self.device as? AuroraSimulatedDevice else {
            fail("Invalid Configuration")
            return
        }
        
        peripheral.readCharacteristicUUID(AuroraService.events.awakening, serviceUUID: AuroraService.uuid) { (characteristic, error) in
            if let _ = characteristic?.value {
                awakened = true
            }
        }
        
        waitForQueueFlush()
        expect(awakened)
    }
    
    func testBatteryCanBeRead() {
        var battery = 0
        guard let device = self.device as? AuroraSimulatedDevice else {
            fail("Invalid Configuration")
            return
        }
        
        peripheral.addBatteryLevelObserver({ (level, error) in
            battery = Int(level)
            print("level: \(level), error: \(error)")
        }) { error in
            print("error: \(error)")
        }
        waitForQueueFlush()
        
        device.batteryLevel = 80
        
        waitForQueueFlush()
        expect(battery) == 80
    }

    
}
