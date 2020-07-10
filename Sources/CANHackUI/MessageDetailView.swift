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
    @ObservedObject public var stats: GroupedStat<Message, MessageID>
    
    @Binding var decoder: DecoderMessage {
        didSet {
            self.selection.signals = decoder.signals
        }
    }
        
    @State private var selection = Selection()
    @State var activeSignal: SignalInstance<Message> = Mock.signalInstance
    
    fileprivate func eraseSignal() {
        selection.isActive = false
        decoder.signals.remove(at: selection.focusedSignalIdx!)
        selection.focusedSignalIdx = nil
    }
    
    fileprivate func createSignal() {
        selection.isActive = false
        selection.focusedSignalIdx = decoder.signals.count
        decoder.signals.append(DecoderSignal(location: selection.location))
    }
    
    private func selectionBinding(for idx: Int) -> Binding<Bool> {
        return Binding(get: {
            self.selection.focusedSignalIdx == idx
        }) { (selected) in
            self.selection.isActive = false
            self.selection.focusedSignalIdx = selected ? idx : nil
        }
    }
    
    public var body: some View {
        let stats = self.stats
        
        return ScrollView {
            Group {
                VStack {
                    MessageIDView(id: stats.group, decoder: $decoder, canEdit: true)
                        
                    AdaptiveGraphView(groupStats: stats)
                        .overlay(ScrubView(data: stats, activeSignal: $activeSignal))
                    
                }.padding()

                HStack {
                    BinaryDataCellsView(message: activeSignal.signal, decoder: self.$decoder, selection: self.$selection)
                    
                    VStack(alignment: .center) {
                        if selection.focusedSignalIdx == nil {
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
                VStack {
                    SignalGraph(groupStats: stats, decoder: self.$decoder.signals[idx])
                        .overlay(ScrubView(data: stats, activeSignal: self.$activeSignal, snapToStat: false))

                    DecoderSignalView(decoderSignal: self.$decoder.signals[idx], selected: self.selectionBinding(for: idx), index: idx)
                }.accentColor(.color(for: idx))
            }
            
            Spacer()
        }
        .environmentObject(stats.scale)
        .onAppear {
            if let first = stats.firstInstance {
                self.activeSignal = first
            }
            self.selection.signals = self.decoder.signals
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
