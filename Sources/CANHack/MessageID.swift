//
//  MessageID.swift
//  SmartCar
//
//  Created by Robert Smith on 6/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public struct MessageID : Signal, ExpressibleByIntegerLiteral {
    public typealias RawValue = UInt32
    
    public var rawValue: UInt32
        
    public init(integerLiteral value: IntegerLiteralType) {
        self.rawValue = UInt32(value)
    }
    
    public init?(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public var extended: Bool {
        return rawValue > 0x7FF
    }
}

public extension MessageID {
    struct InvalidHexError: Error {
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        
        guard let parsed = Self.from(hex: try values.decode(String.self)) else {
            throw InvalidHexError()
        }
        
        self = parsed
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hex)
    }
    
}

extension MessageID: Identifiable {
    public var id: RawValue {
        rawValue
    }
}

public extension MessageID {
    /// A list of the bytes that make up `self`
    var bytes: [Byte] {
        return [
            Byte(rawValue >> 24),
            Byte(rawValue >> 16 & 0xFF),
            Byte(rawValue >> 8 & 0xFF),
            Byte(rawValue & 0xFF),
        ]
    }
            
    /// Accesses the byte at `index`
    ///
    /// Identical to `bytes[index]`
    subscript(index: Int) -> Byte {
        return bytes[index]
    }
    
    /// A human readable hex representation of `self`
    var hex: String {
        return "0x" + String(format: "%X", rawValue)
    }
    
    /// Creates am instance of `self` from a hex string
    static func from(hex: String) -> MessageID? {
        guard let value = RawValue(hex.dropping(prefix: "0x"), radix: 16) else { return nil }
        
        return MessageID(rawValue: value)
    }
}

extension MessageID: Comparable {
    public static func <(lhs: MessageID, rhs: MessageID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension MessageID: CustomStringConvertible {
    public var description: String {
        return hex
    }
}
