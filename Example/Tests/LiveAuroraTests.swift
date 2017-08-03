//
//  LiveAuroraTests.swift
//  AuroraDreamband
//
//  Created by Rafael Nobre on 15/07/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import RZBluetooth
@testable import AuroraDreamband

class LiveAuroraTests: XCTestCase {
    
    let aurora = AuroraDreamband.shared
    
    private var connectionObserver: NSObjectProtocol!
    private var disconnectionObserver: NSObjectProtocol!
    private var connectionHandler: (() -> Void)?
    private var disconnectionHandler: (() -> Void)?
    
    
    override func setUp() {
        super.setUp()
        
        aurora.loggingEnabled = true
//        RZBSetLogHandler { (level, format, vaList) in
//            NSLogv(format!, vaList!)
//        }
        
        connectionObserver = NotificationCenter.default.addObserver(forName: .auroraDreambandConnected, object: nil, queue: .main) { _ in
            self.connectionHandler?()
        }
        
        disconnectionObserver = NotificationCenter.default.addObserver(forName: .auroraDreambandDisconnected, object: nil, queue: .main) { _ in
            self.disconnectionHandler?()
        }
        
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(connectionObserver)
        NotificationCenter.default.removeObserver(disconnectionObserver)
        
        aurora.disconnect()
        super.tearDown()
    }

    func testCanConnectToAurora() {
        #if TARGET_OS_SIMULATOR
            return
        #endif
        // Given
        var connected = false
        connectionHandler = {
            connected = true
        }
        // When
        aurora.connect()
        
        // Then
        expect(connected).toEventually(beTrue(), timeout: 10, pollInterval: 1)
    }
    
    func testCanDisconnectFromAurora() {
        #if TARGET_OS_SIMULATOR
            return
        #endif
        // Given
        testCanConnectToAurora()
        var disconnected = false
        disconnectionHandler = {
            disconnected = true
        }
        // When
        aurora.disconnect()
        // Then
        expect(disconnected).toEventually(beTrue(), timeout: 10, pollInterval: 1)
    }
    
    func testCanActivateDSLFeatureOnDevice() {
        #if TARGET_OS_SIMULATOR
            return
        #endif
        // Given
        testCanConnectToAurora()
        var settings = [ProfileSetting]()
        
        // When
        aurora.updateProfile(with: [.dslEnabled(true)]).then {
            self.aurora.readProfile()
        }.then { data in
            settings = try self.aurora.parseProfileSettings(from: data)
        }.catch { error in
            fail(error.localizedDescription)
        }
        
        expect(settings).toEventually(contain(.dslEnabled(true)), timeout: 20, pollInterval: 1)
    }
    
}
