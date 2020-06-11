//
//  DecoderSignalView.swift
//  CANHack
//
//  Created by Robert Smith on 6/10/20.
//

import SwiftUI

import CANHack

public extension View {
    func flipEffect(_ flipped: Bool) -> some View {
        return modifier(_ScaleEffect(transform: flipped ? -1.0 : 1.0))
    }
}

struct _ScaleEffect: GeometryEffect {
    var transform: CGFloat
    
    var animatableData: CGFloat {
        get { transform }
        set { transform = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = -size.height * (transform - 1) / 2
        
        return ProjectionTransform(CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: transform, tx: 0.0, ty: offset))
    }
}

struct ConversionView: View {
    @Binding var conversion: DecoderSignal.Conversion
    @State var expanded: Bool = false
    
    var body: some View {
        return VStack(alignment: .leading) {
            HStack {
                Text("Conversion").font(.headline)
                Spacer()
                Button(action: {
                    withAnimation {
                        self.expanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .flipEffect(expanded)

                }.buttonStyle(BorderlessButtonStyle())
            }
            if expanded {
                VStack {
                    Stepper(value: $conversion.factor, step: 0.01) {
                        Text("Factor: \(conversion.factor, specifier: "%.2f")")
                    }
                    Stepper(value: $conversion.offset, step: 1) {
                        Text("Offset: \(conversion.offset)")
                    }
                    HStack {
                        Stepper(value: $conversion.min, step: 1) {
                            Text("min: \(conversion.min)")
                        }
                        Stepper(value: $conversion.max, step: 1) {
                            Text("max: \(conversion.max)")
                        }
                    }
                    }.transition(AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity))
            }
        }
    }
}

struct DecoderSignalView: View {
    @Binding var decoderSignal: DecoderSignal
    let index: Int
    let highlightColor: Color
    
    var body: some View {
        VStack {
            HStack {
                Text("\(decoderSignal.location.startBit): \(decoderSignal.location.len)")
                    .padding(5.0)
                    .background(highlightColor.clipShape(RoundedRectangle(cornerRadius: 7.0)))
                
                TextField("Name", text: $decoderSignal.name)
                TextField("Reciver", text: $decoderSignal.recivingNode)
            }
            
            ConversionView(conversion: $decoderSignal.conversion)
        }.padding()
    }
}

struct DecoderSignalView_Previews: PreviewProvider {
    struct MockView: View {
        @State var decoderSignal = DecoderSignal(name: "", location: .init(startBit: 0, len: 3), conversion: .init(factor: 0, offset: 0, min: 0, max: 0), unit: "unit", recivingNode: "someNode")
        
        var body: some View {
            DecoderSignalView(decoderSignal: $decoderSignal, index: 0, highlightColor: .blue)
        }
    }
    
    static var previews: some View {
        MockView().previewLayout(.fixed(width: 375, height: 170))
    }
}
