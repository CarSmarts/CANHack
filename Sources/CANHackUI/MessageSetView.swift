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
    @ObservedObject public var model: CanBusModel

    public init(model: CanBusModel) {
        self.model = model
    }
    
    public var body: some View {
        List(model.ids) { id in
            MessageStatView(groupStats: self.model.groupedById[id])
        }
        .environmentObject(model)
    }
}

struct MessageSetView_Previews: PreviewProvider {
    static var previews: some View {
        MessageSetView(model: Mock.mockModel)
    }
}
