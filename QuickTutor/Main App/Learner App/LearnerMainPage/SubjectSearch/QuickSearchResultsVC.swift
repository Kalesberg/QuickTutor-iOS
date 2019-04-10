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
        if currentSubjects.count == 0 {
            collectionView.setEmptyMessage("No subjects found")
        } else {
            collectionView.restoreEmptyState()
        }
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
        let subject = currentSubjects[indexPath.item].0
        vc.subject = subject
        AnalyticsService.shared.logSubjectTapped(subject)
        vc.navigationItem.title = subject
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = Colors.grayText
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = Fonts.createSize(14)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restoreEmptyState() {
        self.backgroundView = nil
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


class TutorAddSubjectsResultsVC: UIViewController {
    
    var subjects = [String]()
    var filteredSubjects = [String]()
    var inSearchMode = false
    var isBeingControlled = false
    
    var currentSubjects: [String] {
        get {
            return inSearchMode ? filteredSubjects : subjects
        }
    }
    
    let contentView: TutorAddSubjectsResultsVCView = {
        let view = TutorAddSubjectsResultsVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserers()
        loadSubjects()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !isBeingControlled else { return }
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "newCheck"), style: .plain, target: self, action: #selector(onBack))
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupDelegates() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
    }
    
    func loadSubjects() {
        guard subjects.count == 0 else { return }
        if let subjects = SubjectStore.loadTotalSubjectList() {
            self.subjects = subjects.map({ $0.0 })
            self.subjects.shuffle()
            contentView.collectionView.reloadData()
        }
    }
    
    func setupObserers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(rawValue: "com.qt.tooManySubjects"), object: nil)
    }
    
    @objc func showAlert() {
        let ac = UIAlertController(title: "Too many subjects", message: "We currently only allow users to choose 20 subjects", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            ac.dismiss(animated: true, completion: nil)
        }))
        present(ac, animated: true, completion: nil)
    }
    
}

extension TutorAddSubjectsResultsVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSubjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TutorAddSubjectsResultsCell
        cell.titleLabel.text = currentSubjects[indexPath.item]
        let categoryString = SubjectStore.findCategoryBy(subject: currentSubjects[indexPath.item]) ?? ""
        let category = Category.category(for: categoryString)!
        cell.imageView.image = Category.imageFor(category: category)
        cell.selectionView.isHidden = !TutorRegistrationService.shared.subjects.contains(currentSubjects[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorAddSubjectsResultsCell
        cell.selectionView.isHidden = !cell.selectionView.isHidden
        if cell.selectionView.isHidden {
            TutorRegistrationService.shared.removeSubject(currentSubjects[indexPath.item])
        } else {
            TutorRegistrationService.shared.addSubject(currentSubjects[indexPath.item])
        }
    }
}

class TutorAddSubjectsResultsCell: QuickSearchResultsCell {
    
    let selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.purple
        view.layer.cornerRadius = 5
        view.isHidden = true
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        setupSelectionView()
    }
    
    func setupSelectionView() {
        addSubview(selectionView)
        selectionView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 10, height: 10)
        addConstraint(NSLayoutConstraint(item: selectionView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionView.isHidden = true
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
        backgroundColor = Colors.darkBackground
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

class TutorAddSubjectsResultsVCView: UIView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .interactive
        cv.register(TutorAddSubjectsResultsCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
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
