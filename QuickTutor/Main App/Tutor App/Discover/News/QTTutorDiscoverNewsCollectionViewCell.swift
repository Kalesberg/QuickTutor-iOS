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
    
    var news: QTNewsModel?
    var trending: MainPageFeaturedItem?
    
    var didReadButtonClickedHandler: ((Any) -> ())?
        
    // MARK: - Functions
    func configureViews() {
        readButton.backgroundColor = Colors.purple
        readButton.layer.cornerRadius = 5
        
        titleView.layer.cornerRadius = 5
        titleView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        titleView.clipsToBounds = true
    }
    
    func setData(news: QTNewsModel) {
        self.news = news
        
        if isSkeletonActive {
            hideSkeleton()
        }
        
        titleLabel.text = news.title
        imageView.sd_setImage(with: news.image, placeholderImage: UIImage(color: Colors.gray))
        
        titleLabel.isHidden = false
        readButton.isHidden = false

        imageView.isHidden = false
    }
    
    func setTrending(trending: MainPageFeaturedItem) {
        self.trending = trending
        
        titleLabel.text = trending.title
        imageView.sd_setImage(with: trending.backgroundImageUrl, placeholderImage: UIImage(color: Colors.gray))
        if let subject = trending.subject {
            readButton.setTitle(subject, for: .normal)
        } else if let subcategory = trending.subcategoryTitle {
            readButton.setTitle(subcategory, for: .normal)
        } else if let category = trending.categoryTitle {
            readButton.setTitle(category, for: .normal)
        }
        
        titleLabel.isHidden = false
        readButton.isHidden = false
    }
    
    // MARK: - Actions
    @IBAction func onReadButtonClicked(_ sender: Any) {
        if let news = news {
            didReadButtonClickedHandler?(news)
        } else if let trending = trending {
            didReadButtonClickedHandler?(trending)
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureViews()
    }

}
