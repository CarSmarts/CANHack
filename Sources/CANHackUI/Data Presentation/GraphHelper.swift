//
//  GraphHelper.swift
//  CANHackUI
//
//  Created by Robert Smith on 6/15/20.
//

import SwiftUI
import Combine
import CANHack

struct AdaptiveGraphView: View {
    @ObservedObject public var groupStats: GroupedStat<Message, MessageID>

    var body: some View {
        Group {
            if groupStats.stats.count > 10 {
                SimpleGraphView(groupedStats: self.groupStats)
            } else {
                OccuranceGraph(data: self.groupStats)
            }
        }
    }
}

public class GraphScale<Value: BinaryInteger>: ObservableObject {
    var sub: AnyCancellable?
    
    internal init(min: Value, max: Value) {
        self.min = min
        self.max = max
    }
    
    @Published public var minDifference: CGFloat = 0.75
    
    public var range: Value {
        return max - min
    }
    
    @Published public var min: Value
    @Published public var max: Value
}

public extension GraphScale where Value == Int {
    convenience init<T: InstanceList>(list: T) {
        self.init(min: list.firstTimestamp, max: list.lastTimestamp)
        
        sub = list.newInstancePublisher.map { list, _ in
            (list.firstTimestamp, list.lastTimestamp)
        }.sink { (first, last) in
            self.min = first
            self.max = last
        }
    }
}

/// Allow Any InstanceList to be graphed
extension InstanceList {
    public var scale: GraphScale<Int> {
        return GraphScale(list: self)
    }
}
