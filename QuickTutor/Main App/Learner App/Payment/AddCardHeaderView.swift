//
//  AddCardHeaderView.swift
//  QuickTutor
//
//  Created by Will Saults on 5/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol AddCardHeaderDelegate {
    func didTapAddButton()
}

class AddCardHeaderView: UIView {
 
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var addNewButton: UIButton!
    var delegate: AddCardHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static var view: AddCardHeaderView {
        return Bundle.main.loadNibNamed(String(describing: AddCardHeaderView.self),
                                        owner: nil,
                                        options: [:])?.first as! AddCardHeaderView
    }
    @IBAction func tappedAddNewButton(_ sender: Any) {
        delegate?.didTapAddButton()
    }
}
