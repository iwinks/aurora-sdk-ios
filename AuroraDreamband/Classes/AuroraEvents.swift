//
//  AuroraEvents.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 06/12/16.
//
//
import CoreBluetooth

public class AuroraEvents: NSObject {
    public var signalMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA570")
        }
    }
    
    public var sleepMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA571")
        }
    }
    
    public var movement: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA572")
        }
    }
    
    public var stimPresented: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA573")
        }
    }
    
    public var awakening: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA574")
        }
    }
    
    public var autoShutdown: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA575")
        }
    }
    
    public var reserved1: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA576")
        }
    }
    
    public var reserved2: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA577")
        }
    }
    
    public var reserved3: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA578")
        }
    }
    
    public var reserved4: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA579")
        }
    }
    
    public var reserved5: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57A")
        }
    }
    
    public var reserved6: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57B")
        }
    }
    
    public var reserved7: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57C")
        }
    }
    
    public var reserved8: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57D")
        }
    }
    
    public var reserved9: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57E")
        }
    }
    
    public var reserved10: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA57F")
        }
    }
    
    public var buttonMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA580")
        }
    }
    
    public var sdCardMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA581")
        }
    }
    
    public var usbMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA582")
        }
    }
    
    public var batteryMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA583")
        }
    }
    
    public var buzzMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA584")
        }
    }
    
    public var ledMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA585")
        }
    }
    
    public var reserved11: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA586")
        }
    }
    
    public var reserved12: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA587")
        }
    }
    
    public var bleMonitor: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA588")
        }
    }
    
    public var bleNotify: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA589")
        }
    }
    
    public var bleIndicate: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58A")
        }
    }
    
    public var clockAlarmFire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58B")
        }
    }
    
    public var clockTimer0Fire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58C")
        }
    }
    
    public var clockTimer1Fire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58D")
        }
    }
    
    public var clockTimer2Fire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58E")
        }
    }
    
    public var clockTimerFire: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-A614A0DDA58F")
        }
    }
    
    public var transferData: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C880")
        }
    }
    
    public var transferStatus: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C881")
        }
    }
    
//    public var streamData: CBUUID {
//        get {
//            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C890")
//        }
//    }
    
    public var streamData: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-49CE-8077-B954B033C891")
        }
    }
    
}
