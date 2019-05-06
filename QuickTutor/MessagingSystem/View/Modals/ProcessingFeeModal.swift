//
//  ProcessingFeeModal.swift
//  QuickTutor
//
//  Created by Will Saults on 5/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class ProcessingFeeModal: BaseModalXibView {

    @IBOutlet weak var processingFeeLabel: UILabel!
    
    override func commonInit() {
        super.commonInit()
        
        setParagraphStyle(label: processingFeeLabel)
    }
    
    @IBAction func tappedDone(_ sender: Any) {
        dismiss()
    }
    
    static var view: ProcessingFeeModal {
        return Bundle.main.loadNibNamed(String(describing: ProcessingFeeModal.self),
                                        owner: nil,
                                        options: [:])?.first as! ProcessingFeeModal
    }
}
