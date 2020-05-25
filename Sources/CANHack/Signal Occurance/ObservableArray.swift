//
//  ObservableArray.swift
//  SmartCar
//
//  Created by Robert Smith on 6/27/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import Foundation

public class AppendArray<Element>: ObservableArrayBase<Element> {
    private var appendObservers: [(Element) -> Void] = []
    public func append(_ newElement: Element) {
        array.append(newElement)
        appendObservers.forEach { $0(newElement) }
    }
    public func onAppend(_ observer: @escaping (Element) -> Void) {
        appendObservers.append(observer)
    }
}

public class SortedArray<Element: Equatable>: ObservableArrayBase<Element> {
    private let predicate: (Element, Element) -> Bool
    
    public init(sorting array: [Element] = [], predicate: @escaping (Element, Element) -> Bool) {
        self.predicate = predicate
        super.init(array)
        
        self.array.sort(by: predicate)
    }
    
    private var insertObservers: [(Element, Int) -> Void] = []
    public func insert(_ newElement: Element) {
        let newIndex = search(for: newElement).index
        
        array.insert(newElement, at: newIndex)
        insertObservers.forEach { $0(newElement, newIndex) }
    }
    public func onInsert(_ observer: @escaping (Element, Int) -> Void) {
        insertObservers.append(observer)
    }
}

extension SortedArray where Element: Comparable {
    public convenience init(sorting array: [Element]) {
        self.init(sorting: array, predicate: <)
    }
}

/// Binary Search
extension SortedArray {
    public func search(for element: Element) -> (found: Bool, index: Int) {
        // check if we just need to append to the end
        if let last = array.last, predicate(last, element) {
            return (false, array.endIndex)
        }
        
        return _search(for: element, lowerIndex: 0, upperIndex: count - 1)
    }
    
    private func _search(for element: Element, lowerIndex: Int, upperIndex: Int) -> (found: Bool, index: Int) {
        guard (lowerIndex <= upperIndex) else {
            return (false, lowerIndex) // ??
        }
        
        let middleIndex = (lowerIndex + upperIndex) / 2
        if self[middleIndex] == element {
            return (true, middleIndex)
        } else if predicate(self[middleIndex], element) {
            return _search(for: element, lowerIndex: middleIndex + 1, upperIndex: upperIndex)
        } else {
            return _search(for: element, lowerIndex: lowerIndex, upperIndex: upperIndex - 1)
        }
    }
}

/// Array wrapper that allows someone to observe changes to values in the array
public class ObservableArrayBase<Element> {
    public fileprivate(set) var array: [Element]
    
    public init(_ array: [Element] = []) {
        self.array = array
    }
}

/// Make ObservableArrayBase a RandomAccessCollection
extension ObservableArrayBase: RandomAccessCollection {
    public typealias Index = Array<Element>.Index
    public typealias Indices = Array<Element>.Indices
    public typealias SubSequence = Array<Element>.SubSequence
    public typealias Iterator = Array<Element>.Iterator

    public func index(before i: Array<Element>.Index) -> Array<Element>.Index {
        return array.index(before: i)
    }
    
    public func index(after i: Array<Element>.Index) -> Array<Element>.Index {
        return array.index(after: i)
    }
    
    public subscript(position: Array<Element>.Index) -> Element {
        return array[position]
    }
    
    public var startIndex: Array<Element>.Index {
        return array.startIndex
    }
    
    public var endIndex: Array<Element>.Index {
        return array.endIndex
    }
    
    public var indices: Array<Element>.Indices {
        return array.indices
    }
    
    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return array.makeIterator()
    }
    
    public func dropFirst(_ n: Int) -> ArraySlice<Element> {
        return array.dropFirst()
    }
    
    public func dropLast(_ n: Int) -> ArraySlice<Element> {
        return array.dropLast()
    }
    
    public func drop(while predicate: (Element) throws -> Bool) rethrows -> ArraySlice<Element> {
        return try array.drop(while: predicate)
    }
    
    public func prefix(_ maxLength: Int) -> ArraySlice<Element> {
        return array.prefix(maxLength)
    }
    
    public func prefix(while predicate: (Element) throws -> Bool) rethrows -> ArraySlice<Element> {
        return try array.prefix(while: predicate)
    }
    
    public func suffix(_ maxLength: Int) -> ArraySlice<Element> {
        return array.suffix(maxLength)
    }
    
    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [ArraySlice<Element>] {
        return try array.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
    }

}

