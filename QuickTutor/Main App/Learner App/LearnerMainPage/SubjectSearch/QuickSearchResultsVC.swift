//
//  QuickSearchResultsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 1/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QuickSearchResultsVC: UIViewController {
    
    var subjects = [(String, String)]()
    var filteredSubjects = [(String, String)]()
    var inSearchMode = false
    
    var currentSubjects: [(String, String)] {
        get {
            return inSearchMode ? filteredSubjects : subjects
        }
    }
    
    let contentView: QuickSearchResultsVCView = {
        let view = QuickSearchResultsVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubjects()
        setupDelegates()
    }
    
    func setupDelegates() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
    }
    
    func loadSubjects() {
        if let subjects = SubjectStore.loadTotalSubjectList() {
            self.subjects = subjects
            self.subjects.shuffle()
            contentView.collectionView.reloadData()
        }
    }
    
}

extension QuickSearchResultsVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSubjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickSearchResultsCell
        cell.titleLabel.text = currentSubjects[indexPath.item].0
        let categoryString = SubjectStore.findCategoryBy(subject: currentSubjects[indexPath.item].0) ?? ""
        let category = Category.category(for: categoryString)!
        cell.imageView.image = Category.imageFor(category: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CategorySearchVC()
        vc.category = CategoryFactory.shared.getCategoryFor(subject: currentSubjects[indexPath.item].0)
        vc.navigationItem.title = currentSubjects[indexPath.item].0
        navigationController?.pushViewController(vc, animated: true)
    }
}

class QuickSearchResultsCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(14)
        label.text = "Mathmatics"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.layer.cornerRadius = 17.5
        iv.clipsToBounds = true
        return iv
    }()
    
    func setupViews() {
        setupImageView()
        setupTitleLabel()
    }
    
    func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 20, paddingBottom: 10, paddingRight: 0, width: 35, height: 0)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class QuickSearchResultsVCView: UIView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .interactive
        cv.register(QuickSearchResultsCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = .blue
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
