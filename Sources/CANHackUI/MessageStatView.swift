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

struct MessageStatView: View {
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
            Text(groupStats.group.description)
                .font(.headline)
                .modifier(Monospaced())

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

        let longExample = groupedSet.stats.first { stat in
            stat.group == MessageID(rawValue: 0x12F85351)
        }
        
        return Group {
            Unwrap(goodExample) {
                MessageStatView(groupStats: $0)
            }
            
            Unwrap(longExample) {
                MessageStatView(groupStats: $0)
            }
        }.previewLayout(.fixed(width: 375, height: 170))
    }
}
