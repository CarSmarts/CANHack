//
//  CarDecoder.swift
//  CANHack
//
//  Created by Robert Smith on 5/25/20.
//

import Foundation

public class CarDecoder: ObservableObject, Codable {
    public init(_ messages: [DecoderMessage]) {
        allNodes = Set(messages.map { $0.sendingNode })
        
        messagesById = Dictionary(uniqueKeysWithValues: messages.map { ($0.id, $0) })
    }
    
    public private(set) var allNodes: Set<DecoderNode>
    public private(set) var messagesById: Dictionary<MessageID, DecoderMessage>
    
    /// get a DecoderMessage for an ID, creating an empty one if neccessary
    public subscript(_ id: MessageID) -> DecoderMessage {
        if let existingMessage = messagesById[id] {
            return existingMessage
        } else {
            return DecoderMessage(id: id, name: "", len: 0, sendingNode: "")
        }
    }
}

public typealias DecoderNode = String

public class DecoderMessage: Codable {
    public init(id: MessageID, name: String, len: Int, sendingNode: DecoderNode, signals: [DecoderSignal] = []) {
        self.id = id
        self.name = name
        self.len = len
        self.sendingNode = sendingNode
        self.signals = signals
    }
    
    public var id: MessageID
    public var name: String
    public var len: Int
    
    public var sendingNode: DecoderNode
    
    public var signals: [DecoderSignal] = []
}

public class DecoderSignal: Codable {
    internal init(name: String, location: DecoderSignal.Location, conversion: DecoderSignal.Conversion, unit: String, recivingNode: DecoderNode) {
        self.name = name
        self.location = location
        self.conversion = conversion
        self.unit = unit
        self.recivingNode = recivingNode
    }
    
    public var name: String
    
    public struct Location: Codable {
        public var startBit: Int
        public var len: Int
        public var littleEndian: Bool
        public var signed: Bool
    }
    public var location: Location
    
    public struct Conversion: Codable {
        public var factor: Double
        public var offset: Int
        public var min: Int
        public var max: Int
    }
    public var conversion: Conversion
    
    public var unit: String

    public var recivingNode: DecoderNode
}

