
//
//  TutorMyProfileSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class TutorMyProfileSubjects : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	let sectionTitle : UILabel = {
		let label = UILabel()
		
		label.text = "Subjects"
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(16)
		label.textColor = Colors.tutorBlue
		
		return label
	}()
	
	let subjectCollectionView : UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 8.0
		layout.minimumLineSpacing = 8.0
		
		let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.alwaysBounceHorizontal = true
		
		return collectionView
	}()
	
	let divider : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.divider
		return view
	}()
	
	var datasource = [String]() {
		didSet {
			subjectCollectionView.reloadData()
		}
	}

	func configureView() {
		addSubview(sectionTitle)
		addSubview(subjectCollectionView)
		addSubview(divider)
		configureDelegates()

		backgroundColor = Colors.navBarColor
		applyConstraints()
	}
	
	func applyConstraints() {
		sectionTitle.snp.makeConstraints { (make) in
			make.top.width.equalToSuperview()
			make.left.equalToSuperview().inset(12)
			make.height.equalTo(30)
		}
		subjectCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(sectionTitle.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(40)
		}
		divider.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().inset(20)
			make.height.equalTo(1)
		}
	}
	private func configureDelegates() {
		subjectCollectionView.delegate = self
		subjectCollectionView.dataSource = self
		subjectCollectionView.register(SubjectSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "subjectSelectionCollectionViewCell")
	}
}
extension TutorMyProfileSubjects : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
		return datasource.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectSelectionCollectionViewCell", for: indexPath) as! SubjectSelectionCollectionViewCell
		
		cell.label.text = datasource[indexPath.row]
		return cell
	}
	
	func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: (datasource[indexPath.row] as NSString).size(withAttributes: nil).width + 35, height: 30)
	}
}
