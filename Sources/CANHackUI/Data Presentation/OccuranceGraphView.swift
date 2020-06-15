//
//  HistogramView.swift
//  SmartCar
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Combine
import SwiftUI
import CANHack
import SmartCarUI


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

struct OccuranceGraphRow: View {
    public var occurances: [Int]
    @EnvironmentObject var scale: GraphScale<Int>
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard self.scale.range > 0 else {
                    return
                }
                let min = self.scale.min
                let range = self.scale.range
                let minDifference = self.scale.minDifference

                var lastPosition: CGFloat = -100.0
                let height = geometry.size.height
                let width = geometry.size.width

                for occurance in self.occurances {
                    let position = CGFloat(occurance - min) / CGFloat(range) * width
                    
                    if (position - lastPosition) > minDifference {
                        path.move(to: CGPoint(x: position, y: 0))
                        path.addLine(to: CGPoint(x: position, y: height))
                        
                        lastPosition = position
                    }
                }
            }
            .stroke(Color.accentColor)
        }
    }
}

struct ScrubView: View {
    var data: GroupedStat<Message, MessageID>
    @EnvironmentObject var scale: GraphScale<Int>
    @Binding public var activeSignal: SignalInstance<Message>
    
    var snapToStat = true

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
        guard let last = data.signalList.last?.timestamp,
            let first = data.signalList.first?.timestamp, first != last else {
                return
        }

        // compute target timestamp from xlocation
        let range = last - first
        let target = Int((location.x / size.width) * CGFloat(range)) + first

        if snapToStat {
            // compute hoveredStat
            let hoveredStatIndex = Int((location.y / size.height) * CGFloat(data.stats.count))
            let hoveredStatSignalList = data.stats[clamping: hoveredStatIndex].signalList
                                
            // first search in our hovered StatIndex
            activeSignal = findActiveSignal(in: hoveredStatSignalList, target: target)
            
            let hypotheticalViewPosition = computeScrubOffset(width: size.width)
            
            // if we're more than five pixels away from our signal
            if abs(hypotheticalViewPosition - location.x) > 5.0 {
                // search again in all the signals
                activeSignal = findActiveSignal(in: data.signalList, target: target)
            }
        } else {
            activeSignal = findActiveSignal(in: data.signalList, target: target)
        }
    }
    
    private func computeScrubOffset(width: CGFloat) -> CGFloat {
        guard scale.range > 0 else {
            return 0.0
        }
        
        let target = activeSignal.timestamp
        let percent = CGFloat(target - scale.min) / CGFloat(scale.range)
        
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
                    })
                )
            .overlay(
                Color.red
                .opacity(0.80)
                    .frame(width: 2.0, height: geo.size.height)
                    .offset(x: self.computeScrubOffset(width: geo.size.width)),
                alignment: Alignment(horizontal: .leading, vertical: .center)
            )
        }
    }
}

struct OccuranceGraph: View {
    @ObservedObject var data: GroupedStat<Message, MessageID>
    
    var shortList: ArraySlice<SignalStat<Message>> {
        data.stats.prefix(10)
    }
    
    var remander: Int {
        data.stats.count - 10
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            VStack(alignment: .leading, spacing: 2) {
                Enumerating(self.shortList) { signalStat, idx in
                    Text(signalStat.signal.contentDescription)
                    .modifier(Monospaced())
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 27.0)
                    .background(
                        OccuranceGraphRow(occurances: signalStat.timestamps)
                            .accentColor(.color(for: idx))
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
                MessageStatView(groupStats: $0, decoder: .constant(Mock.decoder[$0.group]))
            }
            
            Unwrap(otherExample) {
                MessageStatView(groupStats: $0, decoder: .constant(Mock.decoder[$0.group]))
            }
        }.environmentObject(groupedSet.scale)
        .previewLayout(.fixed(width: 375, height: 170))
    }
}
