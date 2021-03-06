//
//  QTLocationTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLocationTableViewCell: UITableViewCell {

    // MARK: - variables
    @IBOutlet weak var landmarkLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: - static functions
    static var resuableIdentifier: String {
        return String(describing: QTLocationTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTLocationTableViewCell.self), bundle: nil)
    }
    
    // MARK: - lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.newScreenBackground.darker(by: 5)
        selectedBackgroundView = cellBackground
    }

    // MARK: - actions
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - public functions
    public func setData(landmark: String, address: String) {
        landmarkLabel.text = landmark
        addressLabel.text = address
    }
}
