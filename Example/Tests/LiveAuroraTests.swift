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
    
    private let aurora = AuroraDreamband.shared
    private var connectionObserver: NSObjectProtocol!
    private var disconnectionObserver: NSObjectProtocol!
    private var connectionHandler: (() -> Void)?
    private var disconnectionHandler: (() -> Void)?
    
    
    override class func setUp() {
        super.setUp()
        
        AsyncDefaults.Timeout = 30
        AsyncDefaults.PollInterval = 0.1
        
        AuroraDreamband.shared.loggingEnabled = true
        //        RZBSetLogHandler { (level, format, vaList) in
        //            NSLogv(format!, vaList!)
        //        }
    }
    
    override func setUp() {
        super.setUp()
        
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
        super.tearDown()
    }
    
    override class func tearDown() {

        AuroraDreamband.shared.disconnect()
        super.tearDown()
    }
    
    func testCanActivateDSLFeatureOnDevice() {
        #if TARGET_OS_SIMULATOR
            return
        #endif
        // Given
        var settings = [ProfileSetting]()
        
        // When
        aurora.updateProfile(with: [.dslEnabled(true)]).then {
            self.aurora.readProfile()
        }.then { data in
            settings = try self.aurora.parseProfileSettings(from: data)
        }.catch { error in
            fail(error.localizedDescription)
        }
        
        expect(settings).toEventually(contain(.dslEnabled(true)))
    }
    
}
