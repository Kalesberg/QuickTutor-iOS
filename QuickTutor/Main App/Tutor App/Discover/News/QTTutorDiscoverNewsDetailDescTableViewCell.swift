//
//  QTTutorDiscoverNewsDetailDescTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverNewsDetailDescTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDiscoverNewsDetailDescTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var news: QTNewsModel!
    
    // MARK: - Functions
    func setData(news: QTNewsModel) {
        
        let updatedAt = Date(timeIntervalSince1970: news.updatedAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        updatedAtLabel.text = formatter.string(from: updatedAt)
        
        descriptionLabel.text = news.description
        descriptionLabel.isHidden = news.description.isEmpty
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
