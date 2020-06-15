//
//  MessageSetView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Combine
import SwiftUI
import SmartCarUI
import CANHack
import AppFolder

public struct DecodedValueView: View {
    let message: Message
    let decoderSignal: DecoderSignal
    
    public var body: some View {
        HStack {
            Text(decoderSignal.name).padding(5.0)
            Spacer()
            Text("\(decoderSignal.decodeRawValue(message), specifier: "%x")")
                .modifier(Monospaced())
            
            Unwrap(decoderSignal.decodeTabelValue(message)) { label in
                Text(label)
            }
        }
    }
}

public struct MessageStatView: View {
    public init(groupStats: GroupedStat<Message, MessageID>, decoder: Binding<DecoderMessage>) {
        self.groupStats = groupStats
        self._decoder = decoder
    }
    
    @ObservedObject public var groupStats: GroupedStat<Message, MessageID>
    @Binding public var decoder: DecoderMessage
        
    public var body: some View {
        VStack(alignment: .leading) {
            MessageIDView(id: groupStats.group, decoder: $decoder)
            
            AdaptiveGraphView(groupStats: groupStats)
            
            Unwrap(self.groupStats.lastInstance?.signal) { signal in
                Enumerating(self.decoder.signals) { (decoderSignal: DecoderSignal, idx) in
                    DecodedValueView(message: signal, decoderSignal: decoderSignal)
                }
            }
        }
    }
}

public struct MessageSetView: View {
    public init(document: MessageSetDocument, decoder: Binding<CarDecoder>) {
        self.document = document
        self._decoder = decoder
    }
    
    @ObservedObject public var document: MessageSetDocument
    @Binding public var decoder: CarDecoder
    
    public var body: some View {
        GroupedByIdView(groupedSet: document.groupedById, decoder: $decoder)
    }
}

public struct GroupedByIdView: View {
    @ObservedObject public var groupedSet: GroupedSignalSet<Message, MessageID>
    @Binding public var decoder: CarDecoder
    
    public init(groupedSet: GroupedSignalSet<Message, MessageID>, decoder: Binding<CarDecoder>) {
        self.groupedSet = groupedSet
        self._decoder = decoder
    }
        
    public var body: some View {
        List(groupedSet.groups) { id in
            ZStack {
                MessageStatView(groupStats: self.groupedSet[id], decoder: self.$decoder[id])
                
                NavigationLink(destination: MessageDetailView(stats: self.groupedSet[id], decoder: self.$decoder[id]), label: { EmptyView() })
            }
        }
        .environmentObject(groupedSet.scale)
    }
}

struct MessageSetView_Previews: PreviewProvider {
    static var doc = MockMessageSetDocument()
    
    static var previews: some View {
        MessageSetView(document: doc, decoder: .constant(Mock.decoder))
    }
}
