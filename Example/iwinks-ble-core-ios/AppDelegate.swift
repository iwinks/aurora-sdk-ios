//
//  AppDelegate.swift
//  iwinks-ble-core-ios
//
//  Created by Rafael Nobre on 11/17/2016.
//  Copyright (c) 2016 Rafael Nobre. All rights reserved.
//

import UIKit
import RZBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        RZBEnableMock(true)
        return true
    }

}
