//
//  ValueTableView.swift
//  CANHack
//
//  Created by Robert Smith on 6/14/20.
//

import SwiftUI
import CANHack
import SmartCarUI

struct ValueTableRow: View {
    @Binding var decoderValue: DecoderValue
        
    var formatter: NumberFormatter {
        return NumberFormatter()
    }
    
    var body: some View {
        HStack {
            TextField("Value", value: $decoderValue.value, formatter: formatter).frame(width: 80)
            
            TextField("Label", text: $decoderValue.label)
        }.textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct ValueTableView: View {
    @Binding var valueTable: [DecoderValue]
    
    @State private var scratch = DecoderValue()
    
    var body: some View {
        VStack {
            VStack {
                Enumerating(valueTable) { _, idx in
                    HStack {
                        ValueTableRow(decoderValue: self.$valueTable[idx])
                        
                        Button(action: {
                            self.valueTable.remove(at: idx)
                        }) {
                            Image(systemName: "minus.square")
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    ValueTableRow(decoderValue: self.$scratch)
                    
                    Button(action: {
                        self.valueTable.append(self.scratch)
                        self.scratch = DecoderValue()
                    }) {
                        Image(systemName: "plus.square")
                    }
                }

            }
        }
    }
}

struct ValueTableView_Previews: PreviewProvider {
    
    struct ValueTableViewPreview: View {
        @State var table: [DecoderValue] = [DecoderValue(value: 20, label: "String")]
        
        var body: some View {
            ValueTableView(valueTable: $table).padding()
        }
    }
    
    static var previews: some View {
        ValueTableViewPreview()
    }
}
