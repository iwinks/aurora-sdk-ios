//
//  AuroraEvents.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 06/12/16.
//
//
import CoreBluetooth

class AuroraEvents: NSObject {
    var signalMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA570")
        }
    }
    
    var sleepMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA571")
        }
    }
    
    var movement: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA572")
        }
    }
    
    var stimPresented: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA573")
        }
    }
    
    var awakening: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA574")
        }
    }
    
    var autoShutdown: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA575")
        }
    }
    
    var reserved1: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA576")
        }
    }
    
    var reserved2: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA577")
        }
    }
    
    var reserved3: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA578")
        }
    }
    
    var reserved4: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA579")
        }
    }
    
    var reserved5: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57A")
        }
    }
    
    var reserved6: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57B")
        }
    }
    
    var reserved7: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57C")
        }
    }
    
    var reserved8: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57D")
        }
    }
    
    var reserved9: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57E")
        }
    }
    
    var reserved10: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57F")
        }
    }
    
    var buttonMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA580")
        }
    }
    
    var sdCardMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA581")
        }
    }
    
    var usbMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA582")
        }
    }
    
    var batteryMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA583")
        }
    }
    
    var buzzMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA584")
        }
    }
    
    var ledMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA585")
        }
    }
    
    var reserved11: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA586")
        }
    }
    
    var reserved12: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA587")
        }
    }
    
    var bleMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA588")
        }
    }
    
    var bleNotify: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA589")
        }
    }
    
    var bleIndicate: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58A")
        }
    }
    
    var clockAlarmFire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58B")
        }
    }
    
    var clockTimer0Fire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58C")
        }
    }
    
    var clockTimer1Fire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58D")
        }
    }
    
    var clockTimer2Fire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58E")
        }
    }
    
    var clockTimerFire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58F")
        }
    }
    
    var transferData: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C880")
        }
    }
    
    var transferStatus: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C881")
        }
    }
    
//    var streamData: CBUUID {
//        get {
//            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C890")
//        }
//    }
    
    var streamData: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C891")
        }
    }
    
}
