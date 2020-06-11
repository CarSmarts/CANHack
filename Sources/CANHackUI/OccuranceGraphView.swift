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

extension Comparable {
    func clamped(to min: Self, max: Self) -> Self {
        if self < min {
            return min
        } else if self > max {
            return max
        } else {
            return self
        }
    }
}

extension Collection {
    subscript(clamping idx: Index) -> Element {
        var lastPosible = endIndex
        formIndex(&lastPosible, offsetBy: -1)
        
        return self[idx.clamped(to: startIndex, max: lastPosible)]
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
    
    var data: GroupedStat<Message, MessageID>
    var scale: OccuranceGraphScale
    
    @Binding public var activeSignal: SignalInstance<Message>
    
    
    func findActiveSignal(in list: SignalList<Message>, target: Timestamp) -> SignalInstance<Message> {
        guard list.count > 0 else {
            return activeSignal
        }
        
        var fakeMessage = list.last!
        fakeMessage.timestamp = target

        let index = list.search(for: fakeMessage).index
        let upper = list[clamping: index]
        let lower = list[clamping: index - 1]
        
        if abs(upper.timestamp - target) < abs(lower.timestamp - target) {
            return upper
        } else {
            return lower
        }
    }
    
    func hitTest(location: CGPoint, size: CGSize) {
        let hoveredStatIndex = Int((location.y / size.height) * CGFloat(data.stats.count))
        
        let hoveredStatSignalList = data.stats[clamping: hoveredStatIndex].signalList
        
        guard let last = data.signalList.last?.timestamp,
            let first = data.signalList.first?.timestamp, first != last else {
                return
        }
        
        // compute target timestamp from xlocation
        let range = last - first
        let target = Int((location.x / size.width) * CGFloat(range)) + first
                
        // first search in our hovered StatIndex
        activeSignal = findActiveSignal(in: hoveredStatSignalList, target: target)
        
        let hypotheticalViewPosition = computeScrubOffset(width: size.width)
        
        // if we're more than five pixels away from our signal
        if abs(hypotheticalViewPosition - location.x) > 5.0 {
            // search again in all the signals
            activeSignal = findActiveSignal(in: data.signalList, target: target)
        }
    }
    
    private func computeScrubOffset(width: CGFloat) -> CGFloat {
        let range = scale.max - scale.min
        let target = activeSignal.timestamp
        let percent = CGFloat(target - scale.min) / CGFloat(range)
        
        return (width * percent).clamped(to: 0.0, max: width)
    }
    
    @State var offset: CGFloat = 0.0

    var body: some View {
        GeometryReader { geo in
            Color.clear.contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                    .onChanged({ value in
                        self.hitTest(location: value.location, size: geo.size)
                        
                        self.offset = self.computeScrubOffset(width: geo.size.width)
                    })
                )
            .overlay(
                Color.red
                .opacity(0.80)
                    .frame(width: 2.0, height: geo.size.height)
                    .offset(x: self.offset, y: 0.0),
                alignment: Alignment(horizontal: .leading, vertical: .center)
            )
        }
    }
}

struct OccuranceGraph: View {
    @ObservedObject var data: GroupedStat<Message, MessageID>
    public var scale: OccuranceGraphScale
    
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 27.0)
                    .background(
                        OccuranceGraphRow(occurances: signalStat.timestamps, scale: self.data.scale, colorChoice: AnyHashable(signalStat.signal))
                    )
                }
            }
            .compositingGroup()

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

struct OccuranceGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let groupedSet = Mock.groupedSet
        
        let goodExample = groupedSet.stats.first { stat in
            stat.stats.count > 1
        }
        
        let otherExample = groupedSet.stats[1]
        
        return Group {
            Unwrap(goodExample) {
                MessageStatView(groupStats: $0, decoder: .constant(Mock.decoder[$0.group]), activeSignal: .constant(Mock.signalInstance))
            }
            
            Unwrap(otherExample) {
                MessageStatView(groupStats: $0, decoder: .constant(Mock.decoder[$0.group]), activeSignal: .constant(Mock.signalInstance))
            }
        }.previewLayout(.fixed(width: 375, height: 170))
    }
}
