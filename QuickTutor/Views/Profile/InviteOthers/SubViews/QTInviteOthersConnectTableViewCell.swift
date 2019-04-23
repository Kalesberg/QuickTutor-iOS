//
//  QTInviteOthersConnectTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTInviteOthersConnectTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTInviteOthersConnectTableViewCell.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTInviteOthersConnectTableViewCell.self)
    }
    
    var didClickConnectButton: (() -> ())?
    
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
    @IBAction func onConnectButtonClicked(_ sender: Any) {
        if let didClickConnectButton = didClickConnectButton {
            didClickConnectButton()
        }
    }
}
