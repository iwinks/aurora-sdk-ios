import XCTest
import Nimble
import RZBluetooth
@testable import iwinks_ble_core_ios

class BLETests: RZBSimulatedTestCase {
    
    override class func simulatedDeviceClass() -> AnyClass! {
        return SimulatedPacketDevice.self
    }
    
    override func configureCentralManager() {
        self.centralManager = RZBCentralManager(identifier: "com.test", peripheralClass: PacketPeripheral.self, queue: nil)
    }
    
    func testPing() {
        var packets = Array<Packet>()
        // Need to figure out how to get RZBSimulatedTestCase to create better properties...
        guard let device = self.device as? SimulatedPacketDevice,
            let peripheral = self.peripheral as? PacketPeripheral else {
                fatalError("Invalid Configuration")
        }
        peripheral.setPacketObserver() { packet in
            packets.append(packet)
        }
        waitForQueueFlush()
        
        peripheral.writePacket(packet: .Ping)
        waitForQueueFlush()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(device.packetHistory.count, 1)
    }
    
    func testBasicMatcher() {
        expect(1) == 1
    }
    
    func testBasicFailure() {
        expect(2) != 1
    }
    
    func testBatteryCanBeRead() {
        var battery = 0
        guard let device = self.device as? SimulatedPacketDevice,
            let peripheral = self.peripheral as? PacketPeripheral else {
                fatalError("Invalid Configuration")
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

class SimulatedPacketDevice: RZBSimulatedDevice {
    var packetHistory = Array<Packet>()
    var autoResponse = true
    
    let service = CBMutableService(type: PacketUUID.service, primary: true)
    let toDevice = CBMutableCharacteristic(type: PacketUUID.toDevice, properties: [.write], value: nil, permissions: [.writeable])
    let fromDevice = CBMutableCharacteristic(type: PacketUUID.fromDevice, properties: [.notify], value: nil, permissions: [.readable])
    
    override init(queue: DispatchQueue?, options: [AnyHashable : Any]) {
        super.init(queue: queue, options: options)
        
        service.characteristics = [toDevice, fromDevice]
        addService(service)
        addBatteryService()
        addWriteCallback(forCharacteristicUUID: PacketUUID.toDevice) { [weak self] request -> CBATTError.Code in
            if let strongSelf = self, let value = request.value {
                let pkt = Packet.fromData(data: value as NSData)
                strongSelf.handlePacket(packet: pkt)
            }
            return .success
        }
    }
    
    func handlePacket(packet: Packet) {
        packetHistory.append(packet)
        guard autoResponse == true else {
            return
        }
        
        switch packet {
        case .Ping:
            writePacket(packet: packet)
        case let .Divide(value, by):
            if by > 0 {
                writePacket(packet: .DivideResponse(value: value / by))
            }
            else {
                writePacket(packet: .Invalid)
            }
        default:
            print("Ignoring \(packet)")
        }
    }
    
    func writePacket(packet: Packet) {
        peripheralManager.updateValue(packet.data as Data, for: fromDevice, onSubscribedCentrals: nil)
    }
}

enum Packet {
    case Ping
    case Divide(value: Int8, by: Int8)
    case DivideResponse(value: Int8)
    case Invalid
}

extension Packet {
    
    var commandValue: UInt8 {
        switch self {
        case .Ping:
            return 0
        case .Divide(_, _):
            return 1
        case .DivideResponse(_):
            return 2
        case .Invalid:
            return UInt8.max
        }
    }
    
    var data: NSData {
        let data = NSMutableData()
        var c = commandValue
        data.append(&c, length: 1)
        switch self {
        case .Ping:
            break
        case .Divide(var value, var by):
            data.append(&value, length: 1)
            data.append(&by, length: 1)
        case .DivideResponse(var value):
            data.append(&value, length: 1)
        case .Invalid:
            break
        }
        return data
    }
    
    static func fromData(data: NSData) -> Packet {
        let packet: Packet
        var command: UInt8 = 0
        data.getBytes(&command, length: 1)
        switch command {
        case 0:
            packet = .Ping
        case 1:
            var value: Int8 = 0
            var by: Int8 = 0
            data.getBytes(&value, range:NSMakeRange(1, 1))
            data.getBytes(&by, range:NSMakeRange(2, 1))
            packet = .Divide(value: value, by: by)
        default:
            packet = .Invalid
        }
        return packet
    }
    
}

class PacketPeripheral: RZBPeripheral {
    var packets: [Packet] = []
    
    func setPacketObserver(newPacket: @escaping (Packet) -> Void) {
        enableNotify(forCharacteristicUUID: PacketUUID.fromDevice, serviceUUID: PacketUUID.service, onUpdate: { characteristic, error in
            if let characteristic = characteristic, let data = characteristic.value {
                newPacket(Packet.fromData(data: data as NSData))
            }
            else if let error = error {
                print("Error handling is good \(error)")
            }
            }, completion: { characteristic, error in
                if let error = error {
                    print("Error handling is good \(error)")
                }
        })
    }
    
    func writePacket(packet: Packet) {
        write(packet.data as Data, characteristicUUID: PacketUUID.toDevice, serviceUUID: PacketUUID.service)
    }
    
}

struct PacketUUID {
    static let service = CBUUID(nsuuid: UUID())
    static let toDevice = CBUUID(nsuuid: UUID())
    static let fromDevice = CBUUID(nsuuid: UUID())
}

