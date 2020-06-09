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
    public init(id: MessageID, decoder: Binding<DecoderMessage>, expanded: Binding<Bool>) {
        self.id = id
        self._decoder = decoder
        self._expanded = expanded
    }
    
    public var id: MessageID
    @Binding var decoder: DecoderMessage
    @Binding var expanded: Bool
    
    var body: some View {
        HStack {
            Text(id.description)
                .modifier(Monospaced(style: .headline))
                .layoutPriority(10.0)
            
            TextField("name", text: $decoder.name)
                .font(.subheadline)
            
            TextField("sender", text: $decoder.sendingNode)
                .font(.subheadline)
            
            Button(action: {
                self.expanded.toggle()
            }) {
            if expanded {
                Image(systemName: "chevron.up")
            } else {
                Image(systemName: "chevron.down")
                }
            }
//            .padding(5.0)
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct MessageStatView: View {
    @ObservedObject public var groupStats: GroupedStat<Message, MessageID>
    @Binding public var decoder: CarDecoder
    @State private var expanded: Bool = false

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

            MessageIDView(id: groupStats.group, decoder: $decoder[groupStats.group], expanded: $expanded)
                
            NavigationLink(destination: MessageDetailView(stats: groupStats, decoder: $decoder[groupStats.group]), label: { EmptyView() })
            
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(shortList, id: \.signal) { signalStat in
                        ZStack(alignment: .leading) {
                            OccuranceGraphRow(occurances: signalStat.timestamps, scale: self.groupStats.scale, colorChoice: AnyHashable(signalStat.signal))

                            Text(signalStat.signal.contentDescription)
                            .modifier(Monospaced())
                                .padding(.leading)
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
