//
//  CarDecoderDocument.swift
//  CANHack
//
//  Created by Robert Smith on 5/26/20.
//

import UIKit
import SwiftUI
import CANHack

public class CarDecoderDocument: UIDocument, ObservableObject {
    private var jsonDecoder = JSONDecoder()
    private var jsonEncoder = JSONEncoder()
    
    func printState() {
        print("CarDecoder: ", terminator: "")
        if documentState.contains(.closed) {
            print("closed ", terminator: "")
        }
        if documentState.contains(.editingDisabled) {
            print("editingDisabled ", terminator: "")
        }
        if documentState.contains(.inConflict) {
            print("inConflict ", terminator: "")
        }
        if documentState.contains(.progressAvailable) {
            print("progressAvailable ", terminator: "")
        }
        if documentState.contains(.savingError) {
            print("savingError ", terminator: "")
        }
        if documentState.contains(.normal) {
            print("normal ", terminator: "")
        }
        print()
        print(documentState)
    }
    
    public override init(fileURL url: URL) {
        super.init(fileURL: url)
        
        self.jsonEncoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]
        
        NotificationCenter.default.addObserver(forName: UIDocument.stateChangedNotification, object: self, queue: .main) { notification in
            self.printState()
        }
    }

    @Published(initialValue: CarDecoder([])) public var decoder {
        didSet {
            super.updateChangeCount(.done)
        }
    }
    
//    public override var fileType: String? {
//        return "public.json"
//    }
        
    public override func contents(forType typeName: String) throws -> Any {
        return try jsonEncoder.encode(decoder)
    }
    
    public override func load(fromContents contents: Any, ofType typeName: String?) throws {
        decoder = try jsonDecoder.decode(CarDecoder.self, from: contents as! Data)
    }
}
