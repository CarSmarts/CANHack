//
//  BinaryDataView.swift
//  CANHack
//
//  Created by Robert Smith on 5/28/20.
//

import SwiftUI
import CANHack
import SmartCarUI

extension CoordinateSpace {
    static var dataView: CoordinateSpace {
        let key: String = "dataView"
        
        return .named(key)
    }
}

struct Index: Comparable {
    static func < (lhs: Index, rhs: Index) -> Bool {
        if lhs.row == rhs.row {
            return lhs.column < rhs.column
        } else {
            return lhs.row < rhs.row
        }
    }
    
    internal init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
    
    var finalIndexPosition: Int {
        return column + row * 8
    }

    
    var row: Int
    var column: Int
}

extension DecoderSignal.Location {
    var range: ClosedRange<Int> {
        startBit...startBit+len
    }
}

class Selection: ObservableObject {
    internal init(numRows: Int, numColumns: Int) {
        self.numRows = numRows
        self.numColumns = numColumns
    }
        
    @Published var signals: [DecoderSignal] = []

    let colors = [
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
    
    var colorChoice: AnyHashable = AnyHashable(0)
    
    var numRows: Int
    var numColumns: Int
    @Published var startIndex: Index = Index(0, 0)
    @Published var endIndex: Index = Index(0, 0)
    
    var selectedRange: ClosedRange<Index> {
        return min(startIndex, endIndex)...max(startIndex, endIndex)
    }
    
    var start: Int {
        return selectedRange.lowerBound.finalIndexPosition
    }

    var len: Int {
        return selectedRange.upperBound.finalIndexPosition - start
    }
    
    private func signalIntersects(_ signal: DecoderSignal, _ index: Index) -> Bool {
        return signal.location.range.contains(index.finalIndexPosition)
    }
    
    private func signalIntersects(_ signal: DecoderSignal, _ range: ClosedRange<Index>) -> Bool {
        let mappedRange = range.lowerBound.finalIndexPosition...range.upperBound.finalIndexPosition
        
        return signal.location.range.overlaps(mappedRange)
    }

    func color(for index: Index) -> Color {
        if activeDecoderSignal == nil && isSelected(index) {
            return Color.pink.opacity(0.75)
        }
        
        for (idx, signal) in signals.enumerated() {
            if signalIntersects(signal, index) {
                if let activeDecoderSignal = activeDecoderSignal, activeDecoderSignal == signal {
                    return colors[idx % colors.count].opacity(0.90)
                } else {
                    return colors[idx % colors.count].opacity(0.75)
                }
            }
        }
        
        return .clear
    }
    
    @Published var isActive = false
        
    func isSelected(_ index: Index) -> Bool {
        return isActive && selectedRange.contains(index)
    }
    
    var activeDecoderSignal: DecoderSignal? {
        signals.first(where: { signalIntersects($0, selectedRange)})
    }
}


public struct DigitCell: View {
    public var digit: Bool
    @ObservedObject var selection: Selection
    var index: Index
    
    var selectionColor: Color {
        return selection.color(for: index)
    }
    
    public var body: some View {
        ZStack {
            Text(self.digit ? "1" : "0")
            .modifier(Monospaced())
        }
        .frame(width: 30, height: 30, alignment: .center)
        .border(Color.black, width: 1)
        .background(selectionColor)
    }
}

public struct BinaryDataRow: View {
    var byte: Byte
    var rowIndex: Int
    @ObservedObject var selection: Selection
    
    var reversedBits: [(Int, Bool)] {
        Array(byte.bits.enumerated()).reversed()
    }
    
    public var body: some View {
        HStack {
            HStack(alignment: .lastTextBaseline, spacing: -0.5) {
                ForEach(self.reversedBits, id: \.0) { row in
                    return DigitCell(digit: row.1, selection: self.selection, index: Index(self.rowIndex, row.0))
                }
            }
        }
    }
}

public struct BinaryDataCellsView: View {
    var message: Message
    @Binding var decoder: DecoderMessage
    @ObservedObject var selection: Selection

    func hitTest(geoProxy: GeometryProxy, location: CGPoint) -> Index {

        let xPercent = location.x / geoProxy.size.width
        let yPercent = location.y / geoProxy.size.height
        
        let row = Int(CGFloat(selection.numRows) * yPercent)
        let col = Int(CGFloat(selection.numColumns) * (1 - xPercent))
        
        return Index(row, col)
    }
    
    public var body: some View {
        HStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: -0.5) {
                    ForEach(Array(self.message.contents.enumerated()), id: \.0) { row in
                        HStack {
                            BinaryDataRow(byte: row.element, rowIndex: row.offset, selection: self.selection)
                            
                            Text(row.element.hex)
                            .fontWeight(.light)
                            .modifier(Monospaced())
                        }

                    }
                }
                .gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .dataView)
                .onChanged({ value in
                    self.selection.isActive = true
                    self.selection.startIndex = self.hitTest(geoProxy: geo, location: value.startLocation)
                    self.selection.endIndex = self.hitTest(geoProxy: geo, location: value.location)
                }))
            }.frame(width: 30 * 8, height: 30.0 * CGFloat(self.message.contents.count), alignment: .topLeading)
            
            VStack(alignment: .leading, spacing: -0.5) {
                ForEach(Array(self.message.contents.enumerated()), id: \.0) { row in
                        Text(row.element.hex)
                        .fontWeight(.light)
                        .modifier(Monospaced())
                        .frame(width: nil, height: 30.0, alignment: .center)
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

struct BinaryDataView_Previews: PreviewProvider {
    static var previews: some View {
        let groupedSet = Mock.mockGroupedSet
        
        let example = groupedSet.stats.first { stat in
            stat.group == 0x12F85250
        }!
        
        let message = example.lastInstance!.signal
        
        return BinaryDataCellsView(message: message, decoder: Mock.$mockDecoderMessage, selection: .init(numRows: 3, numColumns: 8)).previewLayout(.fixed(width: 400, height: 170))
    }
}
