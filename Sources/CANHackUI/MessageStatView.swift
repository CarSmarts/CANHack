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
    func body(content: Content) -> some View {
        content.font(.system(.body, design: .monospaced))
    }
}

struct MessageIDView: View {
    public init(id: MessageID) {
        self.id = id
    }
    
    @EnvironmentObject public var model: CanBusModel
    public let id: MessageID
    
    var decoder: DecoderMessage {
        model.decoder[id]
    }
    
    enum EditingType {
        case none, name, sender
    }
    
    @State private var edititng: EditingType = .none
    @State private var nameScratch: String = ""
    @State private var senderScratch: String = ""

    func endEditing() {
        if edititng == .name {
            decoder.name = nameScratch
            nameScratch = ""
        } else if edititng == .sender {
            decoder.sendingNode = senderScratch
            senderScratch = ""
        }
        
        edititng = .none
    }
    
    func startNameEdit() {
        if edititng != .none {
            endEditing()
        }
        edititng = .name
        nameScratch = decoder.name
    }
    
    func startSenderEdit() {
        if edititng != .none {
            endEditing()
        }
        edititng = .sender
        senderScratch = decoder.sendingNode
    }

    
    var body: some View {
        HStack {
            Text(id.description)
                .font(.headline)
                .modifier(Monospaced())
            
            if (edititng == .name) {
                TextField("name", text: $nameScratch, onCommit: endEditing)
            } else {
                Text(decoder.name)
                .fontWeight(.light)
                .onTapGesture(perform: startNameEdit)
            }
            
            if (edititng == .sender) {
                TextField("Sender", text: $senderScratch, onCommit: endEditing)
            } else {
                Text("(" + decoder.sendingNode + ")")
                .fontWeight(.ultraLight)
                .onTapGesture(perform: startSenderEdit)

            }
        }
    }
}

struct MessageStatView: View {
    @EnvironmentObject public var model: CanBusModel
    @ObservedObject public var groupStats: GroupedStat<Message, MessageID>
    
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
        VStack(alignment: .leading, spacing: nil) {

            MessageIDView(id: groupStats.group)
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(shortList, id: \.signal) { signalStat in
                    ZStack(alignment: .leading) {
                        OccuranceGraphRow(occurances: signalStat.timestamps, scale: self.groupStats.scale, colorChoice: AnyHashable(signalStat.signal))

                        Text(signalStat.signal.contentDescription)
                        .modifier(Monospaced())
                            .padding(.leading)
                    }
                }
            }
            
            Group {
                if self.remander > 0 {
                    Text("+ \(self.remander) more")
                        .font(.footnote)
                        .fontWeight(.light)
                }
            }
        }
    }
}

struct MessageStatView_Previews: PreviewProvider {
    static var previews: some View {
        let groupedSet = Mock.mockGroupedSet
        
        let goodExample = groupedSet.stats.first { stat in
            stat.stats.count > 1
        }
        
        let testExample = groupedSet.stats.first { stat in
            stat.group == MessageID(rawValue: 0xAF81111)!
        }

        let longExample = groupedSet.stats.first { stat in
            stat.group == MessageID(rawValue: 0x12F85351)
        }
        
        return Group {
//            Unwrap(goodExample) {
//                MessageStatView(groupStats: $0)
//            }
            
            Unwrap(testExample) {
                MessageStatView(groupStats: $0)
            }
            
//            Unwrap(longExample) {
//                MessageStatView(groupStats: $0)
//            }
        }.previewLayout(.fixed(width: 375, height: 170))
            .environmentObject(Mock.mockModel)
    }
}
