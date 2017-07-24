//
//  ViewController.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 11/17/2016.
//  Copyright (c) 2016 Rafael Nobre. All rights reserved.
//

import UIKit
import AuroraDreamband

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func connectTapped(_ sender: Any) {
        AuroraDreamband.shared.loggingEnabled = true
        AuroraDreamband.shared.connect()
    }
    
    @IBAction func disconnectTapped(_ sender: Any) {
        AuroraDreamband.shared.disconnect()
    }
}

