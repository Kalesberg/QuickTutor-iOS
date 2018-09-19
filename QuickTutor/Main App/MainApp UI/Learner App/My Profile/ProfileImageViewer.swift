//
//  ProfileImageViewer.swift
//  QuickTutor
//
//  Created by QuickTutor on 8/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import FirebaseUI
import SDWebImage

protocol ProfileImageViewerDelegate {
	func dismiss()
}

class ProfileImageViewer : InteractableView, Interactable {
	required init() {
		fatalError("init() has not been implemented")
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let pageControl : UIPageControl = {
		let pageControl = UIPageControl()
		
		pageControl.currentPage = 0
		pageControl.pageIndicatorTintColor = .white
		pageControl.currentPageIndicatorTintColor = Colors.learnerPurple
		
		return pageControl
	}()
	
	let collectionView : UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()

		layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		
		collectionView.collectionViewLayout = layout
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.isPagingEnabled = true
		collectionView.backgroundColor = .clear
		collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
		
		return collectionView
	}()
	
	let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	
	var imageCount : Int
	var userId : String
	var delegate : ProfileImageViewerDelegate?
	
	init(imageCount: Int, userId: String) {
		self.imageCount = imageCount
		self.userId = userId
		super.init()
	}
	
	override func configureView() {
		addSubview(collectionView)
		addSubview(pageControl)
		super.configureView()
		
		alpha = 0.0
		backgroundColor = UIColor.black.withAlphaComponent(0.8)
		pageControl.numberOfPages = imageCount

		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(ProfileImageViewerCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		collectionView.snp.makeConstraints { (make) in
			make.width.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.55)
			make.height.equalToSuperview().multipliedBy(0.3)
		}
		pageControl.snp.makeConstraints { (make) in
			make.top.equalTo(collectionView.snp.bottom)
			make.width.equalTo(50)
			make.height.equalTo(30)
			make.centerX.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	func touchStart() {
		delegate?.dismiss()
	}
}

extension ProfileImageViewer : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imageCount
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.dismiss()
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ProfileImageViewerCollectionViewCell
		cell.profileImageView.sd_setImage(with: storageRef.child("student-info").child(userId).child("student-profile-pic\(indexPath.item+1)"), placeholderImage: nil)
		cell.layoutSubviews()
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = UIScreen.main.bounds.width - 10
		return CGSize(width: width, height: collectionView.frame.height)
	}
}
extension ProfileImageViewer : UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
			pageControl.currentPage = visibleIndexPath.item
		}
	}
}
class ProfileImageViewerCollectionViewCell : UICollectionViewCell {
	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureCollectionViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let profileImageView : UIImageView = {
		let imageView = UIImageView()
		
		imageView.layer.masksToBounds = false
		imageView.clipsToBounds = true
		imageView.scaleImage()
		
		return imageView
	}()
	
	func configureCollectionViewCell() {
		addSubview(profileImageView)

		applyConstraints()
	}
	
	func applyConstraints() {
		profileImageView.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.9)
			make.width.equalTo(profileImageView.snp.height)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		profileImageView.layer.cornerRadius = profileImageView.frame.height / 20
	}
}
