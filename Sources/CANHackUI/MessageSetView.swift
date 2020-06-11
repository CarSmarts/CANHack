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
    @ObservedObject public var document: MessageSetDocument
    @Binding public var decoder: CarDecoder
    
    var groupedByIdSub: AnyCancellable?
    
    public init(document: MessageSetDocument, decoder: Binding<CarDecoder>) {
        self.document = document
        self._decoder = decoder
        
        groupedByIdSub = document.$activeSignalSet.map(\.groupedById).subscribe(groupedSetSubject)
    }
    
    var groupedSetSubject = CurrentValueSubject<GroupedSignalSet<Message, MessageID>, Never>(SignalSet<Message>().groupedById)
    var groupedSet: GroupedSignalSet<Message, MessageID> {
        groupedSetSubject.value
    }

    public var body: some View {
        List(document.activeSignalSet.ids) { id in
            ZStack {
                MessageStatView(groupStats: self.groupedSet[id], decoder: self.$decoder[id], activeSignal: .constant(Mock.signalInstance))
                
                NavigationLink(destination: MessageDetailView(stats: self.groupedSet[id], decoder: self.$decoder[id]), label: { EmptyView() })

            }
        }
    }
}

struct MessageSetView_Previews: PreviewProvider {
    static var doc = { () -> MessageSetDocument in
        let doc = MessageSetDocument(fileURL: AppFolder.tmp.url.appendingPathComponent("test"))
        doc.activeSignalSet = Mock.testSet
        return doc
    }()
    
    static var previews: some View {
        MessageSetView(document: doc, decoder: .constant(Mock.decoder))
    }
}
