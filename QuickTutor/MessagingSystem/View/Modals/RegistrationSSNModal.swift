//
//  RegistrationSSNModal.swift
//  QuickTutor
//
//  Created by Will Saults on 4/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class RegistrationSSNModal: BaseModalXibView {
    
    @IBOutlet weak var trustLabel1: UILabel!
    @IBOutlet weak var trustLabel2: UILabel!
    @IBOutlet weak var trustLabel3: UILabel!
    @IBAction func tappedDone(_ sender: Any) {
        dismiss()
    }

    static var view: RegistrationSSNModal {
        return Bundle.main.loadNibNamed(String(describing: RegistrationSSNModal.self), owner: nil,
                                        options: [:])?.first as! RegistrationSSNModal
    }
    
    override func commonInit() {
        super.commonInit()
        
        setParagraphStyle(label: trustLabel1)
        setParagraphStyle(label: trustLabel2)
        setParagraphStyle(label: trustLabel3)
    }
    
    func setParagraphStyle(label: UILabel?) {
        let attributedString = NSMutableAttributedString(string: label?.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label?.attributedText = attributedString
    }
}
