//
//  DecoderTests.swift
//  CANHackUI
//
//  Created by Robert Smith on 6/15/20.
//

import XCTest
@testable import CANHack

class DecoderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func DecoderTestCase(_ data: [Byte], _ location: DecoderSignal.Location, expectedResult: UInt64) {
            
        XCTAssertEqual(location.decodeRawValue(data), expectedResult)
    }
    
    func MergeBytesTestCase(_ data: [Byte], expectedResult: UInt64) {
            
        XCTAssertEqual(data.mergeBytes, expectedResult)
    }

    
    func testMergeBytes() {
        MergeBytesTestCase(
            [0x00, 0xAF, 0xFF],
            expectedResult: 0xFFAF00
        )
        
        MergeBytesTestCase(
            [0b00001010, 0b00001100],
            expectedResult: 0b0000110000001010
        )
    }
    
    func testDecode() throws {
        DecoderTestCase(
            [0x00, 0xAF, 0xFF],
            .init(startBit: 12, len: 4),
            expectedResult: 0xA
        )
        
        DecoderTestCase(
            [0xFF, 0xFF, 0xFF],
            .init(startBit: 1, len: 24 - 1),
            expectedResult: 0x7F_FF_FF
        )
        
        DecoderTestCase(
            [0b0011_0000, 0b0000_0011],
            .init(startBit: 4, len: 8),
            expectedResult: 0b0011_0011
        )
        
        DecoderTestCase(
            [0b0011_0000, 0b0000_0011],
            .init(startBit: 9, len: 1),
            expectedResult: 0b1
        )

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
