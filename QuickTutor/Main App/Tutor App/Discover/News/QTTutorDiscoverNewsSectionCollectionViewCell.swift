//
//  QTTutorDiscoverNewsSectionCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTPageControl: UIPageControl {
    
    // MARK: - Properties
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    // MARK: - Functions
    func updateDots() {
        var i = 0
        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i == self.currentPage {
                    imageView.image = UIImage(color: Colors.gray)
                } else {
                    imageView.image = UIImage(color: UIColor.clear)
                }
                imageView.layer.borderColor = Colors.gray.cgColor
                imageView.layer.borderWidth = 1
                imageView.layer.cornerRadius = view.bounds.size.width / 2
                i = i + 1
            } else {
                var dotImage = UIImage(color: UIColor.clear)
                if i == self.currentPage {
                    dotImage = UIImage(color: Colors.gray)
                }
                view.clipsToBounds = true
                let imageView = UIImageView(image:dotImage)
                imageView.layer.borderColor = Colors.gray.cgColor
                imageView.layer.borderWidth = 1
                view.addSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
                imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0).isActive = true
                imageView.layer.cornerRadius = view.bounds.size.width / 2
                i = i + 1
            }
        }
    }
    
    fileprivate func imageForSubview(_ view: UIView) -> UIImageView? {
        var dot:UIImageView?
        
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        
        return dot
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class QTTutorDiscoverNewsSectionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "News"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    let controller = QTTutorDiscoverNewsViewController()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    
    var pageControlWidthAnchor: NSLayoutConstraint?
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDiscoverNewsSectionCollectionViewCell.self)
    }
    
    
    // MARK: - Functions
    func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor,
                          paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20,
                          width: 0, height: 0)
    }
    
    func setupController() {
        contentView.addSubview(controller.view)
        controller.delegate = self
        controller.view.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor,
                               paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                               width: 0, height: 0)
    }
    
    func setupPageControl() {
        contentView.addSubview(pageControl)
        pageControl.anchor(top: controller.view.bottomAnchor, left: nil, bottom: contentView.bottomAnchor, right: nil,
                           paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                           width: 0, height: 8)
        pageControlWidthAnchor = pageControl.widthAnchor.constraint(equalToConstant: 63)
        pageControlWidthAnchor?.isActive = true
        pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    func setupViews() {
        setupTitleLabel()
        setupController()
        setupPageControl()
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension QTTutorDiscoverNewsSectionCollectionViewCell: QTTutorDiscoverNewsViewControllerDelegate {
    func didScrollToIndex(index: Int) {
        pageControl.currentPage = index
    }
    
    func numberOfNews(number: Int) {
        pageControlWidthAnchor?.constant = CGFloat(8 * number + 7 * (number - 2))
        pageControl.numberOfPages = number
        pageControl.currentPage = 0
    }
    
}
