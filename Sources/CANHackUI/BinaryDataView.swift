//
//  BinaryDataView.swift
//  CANHack
//
//  Created by Robert Smith on 5/28/20.
//

import SwiftUI
import CANHack
import SmartCarUI

struct Index: Comparable {
    internal init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
    
    var row: Int
    var column: Int
    
    var finalIndexPosition: Int {
        return column + row * 8
    }
    
    static func < (lhs: Index, rhs: Index) -> Bool {
        lhs.finalIndexPosition < rhs.finalIndexPosition
    }
}

extension DecoderSignal.Location {
    var range: ClosedRange<Int> {
        startBit...startBit+len-1
    }
}

extension Color {
    static func color(for idx: Int) -> Color {
        let colors = [
            Color.blue,
            Color.green,
            Color.purple,
            Color.red,
            Color.orange,
        ]
        
        return colors[idx % colors.count]
    }
}

struct Selection {
    var startIndex = Index(0, 0)
    var endIndex = Index(0, 0)
    
    var isActive = false

    func isSelected(_ index: Index) -> Bool {
        return isActive && selectedRange.contains(index)
    }
    
    var signals: [DecoderSignal] = []

    var focusedSignalIdx: Int?
    var focusedDecoderSignal: DecoderSignal? {
        guard let activeIdx = focusedSignalIdx else {
            return nil
        }
        
        return signals[activeIdx]
    }
        
    var location: DecoderSignal.Location {
        let start = selectedRange.lowerBound.finalIndexPosition
        let len = selectedRange.upperBound.finalIndexPosition - start + 1
            
        return .init(startBit: start, len: len)
    }
    
    var selectedRange: ClosedRange<Index> {
        return min(startIndex, endIndex)...max(startIndex, endIndex)
    }
    
    func signal(at index: Index) -> (Int, DecoderSignal)? {
        signals.enumerated().first { pair in
            pair.element.location.range.contains(index.finalIndexPosition)
        }
    }
    
    func color(for index: Index) -> Color {
        if isSelected(index) {
            return Color.pink.opacity(0.75)
        }

        if let (idx, _) = signal(at: index) {
            if idx == focusedSignalIdx {
                return Color.color(for: idx).opacity(0.90)
            } else {
                return Color.color(for: idx).opacity(0.75)
            }
        }
                
        return .clear
    }
    
}


public struct DigitCell: View {
    public var digit: Bool
    var selection: Selection
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
    var selection: Selection
    
    var reversedBits: [(Int, Bool)] {
        Array(byte.bits.enumerated()).reversed()
    }
    
    public var body: some View {
        HStack {
            HStack(alignment: .lastTextBaseline, spacing: -0.5) {
                ForEach(self.reversedBits, id: \.0) { row in
                    DigitCell(digit: row.1, selection: self.selection, index: Index(self.rowIndex, row.0))
                        .padding(.leading, (row.0 % 4 == 3) ? 5.0: 0.0)
                }
            }
        }
    }
}

public struct BinaryDataCellsView: View {
    var message: Message
    @Binding var decoder: DecoderMessage
    @Binding var selection: Selection

    func hitTest(geoProxy: GeometryProxy, location: CGPoint) -> Index {
        let numRows = message.contents.count
        let numColumns = 8

        let xPercent = location.x / geoProxy.size.width
        let yPercent = location.y / geoProxy.size.height
        
        let row = Int(CGFloat(numRows) * yPercent)
        let col = Int(CGFloat(numColumns) * (1 - xPercent))
        
        return Index(row, col)
    }
    
    func handleDrag(_ value: DragGesture.Value, geoProxy: GeometryProxy) {
        let startIndex = hitTest(geoProxy: geoProxy, location: value.startLocation)
        
        if let (idx, _) = selection.signal(at: startIndex) {
            selection.isActive = false
            selection.focusedSignalIdx = idx
        } else {
            selection.isActive = true
            selection.focusedSignalIdx = nil
            selection.startIndex = startIndex
            selection.endIndex = hitTest(geoProxy: geoProxy, location: value.location)
        }
    }
    
    public var body: some View {
        HStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: -0.5) {
                    ForEach(Array(self.message.contents.enumerated()), id: \.0) { row in
                        HStack(alignment: .lastTextBaseline) {
                            BinaryDataRow(byte: row.element, rowIndex: row.offset, selection: self.selection)
                            
                            Text(row.element.hex)
                            .fontWeight(.light)
                            .modifier(Monospaced())
                        }
                        .padding(.bottom, 5.0)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0.0)
                        .onChanged { self.handleDrag($0, geoProxy: geo) }
                )
            }
            .frame(width: 30 * 8 + 5.0, height: 35.0 * CGFloat(self.message.contents.count), alignment: .topLeading)
            
            VStack(alignment: .leading, spacing: -0.5) {
                Enumerating(self.message.contents) { (message, _) in
                    Text(message.hex)
                        .fontWeight(.light)
                        .modifier(Monospaced())
                        .frame(height: 30.0)
                        .padding(.bottom, 5.0)

                }
            }
        }
    }
}

struct BinaryDataView_Previews: PreviewProvider {
    struct BinaryDataPreview: View {
        
        @State var decoderMessage = Mock.decoderMessage
        
        var message: Message
        @State var selection = Selection()
        
        var body: some View {
            BinaryDataCellsView(message: message, decoder: $decoderMessage, selection: $selection)
        }
    }
    
    static var previews: some View {
        let groupedSet = Mock.groupedSet
        
        let example = groupedSet.stats.first { stat in
            stat.group == 0x12F85250
        }!
        
        let message = example.lastInstance!.signal

        return BinaryDataPreview(message: message).previewLayout(.fixed(width: 400, height: 170))
    }
}
