//
//  CANHackTests.swift
//  CANHackTests
//
//  Created by Robert Smith on 5/24/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import XCTest
@testable import CANHack

class CANHackTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding() throws {
        let myDecoder = CarDecoder([])
        myDecoder[0xAF81111].name = "myName"
        myDecoder[0xAF81111].sendingNode = "Sender1"
        myDecoder[0xAF81010].name = "otherName"
        myDecoder[0xAF81010].sendingNode = "Sender2"
        
        let data = try JSONEncoder().encode(myDecoder)
        
        let newDecoder = try JSONDecoder().decode(CarDecoder.self, from: data)

        for id in [0xAF81111, 0xAF81010] as [MessageID] {
            XCTAssertEqual(myDecoder[id].name, newDecoder[id].name)
            
            XCTAssertEqual(myDecoder[id].sendingNode, newDecoder[id].sendingNode)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
