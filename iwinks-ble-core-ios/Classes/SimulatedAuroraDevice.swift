//
//  AuroraSimulatedDevice.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 06/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import RZBluetooth

class AuroraSimulatedDevice: RZBSimulatedDevice {
    
//    let service = CBMutableService(type: PacketUUID.service, primary: true)
//    let toDevice = CBMutableCharacteristic(type: PacketUUID.toDevice, properties: [.write], value: nil, permissions: [.writeable])
//    let fromDevice = CBMutableCharacteristic(type: PacketUUID.fromDevice, properties: [.notify], value: nil, permissions: [.readable])
//    
    override init(queue: DispatchQueue?, options: [AnyHashable : Any]) {
        super.init(queue: queue, options: options)
        
        addService(buildAuroraService())
        addBatteryService()
        
        
//        service.characteristics = [toDevice, fromDevice]
//        addService(service)
//        addBatteryService()
//        addWriteCallback(forCharacteristicUUID: PacketUUID.toDevice) { [weak self] request -> CBATTError.Code in
//            if let strongSelf = self, let value = request.value {
//                let pkt = Packet.fromData(data: value as NSData)
//                strongSelf.handlePacket(packet: pkt)
//            }
//            return .success
//        }
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
            var value: Int = 100
            request.value = NSData(bytes: &value, length: MemoryLayout<Int>.size) as Data
            return .success
        }
        
        self.addReadCallback(forCharacteristicUUID: sleepMonitor.uuid) { request -> CBATTError.Code in
            var value: Int = 4
            request.value = NSData(bytes: &value, length: MemoryLayout<Int>.size) as Data
            return .success
        }
        
        return auroraService
    }
    
}
