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
    public init(id: MessageID, decoder: Binding<DecoderMessage>, canEdit: Bool = false) {
        self.id = id
        self._decoder = decoder
        self.canEdit = canEdit
    }
    
    public var id: MessageID
    public var canEdit: Bool
    @Binding var decoder: DecoderMessage
    
    var body: some View {
        HStack {
            Text(id.description)
                .modifier(Monospaced(style: .headline))
                .layoutPriority(10.0)
            if canEdit {
            TextField("name", text: $decoder.name)
                .font(.subheadline)
            
            TextField("sender", text: $decoder.sendingNode)
                .frame(width: 70.0)
                .font(.subheadline)
            } else {
                Text(decoder.name)
                    .font(.subheadline)
                
                Text(decoder.sendingNode)
                    .frame(width: 70.0)
                    .font(.subheadline)
            }
        }
    }
}

struct MessageStatView: View {
    public init(groupStats: GroupedStat<Message, MessageID>, decoder: Binding<DecoderMessage>, activeSignal: Binding<SignalInstance<Message>>, scale: Binding<OccuranceGraphScale>) {
        self.groupStats = groupStats
        self._decoder = decoder
        self._activeSignal = activeSignal
        self._scale = scale
    }
    
    @ObservedObject public var groupStats: GroupedStat<Message, MessageID>
    @Binding public var decoder: DecoderMessage
    @Binding public var scale: OccuranceGraphScale

    @Binding var activeSignal: SignalInstance<Message>
        
    var body: some View {
        VStack(alignment: .leading) {
            MessageIDView(id: groupStats.group, decoder: $decoder)
                
            OccuranceGraph(data: self.groupStats, scale: self.$scale)
        }
    }
}

struct MessageStatView_Previews: PreviewProvider {
    static var previews: some View {
        return MessageSetView(document: MockMessageSetDocument(), decoder: .constant(Mock.decoder))
    }
}
