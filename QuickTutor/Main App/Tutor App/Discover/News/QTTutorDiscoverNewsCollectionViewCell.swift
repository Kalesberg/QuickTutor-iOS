//
//  QTTutorDiscoverNewsCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/3/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView


class QTTutorDiscoverNewsCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: QTCustomImageView!
    @IBOutlet weak var titleView: UIVisualEffectView!
    @IBOutlet weak var readButton: DimmableButton!
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDiscoverNewsCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var news: QTNewsModel!
    var didReadButtonClickedHandler: ((QTNewsModel) -> Void)?
    
    // MARK: - Functions
    func configureViews() {
        readButton.backgroundColor = Colors.purple
        readButton.layer.cornerRadius = 5
        
        titleView.layer.cornerRadius = 5
        titleView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        titleView.clipsToBounds = true
    }
    
    func setSkeletonViews() {
        titleLabel.isHidden = true
        readButton.isHidden = true
        imageView.isHidden = true
        
        self.isSkeletonable = true
        self.titleView.isSkeletonable = true
    }
    
    func setData(news: QTNewsModel) {
        self.news = news
        
        if isSkeletonActive {
            hideSkeleton()
        }
        
        titleLabel.text = news.title
        imageView.setImage(url: news.image)
        
        titleLabel.isHidden = false
        readButton.isHidden = false
        imageView.isHidden = false
    }
    
    // MARK: - Actions
    @IBAction func onReadButtonClicked(_ sender: Any) {
        didReadButtonClickedHandler?(news)
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureViews()
        setSkeletonViews()
    }

}
