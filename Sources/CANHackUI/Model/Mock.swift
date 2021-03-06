//
//  Helper.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import CANHack
import SwiftUI
import AppFolder

public struct MockHelper {
    public var testSet: SignalSet<Message> = {
        GVRetParser().parse(string: Mock.testFile)
    }()
    
    public var groupedSet: GroupedSignalSet<Message, MessageID> = {
        let mockTestSet = GVRetParser().parse(string: Mock.testFile)
        
        return GroupedSignalSet(grouping: mockTestSet) { stat in
            stat.signal.id
        }
    }()
    
    public var signalInstance: SignalInstance<Message> = {
        SignalInstance(signal: Message(id: 0xAF81111, contents: []), timestamp: 0)
    }()

    public var decoder: CarDecoder = {
        let decoder = CarDecoder([
            DecoderMessage(id: 0xAF81111, name: "Relay Control Status", len: 2, sendingNode: "Relay"),
            DecoderMessage(id: 0x12F83130, name: "Lock Status", len: 1, sendingNode: "Lock", signals: [
                DecoderSignal(name: "Lock", location: .init(startBit: 2, len: 2), valueTable: [
                   DecoderValue(value: 0, label: "Unlocked"),
                   DecoderValue(value: 1, label: "Locked"),
                   DecoderValue(value: 2, label: "Unlocked?"),
               ]),
                DecoderSignal(name: "Cylinder", location: .init(startBit: 6, len: 2), valueTable: [
                    DecoderValue(value: 0, label: "Rest")
                ]),
            ])
        ])
        
        return decoder
    }()
    
    public var decoderMessage = DecoderMessage(id: 0xAF81111, name: "Relay Control Status", len: 2, sendingNode: "Relay")
}

public struct Mock {
    private static var _mockHelper = MockHelper()
    
