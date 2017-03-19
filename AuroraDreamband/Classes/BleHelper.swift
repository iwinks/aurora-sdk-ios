//
//  Helpers.swift
//  Pods
//
//  Created by Rafael Nobre on 28/01/17.
//
//

import RZBluetooth
import PromiseKit
import AwaitKit

class BleHelper: NSObject {
    
    let peripheral: RZBPeripheral
    let service: CBUUID
    
    init(peripheral: RZBPeripheral, service: CBUUID? = nil) {
        self.peripheral = peripheral
        if let service = service {
            self.service = service
        }
        else {
            self.service = AURORA_SERVICE_UUID
        }
    }
    
    /**
     Writes a buffer up to 128 bytes, splitting it in 20 bytes chunks to an Aurora Dreamband device and service.
     
     - parameter data:               the data to write. Must not exceed 128 bytes
     - parameter characteristicUUID: UUID of the characteristic to write
     
     - returns: a promise that resolves when the data is succesfully written, and rejects otherwise
     */
    func write(data: Data, to characteristicUUID: CBUUID) -> Promise<Void> {
        return async {
            if data.count == 0 {
                return
            }
            
            let chunkCount = data.count / TRANSFER_MAX_PACKET_LENGTH
            
            for i in 0...chunkCount {
                let chunkStart = i * TRANSFER_MAX_PACKET_LENGTH
                var chunkEnd = chunkStart + TRANSFER_MAX_PACKET_LENGTH
                
                if chunkEnd > data.count {
                    chunkEnd = data.count
                }
                
                let chunk = data.subdata(in: chunkStart..<chunkEnd)
                
                if chunk.count == 0 {
                    break
                }
                
                log("Sending chunk \(i+1) of \(chunkCount+1) with \(chunk.count) bytes")
                try await(self.write(chunk: chunk, to: characteristicUUID))
            }
        }
    }
    
    /**
     Writes a chunk of data containing a max payload of 20 bytes to the Aurora service at the requested peripheral/uuid
     
     - parameter data:               the data to write. Must not exceed 20 bytes
     - parameter characteristicUUID: UUID of the characteristic to write
     
     - returns: a promise that resolves when the data is succesfully written, and rejects otherwise
     */
    func write(chunk data: Data, to characteristicUUID: CBUUID) -> Promise<Void> {
        return Promise { resolve, reject in
            if data.count == 0 {
                resolve()
            }
            if data.count > TRANSFER_MAX_PACKET_LENGTH {
                throw AuroraErrors.maxPayloadExceeded(size: data.count)
            }
            peripheral.write(data, characteristicUUID: characteristicUUID, serviceUUID: service) { characteristic, error in
                if let error = error  {
                    return reject(error)
                }
                resolve()
            }
        }
    }
    
    /**
     Reads a buffer up to 128 bytes, splitting it in 20 bytes chunks to an Aurora Dreamband device and service.
     
     - parameter characteristicUUID: UUID of the characteristic to read
     - parameter peripheral:         discovered peripheral to read from
     
     - returns: a promise that resolves when the data is succesfully read, and rejects otherwise
     */
    func read(from characteristicUUID: CBUUID, count: Int) -> Promise<Data> {
        return async {
            if count <= 0 {
                throw AuroraErrors.readNothingAttempt
            }
            
            if count > TRANSFER_MAX_PAYLOAD {
                throw AuroraErrors.maxPayloadExceeded(size: count)
            }
            
            var buffer = Data();
            
            var packetCount = Int(ceil(Float(count) / Float(TRANSFER_MAX_PACKET_LENGTH)))
            
            //read packets until we've read all required bytes
            while packetCount > 0 {
                
                //read the packet, and add it to packet array
                let packet = try await(self.read(from: characteristicUUID))
                buffer.append(packet)
                
                packetCount -= 1
            }
            
            //waits till the last promise is resolved
            //then return the concatenated buffer
            return buffer
        }
    }
    
    /**
     Reads a chunk of data containing a max payload of 20 bytes from the Aurora service at the requested peripheral/uuid
     
     - parameter characteristicUUID: UUID of the characteristic to read
     
     - returns: a promise that resolves when the data is succesfully read, and rejects otherwise
     */
    private func read(from characteristicUUID: CBUUID) -> Promise<Data> {
        return Promise { resolve, reject in
            peripheral.readCharacteristicUUID(characteristicUUID, serviceUUID: service) { characteristic, error in
                if let error = error  {
                    return reject(error)
                }
                if let data = characteristic?.value  {
                    return resolve(data)
                }
                reject(AuroraErrors.unknownReadError)
            }
        }
    }
    
    /**
     Subscribes to a characteristic and returns a Promise that resolves when the subscription resolves, or rejects when unable to bind to it. If the characteristic already has a value prior to subscription, it can be obtained in the Promise resolution itself. Following characteristic changes will be sent to the `onUpdate` callback
     
     - parameter characteristicUUID: UUID of the characteristic to read
     */
    func subscribe(to characteristicUUID: CBUUID, updateHandler: @escaping (@escaping () throws -> Data) -> Void) -> Promise<CBCharacteristic> {
        return Promise { resolve, reject in
            peripheral.enableNotify(forCharacteristicUUID: characteristicUUID, serviceUUID: service, onUpdate: { char, error in
                if let data = char?.value {
                    return updateHandler { return data }
                }
                if let error = error {
                    return updateHandler { throw error }
                }
                return updateHandler { throw AuroraErrors.unknownReadError }
            }, completion: { char, error in
                if let error = error  {
                    return reject(error)
                }
                if let char = char  {
                    return resolve(char)
                }
                reject(AuroraErrors.unknownSubscribeError)
            })
        }
    }

}
