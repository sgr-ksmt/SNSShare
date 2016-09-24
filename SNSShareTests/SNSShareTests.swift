//
//  SNSShareTests.swift
//  SNSShareTests
//
//  Created by Suguru Kishimoto on 2015/12/21.
//
//

import XCTest
@testable import SNSShare

class SNSShareTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testShareData() {
        let sd1 = SNSShareData {
            $0.text = "Share it!"
        }
        XCTAssertEqual(sd1.text, "Share it!")
        
        let sd2 = SNSShareData()
        XCTAssertEqual(sd2.text, "")
        
        let sd3 = SNSShareData("wahaha!!")
        XCTAssertEqual(sd3.text, "wahaha!!")
        
        let sd4 = SNSShareData([URL(string: "http://www.google.co.jp")!])
        XCTAssertEqual(sd4.text, "")
        XCTAssertEqual(sd4.urls.count, 1)
        XCTAssertEqual(sd4.urls[0], URL(string: "http://www.google.co.jp")!)
    }
}
