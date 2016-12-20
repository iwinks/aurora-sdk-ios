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
    
}
