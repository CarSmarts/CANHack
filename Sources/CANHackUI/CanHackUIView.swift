//
//  CanHackUIView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import Combine
import CANHack
import SmartCarUI

public struct CanHackUIView: View {
    @EnvironmentObject private var manager: CANHackManager
    @EnvironmentObject private var picker: PickerObject

    public init() { }
    
    public var body: some View {
        NavigationView {
            Group {
                Unwrap(manager.messageSetDocument) { (doc) in
                    MessageSetView(document: doc, decoder: self.manager.decoderBinding)
                }
            }
            .navigationBarTitle(manager.messageSetDocument?.localizedName ?? "CANHack")
            .navigationBarItems(trailing: Button(
                action: {
                    self.picker.isPresented = true
                },
                label: { Text("Choose File") }
            ))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CanHackUIView_Previews: PreviewProvider {
    static var previews: some View {
        CanHackUIView()
    }
}
