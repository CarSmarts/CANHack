//
//  Message.swift
//  CANHack
//
//  Created by Robert Smith on 6/18/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// A specific instance of a network message.
public struct Message: Signal, Codable {
    /// The id of the message.
    public var id: MessageID
    /// The message contents
    public var contents: [Byte]
    
    /// The length of the message (number of bytes)
    public var length: Int {
        return contents.count
    }
    
    public init(id: MessageID, contents: [Byte]) {
        self.id = id
        self.contents = contents
    }
}

extension Message: Hashable, Comparable {
    public static func <(lhs: Message, rhs: Message) -> Bool {
        if lhs.id == rhs.id {
            for (left, right) in zip(lhs.contents, rhs.contents) {
                if left != right {
                    return left < right
                }
            }
            return false // equal
        }
        else {
            return lhs.id.rawValue < rhs.id.rawValue
        }
    }
}

extension Message: CustomStringConvertible {
    public var description: String {
        return "\(id.hex): " + contentDescription
    }
    
    public var contentDescription: String {
        return contents.map { $0.hex }.joined(separator: " ")
    }
}

/// Array Sorting
extension Sequence where Element: Comparable {
    static func <(lhs: Self, rhs: Self) -> Bool {
        for (left, right) in zip(lhs, rhs) {
            if left != right {
                return left < right
            }
        }
        return false // equal
    }
}
