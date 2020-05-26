//
//  CarDecoder.swift
//  CANHack
//
//  Created by Robert Smith on 5/25/20.
//

import Foundation

class CarDecoder: Codable {
    public var nodes: [DecoderNode] = []
    
    public var messages: [DecoderMessage] = []
}

public class DecoderNode: Codable {
    public init(name: String) {
        self.name = name
    }
    
    public var name: String
}

public struct DecoderMessage: Codable {
    public var id: MessageID
    public var name: String
    public var len: Int
    
    public var sendingNode: DecoderNode
    
    public var signals: [DecoderSignal] = []
}

public struct DecoderSignal: Codable {
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

