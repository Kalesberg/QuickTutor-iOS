//
//  ExpirationDateModal.swift
//  QuickTutor
//
//  Created by Will Saults on 5/28/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class ExpirationDateModal: BaseModalXibView {
    
    @IBOutlet weak var expirationDateLabel: UILabel!

    override func commonInit() {
        super.commonInit()
        
        setParagraphStyle(label: expirationDateLabel)
    }
    
    @IBAction func tappedDone(_ sender: Any) {
        dismiss()
    }
    
    static var view: ExpirationDateModal {
        return Bundle.main.loadNibNamed(String(describing: ExpirationDateModal.self),
                                        owner: nil,
                                        options: [:])?.first as! ExpirationDateModal
    }
}