    public static var testFile: String { return """
    TimeStamp,ID,Extended,Dir,Bus,LEN,D1,D2,D3,D4,D5,D6,D7,D8
    12545,0x12F85351,true,Rx,1,6,43,00,00,00,00,00
    13756,0x12F85351,true,Rx,1,6,42,00,00,00,00,00
    14652,0x12F85351,true,Rx,1,6,41,00,00,00,00,00
    15548,0x12F85351,true,Rx,1,6,40,00,00,00,00,00
    17654,0x12F85351,true,Rx,1,6,40,00,00,00,00,00
    18550,0x12F85351,true,Rx,1,6,39,00,00,00,00,00
    20653,0x12F85351,true,Rx,1,6,39,00,00,00,00,00
    21547,0x12F85351,true,Rx,1,6,40,00,00,00,00,00
    23649,0x12F85351,true,Rx,1,6,40,00,00,00,00,00
    26953,0x12F85351,true,Rx,1,6,40,00,00,00,00,00
    31150,0x12F85351,true,Rx,1,6,41,00,00,00,00,00
    33252,0x12F85351,true,Rx,1,6,42,00,00,00,00,00
    35352,0x12F85351,true,Rx,1,6,43,00,00,00,00,00
    47052,0x12F85351,true,Rx,1,6,43,00,00,00,00,00
    49151,0x12F85351,true,Rx,1,6,44,00,00,00,00,00
    51252,0x12F85351,true,Rx,1,6,44,00,00,00,00,00
    53351,0x12F85351,true,Rx,1,6,44,00,00,00,00,00
    57863,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    59965,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    62067,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    64165,0x12F85351,true,Rx,1,6,46,00,00,00,00,00
    67466,0x12F85351,true,Rx,1,6,46,00,00,00,00,00
    68672,0x12F85351,true,Rx,1,6,46,00,00,00,00,00
    69565,0x12F85351,true,Rx,1,6,47,00,00,00,00,00
    70771,0x12F85351,true,Rx,1,6,47,00,00,00,00,00
    71664,0x12F85351,true,Rx,1,6,47,00,00,00,00,00
    72871,0x12F85351,true,Rx,1,6,47,00,00,00,00,00
    74969,0x12F85351,true,Rx,1,6,48,00,00,00,00,00
    76176,0x12F85351,true,Rx,1,6,48,00,00,00,00,00
    77069,0x12F85351,true,Rx,1,6,48,00,00,00,00,00
    78276,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    79168,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    80374,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    81266,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    81276,0xAF81111,true,Rx,1,2,00,00
    81530,0x12F85250,true,Rx,1,4,75,04,AD,D2
    81581,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    82473,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    84571,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    85778,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    86671,0x12F85351,true,Rx,1,6,49,00,00,00,00,00
    86987,0x12F85351,true,Rx,1,6,50,00,00,00,00,00
    87878,0x12F85351,true,Rx,1,6,50,00,00,00,00,00
    88769,0x12F85351,true,Rx,1,6,51,00,00,00,00,00
    89085,0x12F85351,true,Rx,1,6,51,00,00,00,00,00
    89977,0x12F85351,true,Rx,1,6,51,00,00,00,00,00
    90870,0x12F85351,true,Rx,1,6,51,00,00,00,00,00
    91185,0x12F85351,true,Rx,1,6,51,00,00,00,00,00
    92079,0x12F85351,true,Rx,1,6,51,00,00,00,00,00
    92971,0x12F85351,true,Rx,1,6,51,00,00,00,00,00
    94178,0x12F85351,true,Rx,1,6,41,00,00,00,00,00
    95071,0x12F85351,true,Rx,1,6,41,00,00,00,00,00
    96276,0x12F85351,true,Rx,1,6,44,00,00,00,00,00
    113493,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    114070,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    114387,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    114703,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    114967,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    115284,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    115600,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    115863,0x12F85351,true,Rx,1,6,45,00,00,00,00,00
    9767,0x12F83130,true,Rx,1,1,02
    9997,0x12F81010,true,Rx,1,2,00,00
    10004,0x12F83210,true,Rx,1,1,05
    10042,0x12F83010,true,Rx,1,1,80
    10070,0x12F83130,true,Rx,1,1,04
    10299,0x12F83210,true,Rx,1,1,00
    10342,0x12F83010,true,Rx,1,1,80
    10375,0x12F83130,true,Rx,1,1,08
    10599,0x12F83210,true,Rx,1,1,00
    10642,0x12F83010,true,Rx,1,1,80
    10675,0x12F83130,true,Rx,1,1,08
    10900,0x12F83210,true,Rx,1,1,0A
    10942,0x12F83010,true,Rx,1,1,80
    10970,0x12F83130,true,Rx,1,1,08
    11199,0x12F83210,true,Rx,1,1,00
    11242,0x12F83010,true,Rx,1,1,80
    11270,0x12F83130,true,Rx,1,1,08
    11499,0x12F83210,true,Rx,1,1,00
    11542,0x12F83010,true,Rx,1,1,80
    11570,0x12F83130,true,Rx,1,1,08
    11795,0x12F81010,true,Rx,1,2,00,00
    11802,0x12F83210,true,Rx,1,1,00
    11840,0x12F83010,true,Rx,1,1,80
    11872,0x12F83130,true,Rx,1,1,00
    12097,0x12F83210,true,Rx,1,1,00
    12140,0x12F83010,true,Rx,1,1,80
    12168,0x12F83130,true,Rx,1,1,00
    12397,0x12F83210,true,Rx,1,1,00
    12440,0x12F83010,true,Rx,1,1,80
    12468,0x12F83130,true,Rx,1,1,00
    12698,0x12F83210,true,Rx,1,1,00
    12740,0x12F83010,true,Rx,1,1,80
    12768,0x12F83130,true,Rx,1,1,04
    12993,0x12F81010,true,Rx,1,2,00,00
    13000,0x12F83210,true,Rx,1,1,00
    13037,0x12F83010,true,Rx,1,1,80
    13070,0x12F83130,true,Rx,1,1,00
    13295,0x12F83210,true,Rx,1,1,00
    13338,0x12F83010,true,Rx,1,1,80
    13371,0x12F83130,true,Rx,1,1,08
    13595,0x12F83210,true,Rx,1,1,00
    13638,0x12F83010,true,Rx,1,1,80
    13671,0x12F83130,true,Rx,1,1,04
    13896,0x12F83210,true,Rx,1,1,00
    13938,0x12F83010,true,Rx,1,1,80
    13971,0x12F83130,true,Rx,1,1,08
    14191,0x12F81010,true,Rx,1,2,00,00
    14198,0x12F83210,true,Rx,1,1,0A
    14236,0x12F83010,true,Rx,1,1,80
    14268,0x12F83130,true,Rx,1,1,02
    14493,0x12F83210,true,Rx,1,1,00
    14536,0x12F83010,true,Rx,1,1,80
    14569,0x12F83130,true,Rx,1,1,08
    14793,0x12F83210,true,Rx,1,1,00
    14836,0x12F83010,true,Rx,1,1,80
    14869,0x12F83130,true,Rx,1,1,00
    15094,0x12F83210,true,Rx,1,1,00
    15136,0x12F83010,true,Rx,1,1,80
    15169,0x12F83130,true,Rx,1,1,08
    15389,0x12F81010,true,Rx,1,2,00,00
    15396,0x12F83210,true,Rx,1,1,00
    15433,0x12F83010,true,Rx,1,1,80
    15471,0x12F83130,true,Rx,1,1,08
    15691,0x12F83210,true,Rx,1,1,00
    15734,0x12F83010,true,Rx,1,1,80
    15772,0x12F83130,true,Rx,1,1,08
    15530,0x12F85250,true,Rx,1,4,75,04,AD,D2
    15991,0x12F83210,true,Rx,1,1,00
    16034,0x12F83010,true,Rx,1,1,80
    16072,0x12F83130,true,Rx,1,1,08
    16291,0x12F83210,true,Rx,1,1,00
    16334,0x12F83010,true,Rx,1,1,80
    16372,0x12F83130,true,Rx,1,1,08
    16592,0x12F83210,true,Rx,1,1,00
    16634,0x12F83010,true,Rx,1,1,80
    16672,0x12F83130,true,Rx,1,1,08
    16887,0x12F81010,true,Rx,1,2,00,00
    16894,0x12F83210,true,Rx,1,1,00
    16932,0x12F83010,true,Rx,1,1,80
    16970,0x12F83130,true,Rx,1,1,08
    17189,0x12F83210,true,Rx,1,1,0A
    17232,0x12F83010,true,Rx,1,1,80
    17270,0x12F83130,true,Rx,1,1,00
    17489,0x12F83210,true,Rx,1,1,00
    17532,0x12F83010,true,Rx,1,1,80
    17570,0x12F83130,true,Rx,1,1,00
    17790,0x12F83210,true,Rx,1,1,00
    17832,0x12F83010,true,Rx,1,1,80
    17870,0x12F83130,true,Rx,1,1,02
    18085,0x12F81010,true,Rx,1,2,00,00
    18092,0x12F83210,true,Rx,1,1,00
    18130,0x12F83010,true,Rx,1,1,80
    18172,0x12F83130,true,Rx,1,1,08
    18387,0x12F83210,true,Rx,1,1,00
    18430,0x12F83010,true,Rx,1,1,80
    18473,0x12F83130,true,Rx,1,1,08
    18687,0x12F83210,true,Rx,1,1,00
    18730,0x12F83010,true,Rx,1,1,80
    """
    }

