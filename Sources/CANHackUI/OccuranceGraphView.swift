//
//  HistogramView.swift
//  SmartCar
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit
import SwiftUI
import CANHack
import SmartCarUI

/// Allow Any InstanceList to be graphed
extension InstanceList {
    public var scale: OccuranceGraphScale {
        return OccuranceGraphScale(min: firstTimestamp, max: lastTimestamp)
    }
}

public struct OccuranceGraphScale {
    public var minDifference: CGFloat = 0.75
    
    public var min: Int
    public var max: Int
    public var count: Int = 1 {
        didSet {
            if count > 10 {
                count = 10
            }
        }
    }
}

struct OccuranceGraphRow: View {
    public var occurances: [Int]
    public var scale: OccuranceGraphScale

    private let colors = [
        Color.blue,
        Color.green,
        Color.purple,
        Color.red,
        Color.orange,
    ]
    
    var color: Color {
        let hash = Int(colorChoice.hashValue.magnitude)
        
        return colors[hash % colors.count]
    }
    
    public var colorChoice: AnyHashable = AnyHashable(0)
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let scale = self.scale
                
                var lastPosition: CGFloat = 0.0
                let height = geometry.size.height
                let width = geometry.size.width

                for occurance in self.occurances {
                    let position = CGFloat(occurance - scale.min) / CGFloat(scale.max - scale.min) * width
                    
                    if (position - lastPosition) > scale.minDifference {
                        path.move(to: CGPoint(x: position, y: 0))
                        path.addLine(to: CGPoint(x: position, y: height))
                        
                        lastPosition = position
                    }
                }
            }
            .stroke(self.color)
        }
    }
}

struct OccuranceGraph: View {
    @ObservedObject var data: GroupedStat<Message, MessageID>
    public var scale: OccuranceGraphScale
        
    var body: some View {
        VStack {
            ForEach(data.stats, id: \.signal) { signalStat in
                OccuranceGraphRow(occurances: signalStat.timestamps, scale: self.scale)
            }
        }
    }
}

//extension GroupedSignalSet {
//    public var scale: OccuranceGraphScale {
//        var scale = _signalSet.scale
//        scale.count = groups.count
//        return scale
//    }
//}

struct OccuranceGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let groupedSet = Mock.mockGroupedSet
        
        let goodExample = groupedSet.stats.first { stat in
            stat.stats.count > 1
        }
        
        let otherExample = groupedSet.stats[1]
        
        return Group {
            Unwrap(goodExample) {
                MessageStatView(groupStats: $0, decoder: .constant(Mock.mockDecoder))
            }
            
            Unwrap(otherExample) {
                MessageStatView(groupStats: $0, decoder: .constant(Mock.mockDecoder))
            }
        }.previewLayout(.fixed(width: 375, height: 170))
    }
}
