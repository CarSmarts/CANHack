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

extension SortedArray {
    private func _find(closest element: Element, lowerIndex: Int, upperIndex: Int) -> Int {
        guard (lowerIndex <= upperIndex) else {
            return lowerIndex
        }
        
        let middleIndex = (lowerIndex + upperIndex) / 2
        if self[middleIndex] == element {
            return middleIndex
        } else if predicate(self[middleIndex], element) {
            return _find(closest: element, lowerIndex: middleIndex + 1, upperIndex: upperIndex)
        } else {
            return _find(closest: element, lowerIndex: lowerIndex, upperIndex: upperIndex - 1)
        }
    }
    
    func find(closest element: Element) -> Int {
        var idx =  _find(closest: element, lowerIndex: 0, upperIndex: count - 1)
        
        if idx > count {
            idx = count - 1
        }
        
        return idx
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

struct ScrubView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.red
                    .opacity(0.80)
                    .frame(width: 2.0, height: geo.size.height, alignment: .center)
            }
        }
    }
}

struct OccuranceGraph: View {
    @ObservedObject var data: GroupedStat<Message, MessageID>
    public var scale: OccuranceGraphScale
    
    @Binding public var activeSignal: SignalInstance<Message>
    
    @State private var activeIndex: Int = 0 {
        didSet {
            if activeIndex < 0 {
                activeIndex = 0
            }
            if activeIndex > data.signalList.count {
                activeIndex = data.signalList.count - 1
            }
            activeSignal = data.signalList[activeIndex]
        }
    }
    @State private var lastActiveIndex: Int = 0

    func hitTest(xpos: CGFloat, width: CGFloat) {
        let last = data.lastTimestamp
        let first = data.firstTimestamp
        
        guard last != 0, first != 0, first != last else {
            return
        }
        
        let range = last - first
        let target = Int((width - xpos) * CGFloat(range)) + first
        
        var fakeMessage = data.lastInstance!
        fakeMessage.timestamp = target
        
        let closestIdx = data.signalList.find(closest: fakeMessage)
        activeSignal = data.signalList[closestIdx]
        
        print("Scrub to:", closestIdx)
    }
    
    var shortList: ArraySlice<SignalStat<Message>> {
        data.stats.prefix(10)
    }
    
    var remander: Int {
        data.stats.count - 10
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(self.shortList, id: \.signal) { signalStat in
                    Text(signalStat.signal.contentDescription)
                    .modifier(Monospaced())
                    .padding(.leading)
                    .frame(maxWidth: .infinity, minHeight: 13.0, maxHeight: 30.0, alignment: .leading)
                    .background(                            OccuranceGraphRow(occurances: signalStat.timestamps, scale: self.data.scale, colorChoice: AnyHashable(signalStat.signal))
                    )
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                .onChanged({ value in
                    let offset = Int(value.translation.width / 10.0)
                    self.activeIndex = self.lastActiveIndex + offset
                })
                .onEnded({ _ in
                    self.lastActiveIndex = self.activeIndex
                })
            )
            .overlay(ScrubView(), alignment: .center)

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
                MessageStatView(groupStats: $0, decoder: .constant(Mock.mockDecoder[$0.group]))
            }
            
            Unwrap(otherExample) {
                MessageStatView(groupStats: $0, decoder: .constant(Mock.mockDecoder[$0.group]))
            }
        }.previewLayout(.fixed(width: 375, height: 170))
    }
}
