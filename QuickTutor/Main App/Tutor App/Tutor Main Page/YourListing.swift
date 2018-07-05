//
//  YourListing.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class YourListingView : MainLayoutTitleBackTwoButton {
    
    var editButton = NavbarButtonEdit()
    
    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }
    
    let scrollView = UIScrollView()
    
    let collectionView : UICollectionView = {
        
        let collectionView  = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        
        let customLayout = CategorySearchCollectionViewLayout(cellsPerRow: 3, minimumInteritemSpacing: 5, minimumLineSpacing: 50, sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
        
        collectionView.collectionViewLayout = customLayout
        collectionView.backgroundColor = Colors.tutorBlue
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    
    let imageView : UIImageView = {
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFill
        view.image = #imageLiteral(resourceName: "auto-pattern")
        view.clipsToBounds = true
        
        return view
    }()
    
    let categoryLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
        label.text = "Sports & Games"
        
        return label
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("\nWhat is this?", 18, .white)
            .regular("\n\nThis is where you can view and edit how your listing is seen by learners on the home page. Your listing is different from your actual profile.\n\nYou can customize the photo, price, and subject that you want learners to see on the home page of the learner app.\n\nTap \"Edit\" in the top-right of the screen.\n\n", 15, .white)
        
        label.attributedText = formattedString
        
        label.numberOfLines = 0
        
        return label
    }()
    
    override func configureView() {
        addSubview(scrollView)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(imageView)
        imageView.addSubview(categoryLabel)
        scrollView.addSubview(infoLabel)
        super.configureView()
        
        title.label.text = "Your Listing"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.width.centerX.top.equalToSuperview()
            make.height.equalTo(250)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).inset(-1)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(50)
        }

        categoryLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
    }
}


class YourListing : BaseViewController {
    
    override var contentView: YourListingView {
        return view as! YourListingView
    }
    
    override func loadView() {
        view = YourListingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(FeaturedTutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
}


extension YourListing : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell
        
//        cell.featuredTutor.imageView.loadUserImagesWithoutMask(by: datasource[indexPath.item].imageUrl)
//        cell.price.text = datasource[indexPath.item].price.priceFormat()
//        cell.featuredTutor.namePrice.text = datasource[indexPath.item].name
//        cell.featuredTutor.region.text = datasource[indexPath.item].region
//        cell.featuredTutor.subject.text = datasource[indexPath.item].subject
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            //.bold("\(datasource[indexPath.item].rating) ", 14, Colors.yellow)
            //.regular("(\(datasource[indexPath.item].reviews) ratings)", 12, Colors.yellow)
        cell.featuredTutor.ratingLabel.attributedText = formattedString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let horizontalInset = (contentView.collectionView.frame.width - CGFloat(150)) / 2
        let verticalInset = (contentView.collectionView.frame.height - CGFloat(200)) / 2
        
        return UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        cell.shrink()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
}


