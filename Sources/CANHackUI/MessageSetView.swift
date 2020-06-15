//
//  MessageSetView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Combine
import SwiftUI
import CANHack
import AppFolder

public struct MessageSetView: View {
    public init(document: MessageSetDocument, decoder: Binding<CarDecoder>) {
        self.document = document
        self._decoder = decoder
    }
    
    @ObservedObject public var document: MessageSetDocument
    @Binding public var decoder: CarDecoder
    
    public var body: some View {
        GroupedByIdView(groupedSet: document.groupedById, decoder: $decoder)
    }
}

public struct GroupedByIdView: View {
    @ObservedObject public var groupedSet: GroupedSignalSet<Message, MessageID>
    @Binding public var decoder: CarDecoder
    
    @State var scale = OccuranceGraphScale(min: 0, max: 10)

    public init(groupedSet: GroupedSignalSet<Message, MessageID>, decoder: Binding<CarDecoder>) {
        self.groupedSet = groupedSet
        self._decoder = decoder
    }
    
    var scaleUpdatePublisher: AnyPublisher<OccuranceGraphScale, Never> {
        groupedSet.newInstancePublisher.map { _ in () }
        .prepend(())
        .map {
            self.groupedSet.scale
        }.eraseToAnyPublisher()
    }
    
    public var body: some View {
        List(groupedSet.groups) { id in
            ZStack {
                MessageStatView(groupStats: self.groupedSet[id], decoder: self.$decoder[id], activeSignal: .constant(Mock.signalInstance), scale: self.$scale)
                
                NavigationLink(destination: MessageDetailView(stats: self.groupedSet[id], decoder: self.$decoder[id]), label: { EmptyView() })
            }
        }.onReceive(scaleUpdatePublisher) { scale in
            self.scale = scale
        }
    }
}

struct MessageSetView_Previews: PreviewProvider {
    static var doc = MockMessageSetDocument()
        
    static var previews: some View {
        MessageSetView(document: doc, decoder: .constant(Mock.decoder))
    }
}
