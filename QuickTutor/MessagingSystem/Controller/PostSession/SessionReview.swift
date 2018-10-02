//
//  SessionReview.swift
//  QuickTutor
//
//  Created by QuickTutor on 8/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import SDWebImage

protocol PostSessionInformationDelegate {
	func didSelectRating(rating: Int)
	func didSelectTipPercentage(tipPercent: Int?)
	func didWriteReview(review: String?)
	func textViewDidBeingEditing()
	func textViewDidEndEditing()
	func didUpdateData()
}

struct PostSessionReviewData {
	static var rating : Int? = nil
	static var tipPercentage : Int? = nil
	static var review : String? = nil
}

struct PostSessionData {
	let partnerId: String?
	let sessionId: String?
	let session: Session?
	let sessionLength: Double?

	init(partnerId: String?, sessionId: String?, session: Session?, sessionLength: Double?) {
		self.partnerId = partnerId
		self.sessionId = sessionId
		self.session = session
		self.sessionLength = sessionLength
	}
}

class SessionReviewView : MainLayoutTitleTwoButton {
	
	//add init to get data in View.
	//let sessionView = YourSessionView()
	//let sessionCompleteHeaderView = SessionCompleteHeader()
	
	let profileImageView : UIImageView = {
		let imageView = UIImageView()
		
		imageView.backgroundColor = .red
		imageView.layer.masksToBounds = false
		imageView.clipsToBounds = true
		
		return imageView
	}()

	var collectionViewLayout : AlignTopCollectionViewFlowLayout = {
		let collectionViewLayout = AlignTopCollectionViewFlowLayout()
		
		collectionViewLayout.minimumLineSpacing = 0
		collectionViewLayout.scrollDirection = .horizontal
		
		return collectionViewLayout
	}()
	
	let collectionView : UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())

		collectionView.backgroundColor = Colors.backgroundDark
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.isScrollEnabled = false
		
		return collectionView
	}()
	
	override func configureView() {
		addSubview(collectionView)
		addSubview(profileImageView)
		super.configureView()
		
		collectionView.collectionViewLayout = collectionViewLayout
		
		title.label.text = "Session Complete!"
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		profileImageView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-10)
			make.width.height.equalTo(80)
			make.centerX.equalToSuperview()
		}
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageView.snp.centerY)
			make.width.centerX.equalToSuperview()
			if UIScreen.main.bounds.height < 570 {
				make.height.equalToSuperview().multipliedBy(0.6)
			} else {
				make.height.equalToSuperview().multipliedBy(0.45)
			}
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		profileImageView.layer.cornerRadius = profileImageView.frame.height / 20
	}
}

class SessionReview : BaseViewController {
	
	override var contentView: SessionReviewView {
		return view as! SessionReviewView
	}
	override func loadView() {
		view = SessionReviewView()
	}
	
	var currentItem = 0
	var postSessionData : PostSessionData?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		configureDelegates()
	}
	
	private func configureDelegates() {
		contentView.collectionView.delegate = self
		contentView.collectionView.dataSource = self
//		contentView.collectionView.register(SessionReviewCell.self, forCellWithReuseIdentifier: "sessionReviewCell")
//		contentView.collectionView.register(TutorRatingViewCell.self, forCellWithReuseIdentifier: "tutorRatingCell")
//		contentView.collectionView.register(TutorReviewCell.self, forCellWithReuseIdentifier: "tutorReviewCell")
//		contentView.collectionView.register(TutorTipCell.self, forCellWithReuseIdentifier: "tutorTipCell")
	}
	
	private func calculateSectionInset() -> CGFloat {
		let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
		let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
		let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
		let cellBodyWidth: CGFloat = 236 + (cellBodyViewIsExpended ? 174 : 0)
		
		let inset = (contentView.collectionView.frame.width - cellBodyWidth) / 4
		return inset
	}
	
	private func configureCollectionViewLayoutItemSize() {
		let inset : CGFloat = calculateSectionInset()
		contentView.collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
		contentView.collectionViewLayout.itemSize = CGSize(width: contentView.collectionView.frame.size.width - inset * 2, height: contentView.collectionView.frame.size.height)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		configureCollectionViewLayoutItemSize()
	}
}
extension SessionReview : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		switch indexPath.item {
//		case 0:
//			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorRatingCell", for: indexPath) as! TutorRatingViewCell
//
//			return cell
//		case 1:
//			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorReviewCell", for: indexPath) as! TutorReviewCell
//			cell.delegate = self
//			return cell
//		case 2:
//			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorTipCell", for: indexPath) as! TutorTipCell
//			return cell
//		default:
//			return UICollectionViewCell()
//		}
		return UICollectionViewCell()
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 25
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		switch indexPath.item {
		case 0:
			return CGSize(width: collectionView.frame.size.width - calculateSectionInset() * 2, height: collectionView.frame.size.height / 1.2)
		case 1:
			return CGSize(width: collectionView.frame.size.width - calculateSectionInset() * 2, height: collectionView.frame.size.height / 1.2)
		case 2:
			return CGSize(width: collectionView.frame.size.width - calculateSectionInset() * 2, height: collectionView.frame.size.height)
		default:
			return CGSize(width: 0, height: 0)
		}
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if currentItem == 2 {
			currentItem = -1
		}
		let this = currentItem
		currentItem += 1
		let indexPath = IndexPath(row: 1 + this , section: 0)
		contentView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
	}
}

extension SessionReview : PostSessionInformationDelegate {
	func textViewDidBeingEditing() {
		contentView.profileImageView.snp.remakeConstraints { (make) in
			make.top.equalTo(contentView.navbar.snp.bottom)
			make.width.equalTo(0)
			make.height.equalTo(0)
			make.centerX.equalToSuperview()
		}
		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}
	
	func textViewDidEndEditing() {
		contentView.profileImageView.snp.remakeConstraints { (make) in
			make.width.equalTo(80)
			make.height.equalTo(80)
			make.top.equalTo(contentView.navbar.snp.bottom).inset(10)
			make.centerX.equalToSuperview()
		}
		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}
	
	func didSelectRating(rating: Int) {
		PostSessionReviewData.rating = rating
	}
	
	func didSelectTipPercentage(tipPercent: Int?) {
		PostSessionReviewData.tipPercentage = tipPercent
	}
	
	func didWriteReview(review: String?) {
		PostSessionReviewData.review = review
	}
	func didUpdateData() {
	
	}
}

class AlignTopCollectionViewFlowLayout: UICollectionViewFlowLayout {
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let attrs = super.layoutAttributesForElements(in: rect)
		var attrsCopy = [UICollectionViewLayoutAttributes]()
		for  element in attrs! {
			let elementCopy = element.copy() as! UICollectionViewLayoutAttributes
			if (elementCopy.representedElementCategory == .cell) {
				elementCopy.frame.origin.y = 0
			}
			attrsCopy.append(elementCopy)
		}
		return attrsCopy
	}
}
