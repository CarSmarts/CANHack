//
//  MessageDetailView.swift
//  CANHack
//
//  Created by Robert Smith on 6/9/20.
//

import SwiftUI
import CANHack

struct DecoderSignalView: View {
    @Binding var decoderSignal: DecoderSignal
    let index: Int
    
    var body: some View {
        return Text("Decoder Signal")
    }
}

struct MessageDetailView: View {
    public init(stats: GroupedStat<Message, MessageID>, decoder: Binding<DecoderMessage>) {
        self.stats = stats
        self._decoder = decoder
                
        self.selection = Selection(numRows: 1, numColumns: 8)
        self.selection.signals = self.decoder.signals
        
        if let first = stats.firstInstance {
            self.activeSignal = first
            self.selection.numRows = first.signal.contents.count
        }
    }

    @ObservedObject public var stats: GroupedStat<Message, MessageID>
    
    @Binding var decoder: DecoderMessage {
        didSet {
            self.selection.signals = decoder.signals
        }
    }
        
    @ObservedObject private var selection: Selection
    @State var activeSignal: SignalInstance<Message> = Mock.mockSignalInstance
    
    fileprivate func eraseSignal() {
        selection.isActive = false

        let activeSignal = selection.activeDecoderSignal!
        
        decoder.signals.removeAll { decoderSignal in
            decoderSignal == activeSignal
        }
    }
    
    fileprivate func createSignal() {
        selection.isActive = false
        
        let startBit = selection.start
        let len = selection.len

        decoder.signals.append(DecoderSignal(name: "", location: .init(startBit: startBit, len: len), conversion: DecoderSignal.Conversion(), unit: "", recivingNode: ""))
    }
    
    public var body: some View {
        let stats = self.stats
        
        return VStack {
            MessageIDView(id: stats.group, decoder: $decoder)
                
            OccuranceGraph(data: stats, scale: stats.scale)
                .overlay(ScrubView(data: stats.signalList, scale: stats.scale, activeSignal: $activeSignal))

            HStack {
                BinaryDataCellsView(message: activeSignal.signal, decoder: self.$decoder, selection: self.selection)
                
                VStack(alignment: .center) {
                    if selection.activeDecoderSignal == nil {
                        Button(action: self.createSignal) {
                            Image(systemName: "plus.square")
                        }
                        .disabled(!selection.isActive)
                    } else {
                        Button(action: self.eraseSignal) {
                            Image(systemName: "minus.square")
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            Spacer()
        }
        .padding()
    }
}

struct MessageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailView(stats: Mock.mockGroupedSet[0x12F85351], decoder: Mock.$mockDecoderMessage)
    }
}
