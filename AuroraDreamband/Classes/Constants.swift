//
//  Constants.swift
//  Pods
//
//  Created by Rafael Nobre on 28/01/17.
//
//
import CoreBluetooth

let TRANSFER_MAX_PACKET_LENGTH = 20
let TRANSFER_MAX_PAYLOAD = 120
let AURORA_SERVICE_UUID = CBUUID(string: "6175726f-7261-454d-af79-42b381af0204")

struct AuroraChars {
    static let commandData = CBUUID(string: "6175726f-7261-49ce-8077-b954b033c880")
    static let commandStatus = CBUUID(string: "6175726f-7261-49ce-8077-b954b033c881")
    
    static let eventIndicated = CBUUID(string: "6175726f-7261-49ce-8077-a614a0dda570")
    static let eventNotified = CBUUID(string: "6175726f-7261-49ce-8077-a614a0dda571")
    
    static let commandOutputIndicated = CBUUID(string: "6175726f-7261-49ce-8077-b954b033c882")
    static let commandOutputNotified = CBUUID(string: "6175726f-7261-49ce-8077-b954b033c883")
    
    static let streamDataIndicated = CBUUID(string: "6175726f-7261-49ce-8077-b954b033c890")
    static let streamDataNotified = CBUUID(string: "6175726f-7261-49ce-8077-b954b033c891")
}

public enum SleepStage: Int32 {
    case unknown = 0
    case awake = 1
    case light = 2
    case deep = 3
    case rem = 4
}

enum CommandState: UInt8 {
    case idle = 0
    case execute = 1
    case responseObjectReady = 2
    case responseTableReady = 3
    case inputRequested = 4
}

enum DataType: Int32 {
    case unknown = 0
    case bool = 1
    case char = 2
    case uint8 = 3
    case int8 = 4
    case uint16 = 5
    case int16 = 6
    case uint32 = 7
    case int32 = 8
    case float = 9
    case str = 10
    case ptr = 11
}

struct EventOutputIds: OptionSet {
    let rawValue: UInt8
    
    static let usb       = EventOutputIds(rawValue: 1 << 0)
    static let log       = EventOutputIds(rawValue: 1 << 1)
    static let session   = EventOutputIds(rawValue: 1 << 2)
    static let profile   = EventOutputIds(rawValue: 1 << 3)
    static let bluetooth = EventOutputIds(rawValue: 1 << 4)
}

public enum EventId: UInt8 {
    case signalMonitor          = 0
    case sleepTrackerMonitor    = 1
    case movementMonitor        = 2
    case stimPresented          = 3
    
    case awakening              = 4
    case autoShutdown           = 5
    case alarm                  = 6
    case eventReserved2         = 7
    
    case eventReserved3         = 8
    case eventReserved4         = 9
    case eventReserved5         = 10
    case eventReserved6         = 11
    
    case eventReserved7         = 12
    case eventReserved8         = 13
    case eventReserved9         = 14
    case eventReserved10        = 15
    
    case buttonMonitor          = 16
    case sdcardMonitor          = 17
    case usbMonitor             = 18
    case batteryMonitor         = 19
    
    case buzzMonitor            = 20
    case ledMonitor             = 21
    case eventReserved11        = 22
    case eventReserved12        = 23
    
    case bleMonitor             = 24
    case bleNotify              = 25
    case bleIndicate            = 26
    case clockAlarmFire         = 27
    
    case clockTimer0Fire        = 28
    case clockTimer1Fire        = 29
    case clockTimer2Fire        = 30
    case clockTimerFire         = 31
}

public struct EventIds: OptionSet {
    public let rawValue: UInt32

    public static let signalMonitor       = EventIds(rawValue: 1 << 0)
    public static let sleepTrackerMonitor = EventIds(rawValue: 1 << 1)
    public static let movementMonitor     = EventIds(rawValue: 1 << 2)
    public static let stimPresented       = EventIds(rawValue: 1 << 3)

    public static let awakening           = EventIds(rawValue: 1 << 4)
    public static let autoShutdown        = EventIds(rawValue: 1 << 5)
    public static let alarm               = EventIds(rawValue: 1 << 6)
    public static let eventReserved2      = EventIds(rawValue: 1 << 7)

    public static let eventReserved3      = EventIds(rawValue: 1 << 8)
    public static let eventReserved4      = EventIds(rawValue: 1 << 9)
    public static let eventReserved5      = EventIds(rawValue: 1 << 10)
    public static let eventReserved6      = EventIds(rawValue: 1 << 11)

    public static let eventReserved7      = EventIds(rawValue: 1 << 12)
    public static let eventReserved8      = EventIds(rawValue: 1 << 13)
    public static let eventReserved9      = EventIds(rawValue: 1 << 14)
    public static let eventReserved10     = EventIds(rawValue: 1 << 15)

    public static let buttonMonitor       = EventIds(rawValue: 1 << 16)
    public static let sdcardMonitor       = EventIds(rawValue: 1 << 17)
    public static let usbMonitor          = EventIds(rawValue: 1 << 18)
    public static let batteryMonitor      = EventIds(rawValue: 1 << 19)

    public static let buzzMonitor         = EventIds(rawValue: 1 << 20)
    public static let ledMonitor          = EventIds(rawValue: 1 << 21)
    public static let eventReserved11     = EventIds(rawValue: 1 << 22)
    public static let eventReserved12     = EventIds(rawValue: 1 << 23)

    public static let bleMonitor          = EventIds(rawValue: 1 << 24)
    public static let bleNotify           = EventIds(rawValue: 1 << 25)
    public static let bleIndicate         = EventIds(rawValue: 1 << 26)
    public static let clockAlarmFire      = EventIds(rawValue: 1 << 27)