    public static var testSet: SignalSet<Message> {
        _mockHelper.testSet
    }
    
    public static var groupedSet: GroupedSignalSet<Message, MessageID> {
        _mockHelper.groupedSet
    }
    
    public static var signalInstance: SignalInstance<Message> {
        _mockHelper.signalInstance
    }

    public static var decoder: CarDecoder {
        _mockHelper.decoder
    }
    
    public static var decoderMessage: DecoderMessage {
        _mockHelper.decoderMessage
    }
    
    public static var globalManager = { () -> CANHackManager in
        let manager = CANHackManager()
        
        
        
        return manager
    }()
}

public class MockMessageSetDocument: MessageSetDocument {
    public init() {
        super.init(fileURL: AppFolder.tmp.baseURL.appendingPathComponent("testSet"))
    
        signalSet = Mock.testSet
    }
    
    public override func contents(forType typeName: String) throws -> Any {
        return Data()
    }
    
    public override func load(fromContents contents: Any, ofType typeName: String?) throws {
        

    }
}

public class MockDecoderDocument: CarDecoderDocument {
    public init() {
        super.init(fileURL: AppFolder.tmp.baseURL.appendingPathComponent("testDecoder"))
        
        decoder = Mock.decoder
    }
    
    public override func contents(forType typeName: String) throws -> Any {
        return Data()
    }
    
    public override func load(fromContents contents: Any, ofType typeName: String?) throws {

    }
}
