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
    }
    
    var instanceList: GroupedStat<Message, MessageID>
    var decoder: DecoderSignal
    
    var yScale: GraphScale<UInt64> {
        let max = 0b1 << decoder.location.len // 2 ** len
        
        return GraphScale(min: 0, max: UInt64(max))
    }
        
    var data: [SimpleGraphPoint<UInt64>]
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
        SimpleGraphRow(points: decodedSignal.data, yScale: decodedSignal.yScale)
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
