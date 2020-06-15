//
//  SignalInstance.swift
//  SmartCar
//
//  Created by Robert Smith on 11/14/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import Combine

/// Super vague, but a `Signal` is anything that could be associated with "happening" at a certain time
public protocol Signal: Hashable, CustomStringConvertible, Comparable, Codable { }

/// When a `Signal` "happened"
public typealias Timestamp = Int

/// Ties a Signal to a specific Timestamp
public struct SignalInstance<S: Signal>: Hashable, Codable {
    public var signal: S
    public var timestamp: Timestamp

    public init(signal: S, timestamp: Timestamp) {
        self.signal = signal
        self.timestamp = timestamp
    }
}

extension SignalInstance: CustomStringConvertible {
    public var description: String {
        return "\(timestamp) \(signal)"
    }
}

/// List of SignalInstance sorted by timestamp
public class SignalList<S: Signal>: SortedArray<SignalInstance<S>> {
    public init(_ array: [Element] = []) {
        super.init(sorting: array) { $0.timestamp < $1.timestamp }
    }
}

/// Anything that has a list of signalInstances...
public protocol InstanceList {
    associatedtype S: Signal
    
    var signalList: SignalList<S> { get }
}

/// ...should also have a list of Timestamps
extension InstanceList {
    /// The first timestamp in this dataset
    public var firstTimestamp: Timestamp {
        return firstInstance?.timestamp ?? 0
    }
    
    /// The last timestamp in this dataset
    public var lastTimestamp: Timestamp {
        return lastInstance?.timestamp ?? 0
    }
    
    public var timestamps: [Timestamp] {
        return signalList.map { $0.timestamp }
    }
    
    public var firstInstance: SignalInstance<S>? {
        return signalList.first
    }

    public var lastInstance: SignalInstance<S>? {
        return signalList.last
    }
}

/// ...and a way to be notified of insertion
extension InstanceList {
    public var newInstancePublisher: PassthroughSubject<SignalInstance<S>, Never> {
        return signalList.insertPublisher
    }
}


