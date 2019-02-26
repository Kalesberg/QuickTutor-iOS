//
//  QuickSearchVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 1/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

protocol CustomSearchBarDelegate: class {
    func customSearchBar(_ searchBar: PaddedTextField, shouldEndEditing: Bool)
    func customSearchBar(_ searchBar: PaddedTextField, shouldBeginEditing: Bool)
    func customSearchBarDidTapLeftView(_ searchBar: PaddedTextField)
    func customSearchBarDidTapMockLeftView(_ searchBar: PaddedTextField)
}

extension CustomSearchBarDelegate {
    func customSearchBarDidTapMockLeftView(_ searchBar: PaddedTextField) {}
}

class CustomSearchBarContainer: UIView {
    
    weak var delegate: CustomSearchBarDelegate?
    var isEditing = false
    
    lazy var searchBar: PaddedTextField = {
        let field = PaddedTextField()
        field.padding.left = 40
        field.backgroundColor = Colors.gray
        field.textColor = .white
        let searchIcon = UIImageView(image: UIImage(named:"searchIconMain"))
        field.leftView = searchIcon
        field.leftView?.transform = CGAffineTransform(translationX: 12.5, y: 0)
        field.leftViewMode = .always
        field.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.75)])
        field.font = Fonts.createBoldSize(16)
        field.layer.cornerRadius = 4
        return field
    }()
    
    let mockLeftViewButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"newBackButton"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    let cancelEditingButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        return button
    }()
    
    var searchBarRightAnchor: NSLayoutConstraint?

    func setupViews() {
        setupSearchBar()
        setupMockLeftViewButton()
        setupCancelEditingButton()
        setupLeftView()
    }
    
    func setupSearchBar() {
        addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        searchBarRightAnchor = searchBar.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        searchBarRightAnchor?.isActive = true
    }
    
    func setupCancelEditingButton() {
        insertSubview(cancelEditingButton, belowSubview: searchBar)
        cancelEditingButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 0)
        cancelEditingButton.addTarget(self, action: #selector(shouldEndEditing), for: .touchUpInside)
    }
    
    func setupMockLeftViewButton() {
        addSubview(mockLeftViewButton)
        mockLeftViewButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 9, paddingLeft: 7, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
        mockLeftViewButton.addTarget(self, action: #selector(handleMockLeftViewTapped), for: .touchUpInside)
    }
    
    func setupLeftView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLeftViewTap))
        tap.numberOfTapsRequired = 1
        searchBar.leftView?.addGestureRecognizer(tap)
    }
    
    @objc func handleLeftViewTap() {
        delegate?.customSearchBarDidTapLeftView(searchBar)
    }
    
    @objc func handleMockLeftViewTapped() {
        delegate?.customSearchBarDidTapMockLeftView(searchBar)
    }
    
    func shouldBeginEditing() {
        isEditing = true
        guard searchBarRightAnchor?.constant == 0 else { return }
        searchBarRightAnchor?.constant = -60
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
        }
        delegate?.customSearchBar(searchBar, shouldBeginEditing: true)
    }
    
    @objc func shouldEndEditing() {
        isEditing = false
        searchBarRightAnchor?.constant = 0
        searchBar.text = nil
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        delegate?.customSearchBar(searchBar, shouldEndEditing: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QuickSearchVCView: UIView {

    let searchBarContainer: CustomSearchBarContainer = {
        let container = CustomSearchBarContainer()
        return container
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.register(QuickSearchCategoryCell.self, forCellWithReuseIdentifier: "cellId")
        cv.register(QuickSearchSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        return cv
    }()
    
    func setupViews() {
        setupMainView()
        setupSearchBarContainer()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupSearchBarContainer() {
        addSubview(searchBarContainer)
        searchBarContainer.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 53, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 47)

    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TutorRegistrationService {
    static let shared = TutorRegistrationService()
    
    var subjects = [String]()
    
    func addSubject(_ subject: String) {
        subjects.append(subject)
        NotificationCenter.default.post(name: Notifications.tutorSubjectsDidChange.name, object: nil, userInfo: nil)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("subjects").child(subject).child(uid).setValue(1)
    }
    
    func removeSubject(_ subject: String) {
        subjects = subjects.filter({ $0 != subject})
        NotificationCenter.default.post(name: Notifications.tutorSubjectsDidChange.name, object: nil, userInfo: nil)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("subjects").child(subject).child(uid).removeValue()
    }
    
    func setFeaturedSubject(_ subject: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("tutor-info").child(uid).child("sbj").setValue(subject)
        
    }
    
    func restructureTutorSubjectData() {
        Database.database().reference().child("subject")
    }
    
    private init() {
        if CurrentUser.shared.learner.isTutor {
            subjects = CurrentUser.shared.tutor.subjects ?? [String]()
        } else {
            subjects = [String]()
        }
    }
}

class TutorAddSubjectsVCView: QuickSearchVCView {
    
    let noSubjectsLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(12)
        label.text = "You haven't added any subjects yet"
        label.textColor = Colors.gray
        label.textAlignment = .center
        return label
    }()
    
    let selectedSubjectsCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceHorizontal = true
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        cv.register(QuickSearchSubcategoryCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let accessoryView: RegistrationAccessoryView = {
        let view = RegistrationAccessoryView()
        return view
    }()
    
    let accessoryTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Add up to 30 subjects"
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        label.numberOfLines = 0
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupNoSubjectsLabel()
        setupSelectedSubjectsCV()
        setupAccessoryView()
        setupAccessoryTextLabel()
        let backIcon = UIImageView(image: UIImage(named:"newBackButton"))
        searchBarContainer.searchBar.leftView = backIcon
        searchBarContainer.cancelEditingButton.setTitle("Done", for: .normal)
        setupObservers()
        searchBarContainer.mockLeftViewButton.isHidden = false
    }
    
    func setupNoSubjectsLabel() {
        addSubview(noSubjectsLabel)
        noSubjectsLabel.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func setupSelectedSubjectsCV() {
        addSubview(selectedSubjectsCV)
        selectedSubjectsCV.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        selectedSubjectsCV.delegate = self
        selectedSubjectsCV.dataSource = self
    }
    
    func setupAccessoryView() {
        addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
    }
    
    func setupAccessoryTextLabel() {
        accessoryView.addSubview(accessoryTextLabel)
        accessoryTextLabel.anchor(top: accessoryView.topAnchor, left: accessoryView.leftAnchor, bottom: accessoryView.bottomAnchor, right: accessoryView.nextButton.leftAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
    }
    
    override func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubjectChange(_:)), name: Notifications.tutorSubjectsDidChange.name, object: nil)
    }

    @objc func handleSubjectChange(_ notification: Notification) {
        selectedSubjectsCV.reloadData()
        let indexPath = IndexPath(item: selectedSubjectsCV.numberOfItems(inSection: 0) - 1, section: 0)
        selectedSubjectsCV.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    func showRemovePromptFor(subject: String) {
        let ac = UIAlertController(title: "Remove subject?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
            TutorRegistrationService.shared.removeSubject(subject)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            ac.dismiss(animated: true, completion: nil)
        }))
        parentContainerViewController?.present(ac, animated: true, completion: nil)
    }
}

extension TutorAddSubjectsVCView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TutorRegistrationService.shared.subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickSearchSubcategoryCell
        cell.titleLabel.text = TutorRegistrationService.shared.subjects[indexPath.item]
        cell.backgroundColor =  Colors.purple
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 60
        width = TutorRegistrationService.shared.subjects[indexPath.item].estimateFrameForFontSize(12).width + 40
        return CGSize(width: width, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showRemovePromptFor(subject: TutorRegistrationService.shared.subjects[indexPath.item])
    }
}

class NewTutorAddSubjectsVC: UIViewController {
    
    
    var isViewing = true
    var sectionHeights = [Int: CGFloat]()
    let child = TutorAddSubjectsResultsVC()

    
    let contentView: TutorAddSubjectsVCView = {
        let view = TutorAddSubjectsVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
        contentView.accessoryView.isHidden = isViewing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configureDelegates() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.searchBarContainer.delegate = self
        contentView.searchBarContainer.searchBar.delegate = self
    }
}

extension NewTutorAddSubjectsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickSearchCategoryCell
        cell.category = categories[indexPath.section]
        cell.tag = indexPath.section
        cell.delegate = self
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath) as! QuickSearchSectionHeader
            header.titleLabel.text = categories[indexPath.section].mainPageData.displayName
            header.icon.image = categoryIcons[indexPath.section]
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = sectionHeights[indexPath.section] ?? 35
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 75)
    }
}

