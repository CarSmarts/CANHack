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
                Spacer()
                Text(decoder.sendingNode)
                    .frame(width: 70.0)
                    .font(.subheadline)
            }
        }
    }
}
