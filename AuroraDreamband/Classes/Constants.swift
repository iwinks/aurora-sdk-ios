//
//  Constants.swift
//  Pods
//
//  Created by Rafael Nobre on 28/01/17.
//
//

let TRANSFER_MAX_PACKET_LENGTH = 20
let TRANSFER_MAX_PAYLOAD = 128

public enum SleepStage: Int32 {
    case unknown = 0
    case awake = 1
    case light = 2
    case deep = 3
    case rem = 4
}

enum TransferState: Int16 {
    case idle = 0
    case cmdExecute = 1
    case cmdRespReady = 2
    case cmdOutputReady = 3
    case cmdInputRequested = 4
    case cmdInputReady = 5
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

enum EventOutput: Int32 {
    case usb = 0
    case log = 1
    case sessionFile = 2
    case profile = 3
    case bluetooth = 4
}

enum Stream: Int32 {
    
    case signalQuality = 0
    case rawEeg = 1
    case heartRate = 2
    case accelX = 3
    
    case accelY = 4
    case accelZ = 5
    case gyroX = 6
    case gyroY = 7
    
    case gyroZ = 8
    case temperature = 9
    case battery = 10
    case streamReserved1 = 11
    
    case streamReserved2 = 12
    case streamReserved3 = 13
    case streamReserved4 = 14
    case streamReserved5 = 15
    
    case sleepFeatures = 16
    case sleepStages = 17
    case sleepTracker = 18
    case streamReserved6 = 19
    
    case streamReserved7 = 20
    case streamReserved8 = 21
    case streamReserved9 = 22
    case streamReserved10 = 23
    
    case accelMagnitude = 24
    case gyroMagnitude = 25
    case rotationRoll = 26
    case rotationPitch = 27
    
    case streamReserved11 = 28
    case streamReserved12 = 29
    case streamReserved13 = 30
    case streamReserved14 = 31
}

enum StreamOutput: Int32 {
    case silent = 0
    case fileCsv = 1
    case fileRaw = 2
    case console = 3
    case dataLog = 4
    case ble = 5
}
