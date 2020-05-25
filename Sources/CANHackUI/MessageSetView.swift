//
//  MessageSetView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Combine
import SwiftUI
import CANHack

public struct MessageSetView: View {
    @ObservedObject public var messageSet: SignalSet<Message>
    
    public init(messageSet: SignalSet<Message>) {
        self.messageSet = messageSet
    }
    
    private var groupedMessages: GroupedSignalSet<Message, MessageID> {
        GroupedSignalSet(grouping: messageSet, by: { (stat) -> MessageID in
                stat.signal.id
            })
        }

    public var body: some View {
        List(groupedMessages.groups) { group in
            MessageStatView(groupStats: self.groupedMessages[group])
        }
    }
}

struct MessageSetView_Previews: PreviewProvider {
    static var previews: some View {
        MessageSetView(messageSet: Mock.mockTestSet)
    }
}
