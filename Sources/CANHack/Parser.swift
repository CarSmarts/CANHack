//
//  Parser.swift
//  SmartCar
//
//  Created by Robert Smith on 6/17/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import Foundation

public protocol Parser {
    associatedtype S: Signal
    
    /// Main important function
    func parse(line: String) -> SignalInstance<S>?
}

public extension Parser {
    func parse(string: String) -> SignalSet<S> {
        let maxLoad = 500_000

        let lines = string.components(separatedBy: .newlines).prefix(maxLoad)

        // map every line into a parsed message
        let parsed = lines.compactMap { line -> SignalInstance<S>? in
            return parse(line: line)
        }
        
        return SignalSet<S>(signalInstances: parsed)
    }
    
    func parse(string: String, callback: @escaping (SignalSet<S>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let maxLoad = 500_000

            let lines = string.components(separatedBy: .newlines).prefix(maxLoad)
        
            let parsed = lines.compactMap { line -> SignalInstance<S>? in
                return self.parse(line: line)
            }
            
            let buildSet = SignalSet<S>(signalInstances: parsed)
            
            callback(buildSet)
        }
    }
}
