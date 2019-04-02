//
//  LearnerMainPageVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

struct MainPageFeaturedSubject {
    var subject: String
    var backgroundImageUrl: URL
}

class LearnerMainPageFeaturedSubjectTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(LearnerMainPageFeaturedSubjectCell.self, forCellWithReuseIdentifier: "cellId")
        return collectionView
    }()
    
    func setupViews() {
        setupObservers()
        setupMainView()
        setupTitleLabel()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
        selectionStyle = .none
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFetchedSubjects), name: NSNotification.Name(rawValue: "com.qt.fetchedSubjects"), object: nil)
    }
    
    @objc func handleFetchedSubjects() {
        collectionView.reloadData()
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LearnerMainPageFeaturedSubjectCell: UICollectionViewCell {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "cookingTest")
        return iv
    }()
    
    let infoBox: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 4
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.clipsToBounds = true
        return view
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(14)
        label.text = "Mathmatics"
        return label
    }()
    
    let tryItButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.purple
        button.setTitle("Try it", for: .normal)
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    func setupViews() {
        setupBackgroundImageView()
        setupInfoBox()
        setupSubjectLabel()
        setupTryItButton()
    }
    
    func setupBackgroundImageView() {
        addSubview(backgroundImageView)
        backgroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupInfoBox() {
        addSubview(infoBox)
        infoBox.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 10, paddingRight: 30, width: 0, height: 50)
    }
    
    func setupSubjectLabel() {
        infoBox.contentView.addSubview(subjectLabel)
        subjectLabel.anchor(top: infoBox.topAnchor, left: infoBox.leftAnchor, bottom: infoBox.bottomAnchor, right: infoBox.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupTryItButton() {
        infoBox.contentView.addSubview(tryItButton)
        tryItButton.anchor(top: nil, left: nil, bottom: nil, right: infoBox.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 60, height: 30)
        addConstraint(NSLayoutConstraint(item: tryItButton, attribute: .centerY, relatedBy: .equal, toItem: infoBox, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func updateUI(_ featuredSubject: MainPageFeaturedSubject) {
        subjectLabel.text = featuredSubject.subject
        backgroundImageView.sd_setImage(with: featuredSubject.backgroundImageUrl, completed: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LearnerMainPageVCView: UIView {

    lazy var searchBar: PaddedTextField = {
        let field = PaddedTextField()
        field.padding.left = 40
        field.backgroundColor = Colors.gray
        field.textColor = .white
        let searchIcon = UIImageView(image: UIImage(named:"searchIconMain"))
        field.leftView = searchIcon
        field.leftView?.transform = CGAffineTransform(translationX: 12.5, y: 0)
        field.leftViewMode = .unlessEditing
        field.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.75)])
        field.font = Fonts.createBoldSize(16)
        field.layer.cornerRadius = 4
        return field
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedSectionHeaderHeight = 50
        tableView.estimatedRowHeight = 100
//        tableView.sectionHeaderHeight = 50
        tableView.backgroundColor = Colors.newBackground
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.register(LearnerMainPageFeaturedSubjectTableViewCell.self, forCellReuseIdentifier: "featuredCell")
        tableView.register(FeaturedTutorTableViewCell.self, forCellReuseIdentifier: "tutorCell")
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        return tableView
    }()
    
    func applyConstraints() {
        setupSearchBar()
        setupTableView()
    }
    
    func setupSearchBar() {
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(53)
            make.height.equalTo(47)
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        searchBar.delegate = self
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.layoutSubviews()
        tableView.layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyConstraints()
        backgroundColor = Colors.newBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LearnerMainPageVCView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let field = textField as? PaddedTextField else { return }
        UIView.animate(withDuration: 0.25) {
            guard field.padding.left == 40 else { return }
            field.padding.left -= 30
            field.layoutIfNeeded()
            field.leftView?.alpha = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.alpha = 1
    }
}