    public static let clockTimer0Fire     = EventIds(rawValue: 1 << 28)
    public static let clockTimer1Fire     = EventIds(rawValue: 1 << 29)
    public static let clockTimer2Fire     = EventIds(rawValue: 1 << 30)
    public static let clockTimerFire      = EventIds(rawValue: 1 << 31)
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

struct StreamIds: OptionSet {
    let rawValue: UInt32
    
    static let signalQuality    = StreamIds(rawValue: 1 << 0)
    static let rawEeg           = StreamIds(rawValue: 1 << 1)
    static let heartRate        = StreamIds(rawValue: 1 << 2)
    static let accelX           = StreamIds(rawValue: 1 << 3)
    
    static let accelY           = StreamIds(rawValue: 1 << 4)
    static let accelZ           = StreamIds(rawValue: 1 << 5)
    static let gyroX            = StreamIds(rawValue: 1 << 6)
    static let gyroY            = StreamIds(rawValue: 1 << 7)
    
    static let gyroZ            = StreamIds(rawValue: 1 << 8)
    static let temperature      = StreamIds(rawValue: 1 << 9)
    static let battery          = StreamIds(rawValue: 1 << 10)
    static let streamReserved1  = StreamIds(rawValue: 1 << 11)
    
    static let streamReserved2  = StreamIds(rawValue: 1 << 12)
    static let streamReserved3  = StreamIds(rawValue: 1 << 13)
    static let streamReserved4  = StreamIds(rawValue: 1 << 14)
    static let streamReserved5  = StreamIds(rawValue: 1 << 15)
    
    static let sleepFeatures    = StreamIds(rawValue: 1 << 16)
    static let sleepStages      = StreamIds(rawValue: 1 << 17)
    static let sleepTracker     = StreamIds(rawValue: 1 << 18)
    static let streamReserved6  = StreamIds(rawValue: 1 << 19)
    
    static let streamReserved7  = StreamIds(rawValue: 1 << 20)
    static let streamReserved8  = StreamIds(rawValue: 1 << 21)
    static let streamReserved9  = StreamIds(rawValue: 1 << 22)
    static let streamReserved10 = StreamIds(rawValue: 1 << 23)
    
    static let accelMagnitude   = StreamIds(rawValue: 1 << 24)
    static let gyroMagnitude    = StreamIds(rawValue: 1 << 25)
    static let rotationRoll     = StreamIds(rawValue: 1 << 26)
    static let rotationPitch    = StreamIds(rawValue: 1 << 27)
    
    static let streamReserved11 = StreamIds(rawValue: 1 << 28)
    static let streamReserved12 = StreamIds(rawValue: 1 << 29)
    static let streamReserved13 = StreamIds(rawValue: 1 << 30)
    static let streamReserved14 = StreamIds(rawValue: 1 << 31)
}

struct StreamOutputIds: OptionSet {
    let rawValue: UInt8

    static let silent    = StreamOutputIds(rawValue: 1 << 0)
    static let fileCsv   = StreamOutputIds(rawValue: 1 << 1)
    static let fileRaw   = StreamOutputIds(rawValue: 1 << 2)
    static let console   = StreamOutputIds(rawValue: 1 << 3)
    static let dataLog   = StreamOutputIds(rawValue: 1 << 4)
    static let bluetooth = StreamOutputIds(rawValue: 1 << 5)
}

public enum ProfileSetting {
    case wakeupTime(Double)
    case wakeupWindow(Double) //default 1800000 (30 minutes)
    case dslEnabled(Bool)
    case stimDelay(Double) //default 14400000 (4 hours)
    case stimInterval(Double) //default 300000 (5 minutes)
    case stimLed(command: String) // default led-blink 3 0xFF0000 0xFF 5 500 0
    case stimBuzz(command: String)
    case custom(key: String, value: String)
    
    init(key: String, value: String) {
        switch key {
        case "wakeup-time":
            self = .wakeupTime(Double(value) ?? 0)
        case "wakeup-window":
            self = .wakeupWindow(Double(value) ?? 1800000)
        case "dsl-enabled":
            self = .dslEnabled((value as NSString).boolValue)
        case "stim-delay":
            self = .stimDelay(Double(value) ?? 14400000)
        case "stim-interval":
            self = .stimInterval(Double(value) ?? 300000)
        case "stim-led":
            self = .stimLed(command: value)
        case "stim-buzz":
            self = .stimBuzz(command: value)
        default:
            self = .custom(key: key, value: value)
        }
    }
    
    var key: String {
        switch self {
        case .wakeupTime(_):
            return "wakeup-time"
        case .wakeupWindow(_):
            return "wakeup-window"
        case .dslEnabled(_):
            return "dsl-enabled"
        case .stimDelay(_):
            return "stim-delay"
        case .stimInterval(_):
            return "stim-interval"
        case .stimLed(_):
            return "stim-led"
        case .stimBuzz(_):
            return "stim-buzz"
        case .custom(let key, _):
            return key
        }
    }
    
    var value: String {
        switch self {
        case .wakeupTime(let time):
            return "\(time)"
            
        case .wakeupWindow(let window):
            return "\(window)"
            
        case .dslEnabled(let enabled):
            return "\(enabled ? 1 : 0)"
            
        case .stimDelay(let delay):
            return "\(delay)"
            
        case .stimInterval(let interval):
            return "\(interval)"
            
        case .stimLed(let command):
            return command
            
        case .stimBuzz(let command):
            return command
            
        case .custom(_, let value):
            return value
        }
    }
    
    var config: String {
        return "{\(key):\(value)}"
    }
}
