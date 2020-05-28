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

    public init(document: MessageSetDocument, decoder: Binding<CarDecoder>) {
        self.document = document
        self._decoder = decoder
    }
    
    public var body: some View {
        List(document.activeSignalSet.ids) { id in
            MessageStatView(groupStats: self.document.activeSignalSet.groupedById[id], decoder: self.$decoder)
        }
    }
}

struct MessageSetView_Previews: PreviewProvider {
    static var doc = { () -> MessageSetDocument in
        let doc = MessageSetDocument(fileURL: AppFolder.tmp.url.appendingPathComponent("test"))
        doc.activeSignalSet = Mock.mockTestSet
        return doc
    }()
    
    static var previews: some View {
        MessageSetView(document: doc, decoder: .constant(Mock.mockDecoder))
    }
}
