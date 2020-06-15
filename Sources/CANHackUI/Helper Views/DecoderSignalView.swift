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
        return modifier(_VerticalScaleEffect(transform: flipped ? -1.0 : 1.0))
    }
}

struct _VerticalScaleEffect: GeometryEffect {
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

struct ExpandingView<Content: View>: View {
    @State private var expanded: Bool = false

    public init(_ name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
    }
    
    private let name: String
    private let content: Content

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    withAnimation {
                        self.expanded.toggle()
                    }
                }) {
                    Text(name).font(.headline).accentColor(.primary)
                    Spacer()

                    Image(systemName: "chevron.down")
                        .flipEffect(expanded)

                }.buttonStyle(BorderlessButtonStyle())
            }
            if expanded {
                content.transition(AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity))
            }
        }
    }
}

struct ConversionView: View {
    @Binding var conversion: DecoderSignal.Conversion
    
    private var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        
        return formatter
    }
    
    private var intFormater: NumberFormatter {
        let formatter = NumberFormatter()
        
        return formatter
    }

    
    var body: some View {
        VStack {
            
            Stepper(value: $conversion.factor, step: 0.01) {
                Text("Factor:")
                
                TextField("Factor", value: $conversion.factor, formatter: doubleFormatter)
            }
            
            Stepper(value: $conversion.offset, step: 1) {
                Text("Factor:")
                
                TextField("Offset", value: $conversion.offset, formatter: intFormater)
            }
            
            HStack {
                Text("Min: ")
                TextField("Min", value: $conversion.min, formatter: doubleFormatter)
            
                Text("Max: ")
                TextField("Max", value: $conversion.max, formatter: doubleFormatter)
            }
        }
    }
}

struct DecoderSignalView: View {
    internal init(decoderSignal: Binding<DecoderSignal>, selected: Binding<Bool> = .constant(false), index: Int) {
        self._decoderSignal = decoderSignal
        self._selected = selected
        
        self.index = index
    }
    
    @Binding var decoderSignal: DecoderSignal
    @Binding var selected: Bool
    let index: Int
    
    var summaryView: some View {
        let rectangle = RoundedRectangle(cornerRadius: 7.0, style: .continuous)
        
        let selectionOverlay = rectangle.stroke(lineWidth: selected ? 3.0 : 0.0)
        
        return Text("\(decoderSignal.location.startBit): \(decoderSignal.location.len)")
        .padding(9.0)
            .background(Color.accentColor.clipShape(rectangle))
        .overlay(selectionOverlay)
        .onTapGesture {
            self.selected.toggle()
        }
    }

    var body: some View {
        VStack {
            HStack {
                summaryView
                
                TextField("Name", text: $decoderSignal.name)
                TextField("Reciver", text: $decoderSignal.recivingNode)
            }
            
            ExpandingView("Conversion") {
                ConversionView(conversion: $decoderSignal.conversion)
            }
            
            ExpandingView("Value table") {
                ValueTableView(valueTable: $decoderSignal.valueTable)
            }
        }.padding()
    }
}

struct DecoderSignalView_Previews: PreviewProvider {
    struct MockView: View {
        @State var selected: Bool = false
        @State var decoderSignal = DecoderSignal(name: "", location: .init(startBit: 0, len: 3), conversion: .init(factor: 0, offset: 0, min: 0, max: 0), unit: "unit", recivingNode: "someNode")
        
        var body: some View {
            DecoderSignalView(decoderSignal: $decoderSignal, selected: $selected, index: 0)
        }
    }
    
    static var previews: some View {
        MockView().previewLayout(.fixed(width: 375, height: 170))
    }
}
