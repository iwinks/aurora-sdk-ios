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

class Helpers: NSObject {
    
    /**
     Writes a buffer up to 128 bytes, splitting it in 20 bytes chunks to an Aurora Dreamband device and service.
     
     - parameter data:               the data to write. Must not exceed 128 bytes
     - parameter characteristicUUID: UUID of the characteristic to write
     - parameter peripheral:         discovered peripheral to write in
     
     - returns: a promise that resolves when the data is succesfully written, and rejects otherwise
     */
    func write(data: Data, to characteristicUUID: CBUUID, in peripheral: RZBPeripheral) -> Promise<Void> {
        return async {
            if data.count == 0 {
                return
            }
            
            if data.count > TRANSFER_MAX_PAYLOAD {
                throw NSError(domain: "AuroraDreambandErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey:"Exceeded max write payload."])
            }
            
            
            for i in 0..<(data.count+TRANSFER_MAX_PACKET_LENGTH) {
                let chunk = data.subdata(in: i..<(i+TRANSFER_MAX_PACKET_LENGTH))
                if chunk.count == 0 {
                    break
                }
                
                try? await(self.write(chunk: chunk, to: characteristicUUID, in: peripheral))
            }
        }
    }
    
    /**
     Writes a chunk of data containing a max payload of 20 bytes to the Aurora service at the requested peripheral/uuid
     
     - parameter data:               the data to write. Must not exceed 20 bytes
     - parameter characteristicUUID: UUID of the characteristic to write
     - parameter peripheral:         discovered peripheral to write in
     
     - returns: a promise that resolves when the data is succesfully written, and rejects otherwise
     */
    func write(chunk data: Data, to characteristicUUID: CBUUID, in peripheral: RZBPeripheral) -> Promise<Void> {
        return Promise { resolve, reject in
            if data.count == 0 {
                resolve()
            }
            if data.count > TRANSFER_MAX_PACKET_LENGTH {
                reject(NSError(domain: "AuroraDreambandErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Exceeded max write packet length."]))
            }
            peripheral.write(data, characteristicUUID: characteristicUUID, serviceUUID: AuroraService.uuid) { characteristic, error in
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
    func read(from characteristicUUID: CBUUID, in peripheral: RZBPeripheral, count: Int) -> Promise<Data> {
        return async {
            if count <= 0 {
                throw NSError(domain: "AuroraDreambandErrorDomain", code: 3, userInfo: [NSLocalizedDescriptionKey:"Cannot read less than 1 byte."])
            }
            
            if count > TRANSFER_MAX_PAYLOAD {
                throw NSError(domain: "AuroraDreambandErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey:"Exceeded max read payload."])
            }
            
            var buffer = Data();
            
            var packetCount = Int(ceil(Double(count / TRANSFER_MAX_PACKET_LENGTH)))
            
            //read packets until we've read all required bytes
            while packetCount > 0 {
                
                //read the packet, and add it to packet array
                let packet = try await(self.readPacket(from: characteristicUUID, in: peripheral))
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
     - parameter peripheral:         discovered peripheral to read from
     
     - returns: a promise that resolves when the data is succesfully read, and rejects otherwise
     */
    func readPacket(from characteristicUUID: CBUUID, in peripheral: RZBPeripheral) -> Promise<Data> {
        return Promise { resolve, reject in
            peripheral.readCharacteristicUUID(characteristicUUID, serviceUUID: AuroraService.uuid) { characteristic, error in
                if let error = error  {
                    return reject(error)
                }
                if let data = characteristic?.value  {
                    return resolve(data)
                }
                reject(NSError(domain: "AuroraErrorDomain", code: 4, userInfo: [NSLocalizedDescriptionKey: "Nothing to read and no explicit error thrown."]))
            }
        }
    }

}
