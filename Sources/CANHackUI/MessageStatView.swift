//
//  MessageStatView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import CANHack
import SmartCarUI

struct Monospaced: ViewModifier {
    var style: Font.TextStyle = .body
    
    func body(content: Content) -> some View {
        content.font(.system(.body, design: .monospaced))
    }
}

struct MessageIDView: View {
    public init(id: MessageID, decoder: Binding<DecoderMessage>) {
        self.id = id
        self._decoder = decoder
    }
    
    public var id: MessageID
    @Binding var decoder: DecoderMessage
    
    var body: some View {
        HStack {
            Text(id.description)
                .modifier(Monospaced(style: .headline))
                .layoutPriority(10.0)
            
            TextField("name", text: $decoder.name)
                .font(.subheadline)
            
            TextField("sender", text: $decoder.sendingNode)
                .frame(width: 70.0)
                .font(.subheadline)
        }
    }
}

struct MessageStatView: View {
    public init(groupStats: GroupedStat<Message, MessageID>, decoder: Binding<DecoderMessage>) {
        self.groupStats = groupStats
        self._decoder = decoder
        
        if let first = groupStats.firstInstance {
            activeSignal = first
        }
    }
    
    @ObservedObject public var groupStats: GroupedStat<Message, MessageID>
    @Binding public var decoder: DecoderMessage

    @State private var activeSignal: SignalInstance<Message> = SignalInstance(signal: Message(id: 0xAF81111, contents: []), timestamp: 0)
    
    var shortList: ArraySlice<SignalStat<Message>> {
        groupStats.stats.prefix(10)
    }
    
    var remander: Int {
        groupStats.stats.count - 10
    }
    
    var signalText: String {
        shortList.map {
            $0.signal.contentDescription
        }.joined(separator: "\n")
    }
    
    var body: some View {
        VStack(alignment: .leading) {

            MessageIDView(id: groupStats.group, decoder: $decoder)
                
            OccuranceGraph(data: self.groupStats, scale: self.groupStats.scale, activeSignal: $activeSignal)
            
        }
    }
}

struct MessageStatView_Previews: PreviewProvider {
    static var previews: some View {
//        let groupedSet = Mock.mockGroupedSet
        
//        let goodExample = groupedSet.stats.first { stat in
//            stat.stats.count > 1
//        }
//
//        let testExample = groupedSet.stats.first { stat in
//            stat.group == MessageID(rawValue: 0xAF81111)!
//        }
//
//        let longExample = groupedSet.stats.first { stat in
//            stat.group == MessageID(rawValue: 0x12F85351)
//        }
        
//        return Group {
//            Unwrap(goodExample) {
//                MessageStatView(groupStats: $0, decoder: .constant(Mock.mockDecoder))
//            }
//
//            Unwrap(testExample) {
//                MessageStatView(groupStats: $0, decoder: .constant(Mock.mockDecoder))
//            }
//
//            Unwrap(longExample) {
//                MessageStatView(groupStats: $0, decoder: .constant(Mock.mockDecoder))
//            }
//        }.previewLayout(.fixed(width: 375, height: 170))
        
        return MessageSetView(document: MockMessageSetDocument(), decoder: .constant(Mock.mockDecoder))
    }
}