extension NewTutorAddSubjectsVC: CustomSearchBarDelegate {
    func customSearchBarDidTapLeftView(_ searchBar: PaddedTextField) {
        dismiss(animated: true, completion: nil)
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldBeginEditing: Bool) {
        
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldEndEditing: Bool) {
        removeChild()
    }
    
    func customSearchBarDidTapMockLeftView(_ searchBar: PaddedTextField) {
        navigationController?.popViewController(animated: true)
    }
    
    func removeChild() {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        contentView.searchBarContainer.searchBar.resignFirstResponder()
    }
}

extension NewTutorAddSubjectsVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contentView.searchBarContainer.shouldBeginEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        beginEditing()
        child.inSearchMode = true
        guard let text = textField.text, !text.isEmpty else { return true}
        child.filteredSubjects = child.subjects.filter({ $0.range(of: text, options: .caseInsensitive) != nil }).sorted(by: { $0.count < $1.count })
        child.contentView.collectionView.reloadData()
        return true
    }
    
    func beginEditing() {
        guard child.view?.superview == nil else { return }
        child.isBeingControlled = true
        addChild(child)
        contentView.addSubview(child.view)
        child.view.anchor(top: contentView.searchBarContainer.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.getBottomAnchor(), right: contentView.rightAnchor, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        child.didMove(toParent: self)
    }
}

extension NewTutorAddSubjectsVC: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension NewTutorAddSubjectsVC: QuickSearchCategoryCellDelegate {
    func quickSearchCategoryCell(_ cell: QuickSearchCategoryCell, didSelect subcategory: String, at indexPath: IndexPath) {
        let vc = TutorAddSubjectsResultsVC()
        vc.subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategory) ?? [String]()
        vc.navigationItem.title = subcategory.capitalized
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func quickSeachCateogryCell(_ cell: QuickSearchCategoryCell, needsHeight height: CGFloat) {
        let section = contentView.collectionView.indexPath(for: cell)?.section ?? -1
        sectionHeights[section] = height
        contentView.collectionView.reloadSections(IndexSet(arrayLiteral: section))
    }
}

