//
//  QTRecentSearchTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTRecentSearchTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var iconImageView: QTCustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    static var reuseIdentifier: String {
        return String(describing: QTRecentSearchTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var recentSearch: QTRecentSearchModel?
    var onDeleteHandler: ((QTRecentSearchModel?) -> Void)?
    
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
    @IBAction func onDeleteButtonClicked(_ sender: Any) {
        if let recentSearch = recentSearch, let onDeleteHandler = onDeleteHandler {
            onDeleteHandler(recentSearch)
        }
    }
    
    // MARK: - Functions
    func setData(recentSearch: QTRecentSearchModel) {
        self.recentSearch = recentSearch
        if recentSearch.type == QTRecentSearchType.people {
            nameLabel.text = QTUtils.shared.getFormatedName(name: recentSearch.name1)
            if let imageUrl = recentSearch.imageUrl {
                iconImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "viewProfileButton"), options: [])
            } else {
                iconImageView.image = UIImage(named: "viewProfileButton")
            }
            
            iconImageView.borderColor = .clear
            iconImageView.borderWidth = 0
        } else {
            if let named2 = recentSearch.name2 {
                nameLabel.text = named2
                if let category = Category.category(for: recentSearch.name1) {
                    iconImageView.image = Category.imageFor(category: category)
                } else {
                    iconImageView.image = UIImage(named: "uploadImageDefaultImage")
                }
            } else {
                nameLabel.text = recentSearch.name1
                if let category = Category.category(for: recentSearch.name1) {
                    iconImageView.image = Category.imageFor(category: category)
                } else {
                    iconImageView.image = UIImage(named: "uploadImageDefaultImage")
                }
            }
            iconImageView.borderColor = Colors.purple
            iconImageView.borderWidth = 1
        }
        
        deleteButton.imageView?.overlayTintColor(color: Colors.gray)
    }
}
