//
//  SimpleGraphView.swift
//  CANHack
//
//  Created by Robert Smith on 6/15/20.
//

import SwiftUI
import SmartCarUI
import CANHack

public typealias SimpleGraphValueType = FixedWidthInteger

public struct SimpleGraphPoint<Value: SimpleGraphValueType> {
    public var value: Value
    public var timestamp: Timestamp
}

struct SimpleGraphRow<Value: SimpleGraphValueType>: View {
    public var points: [SimpleGraphPoint<Value>]
    public var yScale = GraphScale(min: Value.zero, max: Value.max)
    
    @EnvironmentObject private var xScale: GraphScale<Int>

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard self.xScale.range > 0 else {
                    return
                }
                
                let xMin = self.xScale.min
                let xRange = self.xScale.range
                let yMin = self.yScale.min
                let yRange = self.yScale.range

                func xPosition(for timestamp: Int) -> CGFloat {
                    CGFloat(timestamp - xMin) / CGFloat(xRange)
                }
                
                func yPosition(for value: Value) -> CGFloat {
                    1.0 - CGFloat(value - yMin) / CGFloat(yRange)
                }
                
                var lastPosition: CGFloat = 0.0
                let height = geometry.size.height
                let width = geometry.size.width

                guard let first = self.points.first else { return }
                let xposition = xPosition(for: first.timestamp) * width
                let yposition = yPosition(for: first.value) * height
                
                path.move(to: CGPoint(x: xposition, y: yposition))

                for point in self.points {
                    let xposition = xPosition(for: point.timestamp) * width
                    let yposition = yPosition(for: point.value) * height
                    
                    if (xposition - lastPosition) > 5.0 {
                        path.move(to: CGPoint(x: xposition, y: yposition))
                    } else {
                        path.addLine(to: CGPoint(x: xposition, y: yposition))
                    }
                    
                    lastPosition = xposition
                }
            }
            .stroke(Color.accentColor)
            .compositingGroup()
        }
    }
}

extension Array {
    subscript(if idx: Int) -> Element? {
        if idx >= 0 && idx < count {
            return self[idx]
        } else {
            return nil
        }
    }
}

extension InstanceList where S == Message {
    var byteValuesList: [[(Byte, Timestamp)]] {
        guard let count = self.signalList.first?.signal.contents.count else { return [] }
        
        return (0..<count).map { self.getByteValues(at: $0) }
    }
    
    func getByteValues(at idx: Int) -> [(Byte, Timestamp)] {
        signalList.compactMap { instance in
            guard let value = instance.signal.contents[if: idx] else { return nil }
            
            return (value, instance.timestamp)
        }
    }
}

struct ByteRowData {
    init(_ data: [(Byte, Timestamp)]) {
        self.points = data.map { SimpleGraphPoint(value: $0.0, timestamp: $0.1) }
            
        var uniqueBytes: [Byte: [Timestamp]] = [:]
        
        for point in data {
            uniqueBytes[point.0, default: []].append(point.1)
        }
        
        self.uniqueBytes = uniqueBytes
    }
    
    let uniqueBytes: [Byte: [Timestamp]]
    
    let points: [SimpleGraphPoint<Byte>]
}

struct ByteGraphRow: View {
    let data: ByteRowData
    let colorChoice: Int
    
    /// Because `uniqueBytes` returns a Dictionary, its sort order is unstable..
    /// Sort it before showing it to the user
    private var sortedUniqueBytes: [Dictionary<Byte, [Timestamp]>.Element] {
        data.uniqueBytes.sorted(by: { (pair1, pair2) in
            pair1.key < pair2.key
        })
    }
    
    var body: some View {
        Group {
            if data.uniqueBytes.count > 3 {
                SimpleGraphRow(points: data.points)
            } else {
                Enumerating(sortedUniqueBytes) { pair, idx in
                    Text(pair.0.hex)
                    .modifier(Monospaced())
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 27.0)
                    .background(
                        OccuranceGraphRow(occurances: pair.1)
                            .accentColor(.color(for: idx))
                    )
                }
            }
        }
    }
}

struct SimpleGraphView: View {
    @ObservedObject var groupedStats: GroupedStat<Message, MessageID>
    
    var body: some View {
        VStack {
            Enumerating(groupedStats.byteValuesList) { data, idx in
                Group {
                    ByteGraphRow(data: ByteRowData(data), colorChoice: idx).frame(height: 30.0)
                }
            }
        }
    }
}

struct SimpleGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let groupedSet = Mock.groupedSet
        
        let goodExample = groupedSet.stats.first { stat in
            stat.stats.count > 1
        }
                
        return Group {
            Unwrap(goodExample) { example in
                VStack {
                    MessageIDView(id: example.group, decoder: .constant(Mock.decoderMessage))
                    
                    SimpleGraphView(groupedStats: example)
                }
            }
        }.environmentObject(groupedSet.scale)
    }
}
