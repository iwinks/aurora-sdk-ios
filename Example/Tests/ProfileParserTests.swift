//
//  ProfileParserTests.swift
//  AuroraDreamband
//
//  Created by Rafael Nobre on 15/06/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
@testable import AuroraDreamband

class ProfileParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParsesAllAvailableSettings() {
        // Given
        let remStimProf = FileHelper.data(with: "rem-stim", extension: "prof")
        let auroraApi = AuroraDreamband()
        
        // When
        var settings = [ProfileSetting]()
        expect {
            settings = try auroraApi.parseProfileSettings(from: remStimProf)
        }.notTo(throwError())
        
        // Then
        expect(settings.count) > 0
        
        expect(settings).to(contain(.wakeupTime(0)))
        
        // Custom setting that matches a given preset will also be considered
        expect(settings).to(contain(.custom(key: "wakeup-time", value: "0")))
        
        expect(settings).to(contain(.wakeupWindow(1800000)))

        expect(settings).to(contain(.dslEnabled(true)))
        
        expect(settings).to(contain(.stimDelay(14400000)))
        
        expect(settings).to(contain(.stimInterval(300000)))
        
        expect(settings).to(contain(.stimLed(command: "led-blink 3 0xFF0000 0xFF 5 500 0")))
        
        expect(settings).to(contain(.stimBuzz(command: "")))
        
        // Unknown settings will be parsed as custom key/value settings
        expect(settings).to(contain(.custom(key: "data-streams", value: "0x01000403")))
        // Repeated settings with different values will be parsed as distinct settings
        expect(settings).to(contain(.custom(key: "sel-indicator", value: "3 0xFF00FF 0x7F")))
        expect(settings).to(contain(.custom(key: "sel-indicator", value: "3 0xFF00FF 0x40")))
        
    }
    
    func testAppliesSettingsInProfile() {
        // Given
        let remStimProf = FileHelper.data(with: "rem-stim", extension: "prof")
        let auroraApi = AuroraDreamband()
        
        // When
        var newSettings = [ProfileSetting]()
        newSettings.append(.wakeupTime(800000))
        newSettings.append(.wakeupWindow(1000))
        newSettings.append(.dslEnabled(false))
        newSettings.append(.stimDelay(0))
        newSettings.append(.stimInterval(-1))
        newSettings.append(.stimBuzz(command: "buzz-note 56 200"))
        newSettings.append(.custom(key: "sel-indicator", value: "xpto"))
        // Duplicate settings
        newSettings.append(.wakeupTime(100000))
        newSettings.append(.custom(key: "sel-indicator", value: "3 0xFF00FF 0x7F"))
        var modifiedProfile = Data()
        expect {
            modifiedProfile = try auroraApi.applyProfileSettings(newSettings, to: remStimProf)
        }.notTo(throwError())
        
        // Then
        var settings = [ProfileSetting]()
        expect {
            settings = try auroraApi.parseProfileSettings(from: modifiedProfile)
        }.notTo(throwError())

        expect(settings.count) > 0
        
        expect(settings).to(contain(.wakeupTime(800000)))
        expect(settings).to(contain(.wakeupWindow(1000)))
        expect(settings).to(contain(.dslEnabled(false)))
        expect(settings).to(contain(.stimDelay(0)))
        expect(settings).to(contain(.stimInterval(-1)))
        expect(settings).to(contain(.stimBuzz(command: "buzz-note 56 200")))
        // When adding duplicate settings the expectation is that only the first one will be applied
        expect(settings).notTo(contain(.wakeupTime(100000)))
        expect(settings).to(contain(.custom(key: "sel-indicator", value: "xpto")))
        expect(settings).notTo(contain(.custom(key: "sel-indicator", value: "3 0xFF00FF 0x7F")))
    }
    
    func testNoSettingChangeKeepsProfileIntact() {
        // Given
        let remStimProf = FileHelper.data(with: "rem-stim", extension: "prof")
        let auroraApi = AuroraDreamband()
        
        // When
        var modifiedProfile = Data()
        expect {
            modifiedProfile = try auroraApi.applyProfileSettings([ProfileSetting](), to: remStimProf)
            }.notTo(throwError())
        
        // Then
        expect(remStimProf) == modifiedProfile
    }
    
}
