//
//  QTQAQuickRequestCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTQAQuickRequestCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    @IBOutlet weak var containerView: UIView!
    
    static var reuseIdentifier: String {
        return String(describing: QTQAQuickRequestCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var helpAlert: QTQuickRequestAlertModal?
    
    // MARK: - Functions
    func configureViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 5)
        containerView.layer.cornerRadius = 5
    }
    
    // MARK: - Actions
    @IBAction func OnQuickRequestInfoButtonClicked(_ sender: Any) {
        helpAlert = QTQuickRequestAlertModal(frame: .zero)
        helpAlert?.set("QuickRequest",
                       "Get help with anything as soon as possible.")
        helpAlert?.show()
    }
    
    
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        configureViews()
    }

}
