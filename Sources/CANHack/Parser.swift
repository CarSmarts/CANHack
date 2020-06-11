//
//  Parser.swift
//  SmartCar
//
//  Created by Robert Smith on 6/17/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import Foundation

extension Collection where Index == Int {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

public protocol Parser {
    associatedtype S: Signal
    
    /// Main important function
    func parse(line: String) -> SignalInstance<S>?
}

public class ParseOperation<P: Parser>: Operation {
    let parser: P
    let lines: [String]
    var result: [SignalInstance<P.S>]?

    public init(parser: P, lines: [String]) {
        self.parser = parser
        self.lines = lines
    }
    
    public override func main() {
        guard !isCancelled else {
            return
        }
        
        result = lines.compactMap { line -> SignalInstance<P.S>? in
            return parser.parse(line: line)
        }
    }
}

public extension Parser {
    func getParseOperation(for lines: [String]) -> ParseOperation<Self> {
        ParseOperation(parser: self, lines: lines)
    }
    
    func parse(string: String) -> SignalSet<S> {
        let maxLoad = 500_000

        let lines = string.components(separatedBy: .newlines).prefix(maxLoad)

        // map every line into a parsed message
        let parsed = lines.compactMap { line -> SignalInstance<S>? in
            return parse(line: line)
        }
        
        return SignalSet<S>(signalInstances: parsed)
    }
    
    func parse(url: URL, queue: OperationQueue, callback: @escaping (SignalSet<S>) -> Void) throws {
        let maxLoad = 1_000_000

        let string = try String(contentsOf: url, encoding: .utf8)
        
        let lines = string.components(separatedBy: .newlines).prefix(maxLoad)
        let batchSize = lines.count / 6
        
        let operations = lines.chunked(by: batchSize).map { self.getParseOperation(for: $0) }
                   
        queue.addOperations(operations, waitUntilFinished: true)
        
        let instances = operations.compactMap { $0.result }.flatMap { $0 }
        
        let buildSet = SignalSet<S>(signalInstances: instances)
        
        callback(buildSet)
    }
}
