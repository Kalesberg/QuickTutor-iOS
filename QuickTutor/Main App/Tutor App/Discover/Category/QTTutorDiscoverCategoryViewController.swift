//
//  QTTutorDiscoverCategoryViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/11/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ActiveLabel

class QTTutorDiscoverCategoryViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryDescriptionLabel: ActiveLabel!
    @IBOutlet weak var subcategoriesCollectionView: UICollectionView!
    @IBOutlet weak var priceView: QTCustomView!
    @IBOutlet weak var advancedPriceLabel: UILabel!
    @IBOutlet weak var proPriceLabel: UILabel!
    @IBOutlet weak var expertPriceLabel: UILabel!
    @IBOutlet weak var subcategoriesCollectionViewHeight: NSLayoutConstraint!
    
    static var controller: QTTutorDiscoverCategoryViewController {
        return QTTutorDiscoverCategoryViewController(nibName: String(describing: QTTutorDiscoverCategoryViewController.self), bundle: nil)
    }
    
    var categoryName: String!
    var category: Category!
    
    // MARK: - Functions
    func setupParallaxHeader() {
        
        let headerView = QTTutorDiscoverCategoryParallaxHeaderView.view
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = 380
        scrollView.parallaxHeader.mode = .fill
        scrollView.parallaxHeader.minimumHeight = 0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        headerView.setData(category: category)
    }
    
    func getCategory(name: String) {
        category = Category.category(for: categoryName)
    }
    
    func setData() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        
        scrollView.delegate = self
        
        let customType = ActiveType.custom(pattern: "\\s\(category.mainPageData.displayName)\\b")
        categoryDescriptionLabel.enabledTypes = [customType]
        categoryDescriptionLabel.configureLinkAttribute = {(type, attributes, isSelected) in
            var atts = attributes
            switch type {
            case customType:
                atts[NSAttributedString.Key.font] = UIFont.qtItalicFont(size: 14)
                atts[NSAttributedString.Key.foregroundColor] = UIColor.white
            default: ()
            }
            
            return atts
        }
        
        if let categoryInfo = QTGlobalData.shared.categories[category.mainPageData.name] {
            categoryDescriptionLabel.text = categoryInfo.description
        }
        categoryDescriptionLabel.numberOfLines = 0
        
        subcategoriesCollectionView.register(PillCollectionViewCell.self,
                                             forCellWithReuseIdentifier: PillCollectionViewCell.reuseIdentifier)
        let layout = AlignedCollectionViewFlowLayout(
            horizontalAlignment: .left,
            verticalAlignment: .center
        )
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        subcategoriesCollectionView.collectionViewLayout = layout
        subcategoriesCollectionView.dataSource = self
        subcategoriesCollectionView.delegate = self
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        gradientLayer.frame = priceView.bounds
        gradientLayer.colors = [Colors.purple,
                                Colors.purple.withAlphaComponent(0.3)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        priceView.layer.insertSublayer(gradientLayer, at: 0)
        priceView.layer.cornerRadius = 5
        priceView.clipsToBounds = true
        
        if let categoryInfo = QTGlobalData.shared.categories[category.mainPageData.name] {
            advancedPriceLabel.text = "$\(categoryInfo.priceClass[0])"
            proPriceLabel.text = "$\(categoryInfo.priceClass[1])"
            expertPriceLabel.text = "$\(categoryInfo.priceClass[2])"
        }
    }
    
    func updateSubjectsHeight() {
        subcategoriesCollectionViewHeight.constant = subcategoriesCollectionView.contentSize.height
        subcategoriesCollectionView.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategory(name: categoryName)
        setupParallaxHeader()
        setData()
    }
}

// MARK: - UICollectionViewDelegate
extension QTTutorDiscoverCategoryViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension QTTutorDiscoverCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 60
        width = category.subcategory.subcategories[indexPath.row].title.estimateFrameForFontSize(14, extendedWidth: true).width + 20
        return CGSize(width: width, height: 30)
    }
}

// MARK: - UICollectionViewDataSource
extension QTTutorDiscoverCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PillCollectionViewCell.reuseIdentifier, for: indexPath) as! PillCollectionViewCell
        cell.titleLabel.text = category.subcategory.subcategories[indexPath.row].title
        
        updateSubjectsHeight()
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.subcategory.subcategories.count
    }
}

// MARK: - UIScrollViewDelegate
extension QTTutorDiscoverCategoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let nav = self.navigationController {
            let height = nav.navigationBar.frame.origin.y + nav.navigationBar.frame.size.height
            if scrollView.contentOffset.y >= -height {
                navigationController?.navigationBar.backgroundColor = Colors.newNavigationBarBackground.withAlphaComponent(max(height + scrollView.contentOffset.y, 0) / height)
                UIApplication.shared.statusBarView?.backgroundColor = Colors.newNavigationBarBackground.withAlphaComponent(max(height + scrollView.contentOffset.y, 0) / height)
                title = category.mainPageData.displayName
            } else {
                navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationController?.navigationBar.shadowImage = UIImage()
                navigationController?.navigationBar.backgroundColor = .clear
                navigationController?.navigationBar.alpha = 1
                title = ""
            }
        }
    }
}
