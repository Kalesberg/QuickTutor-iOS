//
//  RoutingAndAccountModal.swift
//  QuickTutor
//
//  Created by Will Saults on 4/27/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class RoutingAndAccountModal: BaseModalXibView {
    
    @IBOutlet weak var routingIcon: RoundUIView!
    @IBOutlet weak var accountIcon: RoundUIView!
    
    @IBAction func tappedDone(_ sender: Any) {
        dismiss()
    }
    
    static var view: RoutingAndAccountModal {
        return Bundle.main.loadNibNamed(String(describing: RoutingAndAccountModal.self),
                                        owner: nil,
                                        options: [:])?.first as! RoutingAndAccountModal
    }
}

@IBDesignable
class RoundUIView: UIView {
    @IBInspectable var borderColor: UIColor = Colors.qtRed {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
