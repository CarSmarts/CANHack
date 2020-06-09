//
//  BinaryDataView.swift
//  CANHack
//
//  Created by Robert Smith on 5/28/20.
//

import SwiftUI
import CANHack
import SmartCarUI

public struct DigitCell: View {
    public var digit: Bool
    @ObservedObject var selection: Selection
    var index: Index
    
    func getSelectionColor(_ geo: GeometryProxy) -> Color {
        if geo.frame(in: .global) .contains(selection.selectionStartPoint) {
            selection.startIndex = index
        }
        if geo.frame(in: .global) .contains(selection.selectionEndPoint) {
            selection.endIndex = index
        }
        
        return selection.color(for: index)
    }
    
    public var body: some View {
        
        
        return GeometryReader { geo in
            ZStack {
                Text(self.digit ? "1" : "0")
                .modifier(Monospaced())
            }
            .frame(width: 30, height: 30, alignment: .center)
            .border(Color.black, width: 1)
            .background(self.getSelectionColor(geo))
        }
        .frame(width: 30, height: 30, alignment: .center)

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
            
            Text(byte.hex)
            .fontWeight(.light)
            .modifier(Monospaced())

        }
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
    internal init(numRows: Int, numColumns: Int, decoderSignals: Binding<[DecoderSignal]>) {
        self.numRows = numRows
        self.numColumns = numColumns
        self._signals = decoderSignals
    }
    
    @Binding var signals: [DecoderSignal]
    
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
    var startIndex: Index = Index(0, 0)
    var endIndex: Index = Index(0, 0)
    
    var selectedRange: ClosedRange<Index> {
        return min(startIndex, endIndex)...max(startIndex, endIndex)
    }
    
    var start: Int {
        return selectedRange.lowerBound.finalIndexPosition
    }

    var len: Int {
        return selectedRange.upperBound.finalIndexPosition - start
    }
    
    fileprivate func signalIntersects(_ signal: DecoderSignal, _ index: Index) -> Bool {
        return signal.location.range.contains(index.finalIndexPosition)
    }
    
    fileprivate func signalIntersects(_ signal: DecoderSignal, _ range: ClosedRange<Index>) -> Bool {
        let mappedRange = range.lowerBound.finalIndexPosition...range.upperBound.finalIndexPosition
        
        return signal.location.range.overlaps(mappedRange)
    }

    func color(for index: Index) -> Color {
        if activeDecoderSignal == nil && isSelected(index) {
            return Color.pink.opacity(0.75)
        }
        
        for (idx, signal) in signals.enumerated() {
            if signalIntersects(signal, index) {
                if isSelected(index) {
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
    
    @Published var selectionStartPoint: CGPoint = CGPoint(x: 0, y: 0)
    @Published var selectionEndPoint: CGPoint = CGPoint(x: 0, y: 0)

}

public struct BinaryDataView: View {
    public init(message: Message, decoder: Binding<DecoderMessage>) {
        self.message = message
        self._decoder = decoder
        
        let decoderSignals = decoder.signals
        
        self.selection = Selection(numRows: message.length, numColumns: 8, decoderSignals: decoderSignals)
    }
    
    @Binding var decoder: DecoderMessage
    
    var message: Message
    private var selection: Selection
    
    func hitTest(geoProxy: GeometryProxy, location: CGPoint) -> Index {
        let xPercent = location.x / geoProxy.size.width
        let yPercent = location.y / geoProxy.size.height
        
        let x = Int(CGFloat(selection.numColumns) * xPercent)
        let y = Int(CGFloat(selection.numRows) * yPercent)
        
        return Index(x, y)
    }
            
    fileprivate func commitSelection() {
        selection.isActive = false
        
        let startBit = selection.start
        let len = selection.len

        decoder.signals.append(DecoderSignal(name: "", location: .init(startBit: startBit, len: len), conversion: DecoderSignal.Conversion(), unit: "", recivingNode: ""))
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -0.5) {
                ForEach(Array(self.message.contents.enumerated()), id: \.0) { row in
                    BinaryDataRow(byte: row.element, rowIndex: row.offset, selection: self.selection)
                }
                .gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .global)
                    .onChanged({ value in
                        self.selection.isActive = true
                        self.selection.selectionStartPoint = value.startLocation
                        
                        self.selection.selectionEndPoint = value.location
                    }).onEnded({ value in
                        self.selection.objectWillChange.send()
                    }))
            }
            
            VStack(alignment: .center) {
                if !selection.isActive && selection.activeDecoderSignal == nil {
                    Button(action: {
                        self.commitSelection()
                    }) {
                        Image(systemName: "plus.square")
                    }.frame(width: 30.0, height: 30.0, alignment: .center)
                } else if selection.activeDecoderSignal != nil {
                    Button(action: {
                        self.decoder.signals.removeAll { decoderSignal in
                            decoderSignal == self.selection.activeDecoderSignal!
                        }
                    }) {
                        Image(systemName: "minus.square")
                    }.frame(width: 30.0, height: 30.0, alignment: .center)

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
        
        var decoderMessage = DecoderMessage(id: 0xAF81111, name: "Name", len: 0, sendingNode: "Node")
        
        decoderMessage.signals.append(DecoderSignal(name: "Some Signal", location: DecoderSignal.Location(startBit: 1, len: 3), conversion: DecoderSignal.Conversion(), unit: "unit", recivingNode: "Node2"))
        
        return BinaryDataView(message: message, decoder: .constant(decoderMessage)).previewLayout(.fixed(width: 375, height: 170))
    }
}
