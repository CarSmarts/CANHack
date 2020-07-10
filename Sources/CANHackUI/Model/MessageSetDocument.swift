//
//  MessageSetDocument.swift
//  CANHackUI
//
//  Created by Robert Smith on 5/26/20.
//

#if canImport(UIKit)
import UIKit
import CANHack

public class MessageSetDocument: UIDocument, ObservableObject {
    @Published public var signalSet = SignalSet<Message>() {
        didSet {
//            super.updateChangeCount(.done)
            self.groupedById = signalSet.groupedById
        }
    }
    
    public private(set) lazy var groupedById = {
        signalSet.groupedById
    }()
        
    func printState() {
        print("MessageSet: \(localizedName) ", terminator: "")
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
    }

    private var parser = GVRetParser()
    private var parsingQueue: OperationQueue

    public override init(fileURL url: URL) {
        parsingQueue = OperationQueue()
        parsingQueue.qualityOfService = .userInitiated
        
        super.init(fileURL: url)
                    
        NotificationCenter.default.addObserver(forName: UIDocument.stateChangedNotification, object: self, queue: .main) { notification in
            self.printState()
        }
    }
            
    public override func contents(forType typeName: String) throws -> Any {
        return Data()
    }
    
    public override func read(from url: URL) throws {
        let string = try String(contentsOf: url, encoding: .utf8)

        parsingQueue.addOperation {
            let loadedSet = self.parser.parse(from: string, queue: self.parsingQueue)

            DispatchQueue.main.async {
                self.signalSet = loadedSet
            }
        }
    }
    
//    public override func read(from url: URL) throws {
//        loading = true
//        do {
//            let string = try String(contentsOf: url, encoding: .utf8)
//
//            let loadedSet = parser.parse(from: string, queue: parsingQueue)
//            DispatchQueue.main.async {
//                self.loading = false
//                self.signalSet = loadedSet
//            }
//        }
//    }
}

#endif
