//
//  GroupedSignalSet.swift
//  SmartCar
//
//  Created by Robert Smith on 11/15/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import Combine

public typealias GroupingID = Signal

/// A stat representing all stats in a collection with a matching feature
public class GroupedStat<S: Signal, G: GroupingID>: InstanceList, ObservableObject {
    public let group: G
    public private(set) var stats: AppendArray<SignalStat<S>>
    public private(set) var signalList: SignalList<S>
    
    var statSubs: [AnyCancellable] = []
    
    fileprivate init(_ group: G, stats: [SignalStat<S>] = []) {
        self.group = group
        self.stats = AppendArray(stats)
        
        self.signalList = SignalList(stats.flatMap { stat in
            stat.signalList
        })
    
        // Side effect, observe each stat so we can update
        statSubs = stats.map { (stat) in
            stat.newInstancePublisher.sink { (_, newInstance) in
                self.signalList.insert(newInstance)
                self.objectWillChange.send()
            }
        }
    }
    
    fileprivate func add(newStat: SignalStat<S>) {
        self.stats.append(newStat)
        for instance in newStat.signalList {
            self.signalList.insert(instance)
        }
        
        newStat.newInstancePublisher.sink { (_, newInstance) in
            self.signalList.insert(newInstance)
            self.objectWillChange.send()
        }.store(in: &statSubs)
        
        self.objectWillChange.send()
    }
}

/// A set of messages, collected for the purpose of analysis, grouped by a specifc identify
public class GroupedSignalSet<S: Signal, G: GroupingID>: InstanceList, ObservableObject {
    private var _signalSet: SignalSet<S>
    private var _stats: [G: GroupedStat<S, G>]
    private var _groupingFunction: (SignalStat<S>) -> G

    /// Sorted list of groups in this set
    public private(set) var groups: SortedArray<G>

    /// The original list of signals
    public var signalList: SignalList<S> {
        return _signalSet.signalList
    }
    
    var newStatSub: AnyCancellable?
    var newInstanceSub: AnyCancellable?

    /// Creates a GroupedSignalSet by grouping an existing SignalSet
    public init(grouping original: SignalSet<S>, by groupingFunction: @escaping (SignalStat<S>) -> G) {
        _signalSet = original
        _groupingFunction = groupingFunction
        
        let grouped = Dictionary(grouping: original.stats, by: groupingFunction)
        
        _stats = Dictionary(uniqueKeysWithValues: grouped.map {
            let (group, stats) = $0
            return (group, GroupedStat(group, stats: stats))
        })
        
        groups = SortedArray(sorting: Array(_stats.keys))
        
        newStatSub = original.newStatPublisher.sink { newSignalStat in
            
            let newGroup = groupingFunction(newSignalStat)
            
            if self._stats[newGroup] == nil {
                // need to create a new group
                self._stats[newGroup] = GroupedStat(newGroup, stats: [newSignalStat])
                
                self.groups.insert(newGroup)
                self.objectWillChange.send()
            } else {
                self._stats[newGroup]!.add(newStat: newSignalStat)
            }
        }
    }
}

/// SignalStat getters
extension GroupedSignalSet {
    /// Access a grouped stat for a specific group
    ///
    /// - traps if `group` is not part of this classes `groups` array
    public subscript (_ group: G) -> GroupedStat<S, G> {
        return _stats[group]!
    }
    
    /// All the stats in a Collection
    public var stats: LazyMapCollection<SortedArray<G>, GroupedStat<S, G>> {
        return groups.lazy.map { self[$0] }
    }
}

// FIXME:
//extension GroupedSignalSet: CustomStringConvertible {
//    public var description: String {
//        return stats.map { $0.description }.joined(separator: "\n")
//    }
//}
