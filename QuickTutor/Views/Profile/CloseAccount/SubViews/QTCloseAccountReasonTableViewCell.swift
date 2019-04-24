//
//  QTCloseAccountReasonTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTCloseAccountReasonTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var reasonLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: QTCloseAccountReasonTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTCloseAccountReasonTableViewCell.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    public func setData(reason: String) {
        reasonLabel.text = reason
    }
}
