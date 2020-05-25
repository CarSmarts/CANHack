//
//  BinaryDataView.swift
//  SmartCar
//
//  Created by Robert Smith on 6/19/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import UIKit
import CANHack

class BinaryDataView: UIView {
    
    /// Shortcut to get labelStack.arrangedSubviews as a list of UILabels
    public var arrangedLabels: [UILabel] {
        return labelStack.arrangedSubviews as! [UILabel]
    }
    
    var data: [Byte]! {
        didSet {
            // TODO: Profile this performace check
            guard data != oldValue else { return }
            
            
            // Make sure we have enough labels
            for _ in arrangedLabels.count..<data.count {
                labelStack.addArrangedSubview(UILabel())
            }
            assert(arrangedLabels.count >= data.count)
            
            for (label, data) in zip(arrangedLabels, data) {
                label.text = data.hex + " " + data.bin
            }
            
            // Hide any extra labels
            for label in arrangedLabels[data.count...] {
                label.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var labelStack: UIStackView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
