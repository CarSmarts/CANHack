//
//  MessageSetDocument.swift
//  CANHackUI
//
//  Created by Robert Smith on 5/26/20.
//

import UIKit
import CANHack

public class MessageSetDocument: UIDocument, ObservableObject {
    @Published public var activeSignalSet = SignalSet<Message>() {
        didSet {
//            super.updateChangeCount(.done)
        }
    }
    
    @Published public var loading = false
    
    func printState() {
        print("MessageSet: \(localizedName) ", terminator: "")
        if documentState.contains(.closed) {
            print("closed ")
        }
        if documentState.contains(.editingDisabled) {
            print("editingDisabled ")
        }
        if documentState.contains(.inConflict) {
            print("inConflict ")
        }
        if documentState.contains(.progressAvailable) {
            print("progressAvailable ")
        }
        if documentState.contains(.savingError) {
            print("savingError ")
        }
        if documentState.contains(.normal) {
            print("normal ")
        }
        print(documentState)
    }

    private var parser = GVRetParser()
    
    public override init(fileURL url: URL) {
            super.init(fileURL: url)
                        
            NotificationCenter.default.addObserver(forName: UIDocument.stateChangedNotification, object: self, queue: .main) { notification in
                self.printState()
            }
        }
    
        public class UnimplementedError: NSError {
            init() {
                super.init(domain: "CS", code: 2, userInfo: nil)
            }
            
            required init?(coder: NSCoder) {
                super.init(coder: coder)
            }
        }
    
        public class ParseError: NSError {
            init() {
                super.init(domain: "CS", code: 1, userInfo: nil)
            }
            
            required init?(coder: NSCoder) {
                super.init(coder: coder)
            }
        }
            
        public override func contents(forType typeName: String) throws -> Any {
            return Data()
        }
        
        public override func load(fromContents contents: Any, ofType typeName: String?) throws {
            guard let data = contents as? Data,
                let contents = String(data: data, encoding: .utf8)
            else {
                throw ParseError()
            }
            
            loading = true
            parser.parse(string: contents) { loadedSet in
                DispatchQueue.main.async {
                    self.loading = false
                    self.activeSignalSet = loadedSet
                }
            }
    }
}
