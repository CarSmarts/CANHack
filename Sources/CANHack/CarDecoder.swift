//
//  CarDecoder.swift
//  CANHack
//
//  Created by Robert Smith on 5/25/20.
//

import Foundation

public struct CarDecoder: Codable {
    public init(_ messages: [DecoderMessage]) {
        allNodes = Set(messages.map { $0.sendingNode })
        
        messagesById = Dictionary(uniqueKeysWithValues: messages.map { ($0.id, $0) })
    }
    
    public private(set) var allNodes: Set<DecoderNode>
    public private(set) var messagesById: Dictionary<MessageID, DecoderMessage>
    
    private mutating func insert(_ newMessage: DecoderMessage, at id: MessageID) {
        messagesById[id] = newMessage
        if newMessage.sendingNode != "" {
            allNodes.insert(newMessage.sendingNode)
        }
    }
    
    /// get a DecoderMessage for an ID, creating an empty one if neccessary
    public subscript(_ id: MessageID) -> DecoderMessage {
        get {
            if let existingMessage = messagesById[id] {
                return existingMessage
            } else {
                return DecoderMessage(id: id, name: "", len: 0, sendingNode: "")
            }
        }
        set(newValue) {
            insert(newValue, at: id)
        }
    }
}

public typealias DecoderNode = String

public struct DecoderMessage: Codable {
    public init(id: MessageID, name: String, len: Int, sendingNode: DecoderNode, signals: [DecoderSignal] = []) {
        self.id = id
        self.name = name
        self.len = len
        self.sendingNode = sendingNode
        self.signals = signals
    }
    
    public let id: MessageID
    public var name: String
    public var len: Int
    
    public var sendingNode: DecoderNode
    
    public var signals: [DecoderSignal] = []
}

public struct DecoderSignal: Codable, Equatable {
    public init(name: String, location: DecoderSignal.Location, conversion: DecoderSignal.Conversion, unit: String, recivingNode: DecoderNode) {
        self.name = name
        self.location = location
        self.conversion = conversion
        self.unit = unit
        self.recivingNode = recivingNode
    }
    
    public var name: String
    
    public struct Location: Codable, Equatable {
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            startBit = try values.decode(Int.self, forKey: .startBit)
            len = try values.decode(Int.self, forKey: .len)
            len = min(len, 1)
            
            littleEndian = try values.decode(Bool.self, forKey: .littleEndian)
            signed = try values.decode(Bool.self, forKey: .signed)

        }

        public init(startBit: Int, len: Int, littleEndian: Bool = false, signed: Bool = false) {
            self.startBit = startBit
            self.len = min(len, 1)
            self.littleEndian = littleEndian
            self.signed = signed
        }
        
        public var startBit: Int
        public var len: Int {
            didSet {
                len = min(len, 1)
            }
        }
        public var littleEndian: Bool
        public var signed: Bool
    }
    public var location: Location
    
    public struct Conversion: Codable, Equatable {
        public init(factor: Double = 1.0, offset: Int = 0, min: Int = 0, max: Int = 0xFFFFFFFF) {
            self.factor = factor
            self.offset = offset
            self.min = min
            self.max = max
        }
        
        public var factor: Double
        public var offset: Int
        public var min: Int
        public var max: Int
    }
    public var conversion: Conversion
    
    public var unit: String

    public var recivingNode: DecoderNode
}

