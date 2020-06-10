//
//  MessageDetailView.swift
//  CANHack
//
//  Created by Robert Smith on 6/9/20.
//

import SwiftUI
import CANHack

struct MessageDetailView: View {
    public init(stats: GroupedStat<Message, MessageID>, decoder: Binding<DecoderMessage>) {
        self.stats = stats
        self._decoder = decoder
        
        self.selection = Selection(numRows: 1, numColumns: 8)
        self.selection.signals = self.decoder.signals
        self.selection.numRows = self.message.contents.count
        
        // start at last position?
        self.scrubPosition = self.stats.signalList.count - 1
    }

    @ObservedObject public var stats: GroupedStat<Message, MessageID>
    
    @Binding var decoder: DecoderMessage {
        didSet {
            self.selection.signals = decoder.signals
        }
    }
        
    @ObservedObject private var selection: Selection
    
    @State var scrubPosition: Int = 0
    
    var message: Message {
        guard scrubPosition < stats.signalList.count else {
            print("signalAccess out of range")
            return Message(id: 0xAF81111, contents: Array(repeating: 0x00, count: selection.numRows))
        }
        
        return stats.signalList[scrubPosition].signal
    }
    
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
        VStack() {
            MessageStatView(groupStats: stats, decoder: self.$decoder)

            HStack {
                BinaryDataCellsView(message: self.message, decoder: self.$decoder, selection: self.selection)
                
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
