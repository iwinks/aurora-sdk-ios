//
//  AuroraService.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 06/12/16.
//
//

import UIKit
import CoreBluetooth

public class AuroraService: NSObject {
    public class var uuid: CBUUID {
        get {
            return CBUUID(string: "6175726F-7261-454D-AF79-42B381AF0204")
        }
    }
    
    public class var events: AuroraEvents {
        get {
            return AuroraEvents()
        }
    }
}

