//
//  QTTutorSearchTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/6/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorSearchTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorSearchTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.newScreenBackground.darker(by: 5)
        selectedBackgroundView = cellBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func setData(user: UsernameQuery) {
        nameLabel.text = QTUtils.shared.getFormatedName(name: user.name)
        usernameLabel.text = user.username
        avatarImageView.image = UIImage(named: "viewProfileButton")
        avatarImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: UIImage(named: "viewProfileButton"), options: [])
    }
}
