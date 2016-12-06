//
//  AuroraEvents.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 06/12/16.
//
//
import CoreBluetooth

public class AuroraEvents: NSObject {
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
    
}
