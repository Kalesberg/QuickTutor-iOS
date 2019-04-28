//
//  BankInfoModal.swift
//  QuickTutor
//
//  Created by Will Saults on 4/27/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class BankInfoModal: BaseModalXibView {
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBAction func tappedDone(_ sender: Any) {
        dismiss()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        firstLabel?.text = "We’ll need your bank account information in order to \ndirectly deposit your tutoring earnings into your \nbank account."
        
        secondLabel?.text = "QuickTutor is partnered with Stripe, which handles \nbillions of dollars every year for forward-thinking \nbusinesses around the world."
    }
    
    static var view: BankInfoModal {
        return Bundle.main.loadNibNamed(String(describing: BankInfoModal.self),
                                        owner: nil,
                                        options: [:])?.first as! BankInfoModal
    }
}
