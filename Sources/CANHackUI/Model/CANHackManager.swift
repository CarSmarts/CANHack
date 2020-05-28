//
//  CANHackManager.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import Combine
import CANHack
import SmartCarUI
import AppFolder

public class CANHackManager: ObservableObject {
    public private(set) var picker: PickerObject
        
    public var decoderBinding: Binding<CarDecoder> {
        return Binding(get: {
            self.decoderDocument.decoder
        }) { (newValue) in
            self.decoderDocument.decoder = newValue
        }
    }
    
    public var activeMessageSet: Binding<SignalSet<Message>?> {
        return Binding(get: {
            self.messageSetDocument?.activeSignalSet
        }) { (newValue) in
            if let newValue = newValue, let doc = self.messageSetDocument {
                doc.activeSignalSet = newValue
            }
        }
    }
    
    public private(set) var decoderDocument: CarDecoderDocument!
    public private(set) var messageSetDocument: MessageSetDocument?
    
    lazy public private(set) var scratch: MessageSetDocument = {
        return MessageSetDocument(fileURL: AppFolder.Documents.url.appendingPathComponent("scratch.csv"))
    }()

    private func openMessageSet(at url: URL) {
        messageSetDocument = MessageSetDocument(fileURL: url)
        messageSetDocument!.open(completionHandler: { _ in
            self.objectWillChange.send()
        })
    }
        
    public init(rootVC: UIViewController) {
        self.picker = PickerObject(rootVC: rootVC)
        
        let url = AppFolder.Documents.url.appendingPathComponent("mainDecoder.json")
        decoderDocument = CarDecoderDocument(fileURL: url)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            decoderDocument.save(to: url, for: .forCreating, completionHandler: nil)
        } else {
            decoderDocument.open(completionHandler: { _ in
                self.objectWillChange.send()
            })
        }
        
        picker.didPickDocument = { url in
//            if let document = self.messageSetDocument, document.documentState != .closed {
//                document.close(completionHandler: { _ in self.openMessageSet(at: url) })
//            } else {
                self.openMessageSet(at: url)
//            }
        }
    }
}
