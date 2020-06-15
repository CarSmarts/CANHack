//
//  Byte.swift
//  CANHack
//
//  Created by Robert Smith on 6/18/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

internal extension String {
    /// Returns a `self`; if `prefix` is found at the start of self, it is removed.
    func dropping(prefix: String) -> String {
        if starts(with: prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }
}

public typealias Byte = UInt8

public extension Byte {
    var bits: [Bool] {
        return Array(0..<8).map { self[$0] }
    }
    
    subscript(_ index: Int) -> Bool {
        precondition(index >= 0)
        precondition(index < 8)
        
        return (self & 0b1 << index) != 0
    }
}

public extension Byte {
    /// A human readable binary representation of a Byte
    var bin: String {
        let padding = String(repeating: "0", count: Swift.min(leadingZeroBitCount, 7))
        var string = "0b"+padding+String(self, radix: 2)
        
        // Insert space, for readability
        string.insert(" ", at: string.index(string.endIndex, offsetBy: -4))
        
        return string
    }
    
    /// A human readable hex representation of a Byte
    var hex: String {
        return String(format: "%02X", self)
    }
    
    /// Creates an instance of `self` from a hex string
    static func from(hex: String) -> Byte? {
        return Byte(hex.dropping(prefix: "0x"), radix: 16)
    }
}

public extension Array where Element == Byte {
    var mergeBytes: UInt64 {
        return self.enumerated().reduce(into: UInt64()) { (partialResult, pair) in
            partialResult |= UInt64(pair.element) << UInt64(pair.offset * 8)
        }
    }
}
