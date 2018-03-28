//
//  TutorCardCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import SnapKit

class TutorCardCollectionViewCell : UICollectionViewCell {
	

	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func configureView() {
		
		applyConstraints()
	}
	func applyConstraints(){

	}
}


class TutorCardHeader : BaseView {
	
	let imageView : UIImageView = {
		let imageView = UIImageView()
		
		return imageView
	}()
	let name : UILabel = {
		let label = UILabel()
		
		return label
	}()
	let region : UILabel = {
		let label = UILabel()
		
		return label
	}()
	let tutorData : UILabel = {
		let label = UILabel()
		
		return label
	}()
	
	override func configureView() {
		super.configureView()
		
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
	}
}

class TutorDistanceView : BaseView {
	let distance : UILabel = {
		let label = UILabel()
		
		return label
	}()
	
	override func configureView() {
		super.configureView()
		
		backgroundColor = .white
		
		applyConstraints()
		
	}
	override func applyConstraints() {
		super.applyConstraints()
	}
}
