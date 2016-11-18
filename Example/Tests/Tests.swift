// https://github.com/Quick/Quick

import XCTest
import Nimble
@testable import iwinks_ble_core_ios

class BLETests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testBasicMatcher() {
        expect(1) == 1
    }

    func testBasicFailure() {
        expect(2) != 1
    }

}

