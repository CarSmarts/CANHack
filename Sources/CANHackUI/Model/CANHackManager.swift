//
//  CANHackManager.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

#if canImport(UIKit)
import SwiftUI
import Combine
import CANHack
import AppFolder

public class CANHackManager: ObservableObject {
    public var decoderBinding: Binding<CarDecoder> {
        return Binding(get: {
            self.decoderDocument.decoder
        }) { (newValue) in
            self.decoderDocument.decoder = newValue
        }
    }
        
    public private(set) var decoderDocument: CarDecoderDocument!
    public private(set) var messageSetDocument: MessageSetDocument?
    
    lazy public private(set) var scratch: MessageSetDocument = {
        return MessageSetDocument(fileURL: AppFolder.Documents.url.appendingPathComponent("scratch.csv"))
    }()

    public func openMessageSet(at url: URL) {
        messageSetDocument = MessageSetDocument(fileURL: url)
        messageSetDocument!.open(completionHandler: { _ in
            self.objectWillChange.send()
        })
    }
        
    public init() {
        let url = AppFolder.Documents.url.appendingPathComponent("mainDecoder.json")
        decoderDocument = CarDecoderDocument(fileURL: url)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            decoderDocument.save(to: url, for: .forCreating, completionHandler: nil)
        } else {
            decoderDocument.open(completionHandler: { _ in
                self.objectWillChange.send()
            })
        }
    }
}

#endif
