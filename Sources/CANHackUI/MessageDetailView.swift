//
//  MessageDetailView.swift
//  CANHack
//
//  Created by Robert Smith on 6/9/20.
//

import SwiftUI
import SmartCarUI

import CANHack

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
    @State var activeSignal: SignalInstance<Message> = Mock.signalInstance
    
    fileprivate func eraseSignal() {
        let activeSignal = selection.activeDecoderSignal!
        selection.isActive = false

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
        
        return ScrollView {
            Group {
                Group {
                    MessageIDView(id: stats.group, decoder: $decoder, canEdit: true)
                        
                    OccuranceGraph(data: stats, scale: stats.scale)
                        .overlay(ScrubView(data: stats, scale: stats.scale, activeSignal: $activeSignal))

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
                }.layoutPriority(1.0)
                
                Enumerating(decoder.signals) { (signal, idx) in
                    DecoderSignalView(decoderSignal: self.$decoder.signals[idx], index: idx, highlightColor: self.selection.color(forSignal: idx))
                        .background(self.selection.activeDecoderSignal == signal ? Color.secondary.opacity(0.80) : Color.clear)
                        .onTapGesture {
                            self.selection.setActiveSignal(idx)
                    }
                }
                
                Spacer()
            }.padding()
        }
    }
}

struct MessageDetailView_Previews: PreviewProvider {
    struct MockView: View {
        @State var decoderMessage = Mock.decoderMessage
        
        var body: some View {
            MessageDetailView(stats: Mock.groupedSet[0x12F85351], decoder: $decoderMessage)
        }
    }
    
    static var previews: some View {
        MockView()
    }
}
