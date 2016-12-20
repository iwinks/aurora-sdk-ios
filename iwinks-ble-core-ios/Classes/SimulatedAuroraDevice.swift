//
//  AuroraSimulatedDevice.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 06/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import RZBluetooth

public class AuroraSimulatedDevice: RZBSimulatedDevice {

    override init(queue: DispatchQueue?, options: [AnyHashable : Any]) {
        super.init(queue: queue, options: options)
        
        addService(buildGenericAccessService())
        addService(buildDeviceInformationService())
        addBatteryService()
        addService(buildHeartRateService())
        addService(buildCurrentTimeService())
        addService(buildEnvironmentalSensingService())
        addService(buildAuroraService())
        
    }
    
    private func buildAuroraService() -> CBMutableService {
        let auroraService = CBMutableService(type: AuroraService.uuid, primary: true)
        
        let props: CBCharacteristicProperties = [.read, .notify, .indicate]
        
        let signalMonitor = CBMutableCharacteristic(type: AuroraService.events.signalMonitor, properties:props , value: nil, permissions: [.readable])
        
        let sleepMonitor = CBMutableCharacteristic(type: AuroraService.events.sleepMonitor, properties:props , value: nil, permissions: [.readable])
        
        let movement = CBMutableCharacteristic(type: AuroraService.events.movement, properties:props , value: nil, permissions: [.readable])
        
        let stimPresented = CBMutableCharacteristic(type: AuroraService.events.stimPresented, properties:props , value: nil, permissions: [.readable])
        
        let awakening = CBMutableCharacteristic(type: AuroraService.events.awakening, properties:props , value: nil, permissions: [.readable])
        
        let autoShutdown = CBMutableCharacteristic(type: AuroraService.events.autoShutdown, properties:props , value: nil, permissions: [.readable])
        
        let reserved1 = CBMutableCharacteristic(type: AuroraService.events.reserved1, properties:props , value: nil, permissions: [.readable])
        
        let reserved2 = CBMutableCharacteristic(type: AuroraService.events.reserved2, properties:props , value: nil, permissions: [.readable])
        
        let reserved3 = CBMutableCharacteristic(type: AuroraService.events.reserved3, properties:props , value: nil, permissions: [.readable])
        
        let reserved4 = CBMutableCharacteristic(type: AuroraService.events.reserved4, properties:props , value: nil, permissions: [.readable])
        
        let reserved5 = CBMutableCharacteristic(type: AuroraService.events.reserved5, properties:props , value: nil, permissions: [.readable])
        
        let reserved6 = CBMutableCharacteristic(type: AuroraService.events.reserved6, properties:props , value: nil, permissions: [.readable])
        
        let reserved7 = CBMutableCharacteristic(type: AuroraService.events.reserved7, properties:props , value: nil, permissions: [.readable])
        
        let reserved8 = CBMutableCharacteristic(type: AuroraService.events.reserved8, properties:props , value: nil, permissions: [.readable])
        
        let reserved9 = CBMutableCharacteristic(type: AuroraService.events.reserved9, properties:props , value: nil, permissions: [.readable])
        
        let reserved10 = CBMutableCharacteristic(type: AuroraService.events.reserved10, properties:props , value: nil, permissions: [.readable])
        
        auroraService.characteristics = [ signalMonitor, sleepMonitor, movement, stimPresented, awakening, autoShutdown, reserved1, reserved2, reserved3, reserved4, reserved5, reserved6, reserved7, reserved8, reserved9, reserved10 ]
        
        self.addReadCallback(forCharacteristicUUID: signalMonitor.uuid) { request -> CBATTError.Code in
            var value: Int = 1
            request.value = NSData(bytes: &value, length: MemoryLayout<Int>.size) as Data
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: sleepMonitor.uuid) { request -> CBATTError.Code in
            var value: Int32 = 1 // 1 - Awake, 2 - Light, 3 - Deep, 4 - REM
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: movement.uuid) { request -> CBATTError.Code in
            var value: Int32 = 3 // 1 - Low, 2 - Moderate, 3 - Strong
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: stimPresented.uuid) { request -> CBATTError.Code in
            var value: Int32 = 1 // 1 - Stim presented
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: awakening.uuid) { request -> CBATTError.Code in
            var value: Int32 = 1 // 1 - Awakening happened
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: autoShutdown.uuid) { request -> CBATTError.Code in
            var value: Int32 = 1 // 1 - Auto shutdown happened
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved1.uuid) { request -> CBATTError.Code in
            var value: Int32 = 1
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved2.uuid) { request -> CBATTError.Code in
            var value: Int32 = 2
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved3.uuid) { request -> CBATTError.Code in
            var value: Int32 = 3
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved4.uuid) { request -> CBATTError.Code in
            var value: Int32 = 4
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved5.uuid) { request -> CBATTError.Code in
            var value: Int32 = 5
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved6.uuid) { request -> CBATTError.Code in
            var value: Int32 = 6
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved7.uuid) { request -> CBATTError.Code in
            var value: Int32 = 7
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved8.uuid) { request -> CBATTError.Code in
            var value: Int32 = 8
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved9.uuid) { request -> CBATTError.Code in
            var value: Int32 = 9
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: reserved10.uuid) { request -> CBATTError.Code in
            var value: Int32 = 10
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        return auroraService
    }
    
    private func buildGenericAccessService() -> CBMutableService {
        let genericAccessService = CBMutableService(type: CBUUID(string: "1800"), primary: false)
        
        let props: CBCharacteristicProperties = [.read]
        
        let name = "Aurora Dreamband".data(using: String.Encoding.utf8)
        let deviceName = CBMutableCharacteristic(type: CBUUID(string: "2A00"), properties:props , value: name!, permissions: [.readable])
        
        let appearance = CBMutableCharacteristic(type: CBUUID(string: "2A01"), properties:props , value: Data(bytes: [ 0x00, 0x00]), permissions: [.readable])
        
        genericAccessService.characteristics = [ deviceName, appearance ]
        
        return genericAccessService
    }
    
    private func buildDeviceInformationService() -> CBMutableService {
        let deviceInformationService = CBMutableService(type: CBUUID(string: "180A"), primary: false)
        
        let props: CBCharacteristicProperties = [.read]
        
        let manufactor = "iWinks".data(using: String.Encoding.utf8)
        let manufactorName = CBMutableCharacteristic(type: CBUUID(string: "2A29"), properties:props, value: manufactor!, permissions: [.readable])
        
        let model = "Aurora v1r3".data(using: String.Encoding.utf8)
        let modelName = CBMutableCharacteristic(type: CBUUID(string: "2A24"), properties:props, value: model!, permissions: [.readable])
        
        let firmware = "1.0.0".data(using: String.Encoding.utf8)
        let firmwareRevision = CBMutableCharacteristic(type: CBUUID(string: "2A26"), properties:props, value: firmware!, permissions: [.readable])
        
        let softwareRevision = CBMutableCharacteristic(type: CBUUID(string: "2A28"), properties:props, value: nil, permissions: [.readable])
        
        deviceInformationService.characteristics = [ manufactorName, modelName, firmwareRevision, softwareRevision ]
        
        self.addReadCallback(forCharacteristicUUID: softwareRevision.uuid) { request -> CBATTError.Code in
            var value: Int64 = 1
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        return deviceInformationService
    }
    
    private func buildHeartRateService() -> CBMutableService {
        let heartRateService = CBMutableService(type: CBUUID(string: "180D"), primary: false)
        
        let props: CBCharacteristicProperties = [.read, .notify, .indicate]
        
        let heartRateMeasurement = CBMutableCharacteristic(type: CBUUID(string: "2A37"), properties:props , value: nil, permissions: [.readable])
        
        let bodySensorLocation = CBMutableCharacteristic(type: CBUUID(string: "2A38"), properties:props , value: Data(bytes: [0x00]), permissions: [.readable])
        
        self.addReadCallback(forCharacteristicUUID: heartRateMeasurement.uuid) { request -> CBATTError.Code in
            request.value = Data(bytes: [0x01, 0x02])
            return .success
        }
        
        heartRateService.characteristics = [ heartRateMeasurement, bodySensorLocation ]
        
        return heartRateService
    }
    
    private func buildCurrentTimeService() -> CBMutableService {
        let currentTimeService = CBMutableService(type: CBUUID(string: "1805"), primary: false)
        
        let props: CBCharacteristicProperties = [.read, .notify, .indicate]
        
        let currentTime = CBMutableCharacteristic(type: CBUUID(string: "2A2B"), properties:props , value: nil, permissions: [.readable])
        
        self.addReadCallback(forCharacteristicUUID: currentTime.uuid) { request -> CBATTError.Code in
            var value: Int32 = 1 // 1 - Auto shutdown happened
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            request.value = Data(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A])
            return .success
        }
        
        currentTimeService.characteristics = [ currentTime ]
        
        return currentTimeService
    }

    private func buildEnvironmentalSensingService() -> CBMutableService {
        let environmentalSensingService = CBMutableService(type: CBUUID(string: "181A"), primary: false)
        
        let props: CBCharacteristicProperties = [.read, .notify, .indicate]
        
        let temperature = CBMutableCharacteristic(type: CBUUID(string: "2A6E"), properties:props , value: nil, permissions: [.readable])
        
        self.addReadCallback(forCharacteristicUUID: temperature.uuid) { request -> CBATTError.Code in
            var value: Int16 = 23
            request.value = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
            return .success
        }
        
        environmentalSensingService.characteristics = [ temperature ]
        
        return environmentalSensingService
    }
    
}
