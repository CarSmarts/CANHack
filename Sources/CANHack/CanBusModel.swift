//
//  CanBusModel.swift
//  CANHack
//
//  Created by Robert Smith on 5/25/20.
//

import Foundation

public class CanBusModel: ObservableObject {
    public init(signalSet: SignalSet<Message>, decoder: CarDecoder = CarDecoder([])) {
        self.decoder = decoder
        self.signalSet = signalSet
    }
    
    public var decoder: CarDecoder
    
    public var signalSet: SignalSet<Message>
    
    public var ids: SortedArray<MessageID> {
        groupedById.groups
    }
    
    public var groupedById: GroupedSignalSet<Message, MessageID> {
        GroupedSignalSet(grouping: signalSet, by: { (stat) -> MessageID in
            stat.signal.id
        })
    }
}
