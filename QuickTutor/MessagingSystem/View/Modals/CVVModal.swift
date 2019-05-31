//
//  CVVModal.swift
//  QuickTutor
//
//  Created by Will Saults on 5/29/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class CVVModal: BaseModalXibView {

    @IBOutlet weak var cvvLabel: UILabel!
    
    override func commonInit() {
        super.commonInit()
        
        setParagraphStyle(label: cvvLabel)
    }
    
    @IBAction func tappedDone(_ sender: Any) {
        dismiss()
    }
    
    static var view: CVVModal {
        return Bundle.main.loadNibNamed(String(describing: CVVModal.self),
                                        owner: nil,
                                        options: [:])?.first as! CVVModal
    }
}
