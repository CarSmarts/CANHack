//
//  SignalGraph.swift
//  CANHackUI
//
//  Created by Robert Smith on 6/15/20.
//

import SwiftUI
import SmartCarUI
import CANHack

class DecodedSignal {
    internal init(instanceList: GroupedStat<Message, MessageID>, decoder: DecoderSignal) {
        self.instanceList = instanceList
        self.decoder = decoder
        
        data = instanceList.signalList.mapSignal { message in
            decoder.location.decodeRawValue(message.contents)
        }.map { pair in SimpleGraphPoint(value: pair.0, timestamp: pair.1) }
                   
        valueData = [:]
        
        for instance in instanceList.signalList {
            let message = instance.signal
            let string = decoder.decodeTabelValue(message) ?? message.contentDescription
            
            valueData[string, default: []].append(instance.timestamp)
        }
        
        sortedValueData = valueData.sorted { (lhs, rhs) in
            lhs.key < rhs.key
        }
    }
    
    var instanceList: GroupedStat<Message, MessageID>
    var decoder: DecoderSignal
    
    var yScale: GraphScale<UInt64> {
        let max = 0b1 << decoder.location.len // 2 ** len
        
        return GraphScale(min: 0, max: UInt64(max))
    }
        
    var data: [SimpleGraphPoint<UInt64>]
    var valueData: [String: [Timestamp]]
    var sortedValueData: [(String, [Timestamp])]
}

struct SignalGraph: View {
    public init(groupStats: GroupedStat<Message, MessageID>, decoder: Binding<DecoderSignal>) {
        self.groupStats = groupStats
        self._decoder = decoder
    }
    
    @ObservedObject public var groupStats: GroupedStat<Message, MessageID>
    @Binding public var decoder: DecoderSignal

    var decodedSignal: DecodedSignal {
        DecodedSignal(instanceList: groupStats, decoder: decoder)
    }
    
    var body: some View {
        Group {
            if decoder.location.len > 3 {
                SimpleGraphRow(points: decodedSignal.data, yScale: decodedSignal.yScale).frame(height: 37.0)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Enumerating(self.decodedSignal.sortedValueData) { pair, idx in
                        OccuranceGraphLabel(pair.0)
                            .background(
                                OccuranceGraphRow(occurances: pair.1)
                            .accentColor(.color(for: idx))
                        )
                    }
                }
                .compositingGroup()
            }
        }
    }
}

struct SignalGraph_Previews: PreviewProvider {
    static var previews: some View {
        let groupedSet = Mock.groupedSet
        
        let goodExample = groupedSet.stats.first { stat in
            stat.stats.count > 1
        }
                
        return Group {
            Unwrap(goodExample) {
                SignalGraph(groupStats: $0, decoder: .constant(DecoderSignal(location: .init(startBit: 0, len: 4))))
                .environmentObject($0.scale)
            }
        }
        .previewLayout(.fixed(width: 375, height: 170))
    }
}
