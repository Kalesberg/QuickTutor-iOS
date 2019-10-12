//
//  QTTutorDiscoverTipDetailTitleTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverTipDetailTitleTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDiscoverTipDetailTitleTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    // MARK: - Functions
    func setData(tip: QTNewsModel) {
        descriptionLabel.text = tip.description
    }
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
