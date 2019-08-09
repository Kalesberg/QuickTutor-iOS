//
//  CategorySearch.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import CoreLocation
import SkeletonView
import MessageUI

struct CategorySelected {
    static var title: String!
}

protocol QTSearchBarViewDelegate {
    func didSearchBarBeginEditing(_ sender: PaddedTextField)
    func didSearchBarTextChanged(_ text: String?)
    func didSearchBarReturn(_ sender: PaddedTextField)
}

class QTSearchBarView: UIView {
    // MARK: - Properties
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var searchBar: PaddedTextField = {
        let field = PaddedTextField()
        field.backgroundColor = Colors.newNavigationBarBackground
        field.textColor = .white
        field.leftView = nil
        field.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.75)])
        field.font = Fonts.createBoldSize(16)
        field.layer.cornerRadius = 4
        field.returnKeyType = .search
        field.enablesReturnKeyAutomatically = true
        field.clearButtonMode = .never
        field.tintColor = Colors.purple
        field.autocorrectionType = .no
        field.autocapitalizationType = .words
        return field
    }()
    
    let searchClearButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        button.setImage(UIImage(named:"ic_search_close"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    var delegate: QTSearchBarViewDelegate?
    
    // MARK: - Actions
    @objc
    func handleDidSearchTextChanged(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            searchClearButton.isHidden = false
        } else {
            searchClearButton.isHidden = true
        }
        
        delegate?.didSearchBarTextChanged(sender.text)
    }
    
    @objc
    func handleDidClearButtonClicked(_ sender: UIButton) {
        searchBar.text = nil
        searchBar.becomeFirstResponder()
        handleDidSearchTextChanged(searchBar)
    }
    
    // MARK: - Functions
    func setupViews() {
        setupContainerView()
        setupSearchBar()
    }
    
    func setupContainerView() {
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 36, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupSearchBar() {
        containerView.addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        searchBar.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        searchBar.delegate = self
        searchBar.addTarget(self, action: #selector(handleDidSearchTextChanged(_:)), for: .editingChanged)
        searchBar.rightView = searchClearButton
        searchBar.rightViewMode = .always
        searchClearButton.addTarget(self, action: #selector(handleDidClearButtonClicked(_:)), for: .touchUpInside)
    }
    
    func showSearchClearButton(_ show: Bool = true) {
        searchClearButton.isHidden = !show
    }
    
    func setTitle(_ title: String) {
        searchBar.text = title
        showSearchClearButton()
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension QTSearchBarView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.didSearchBarBeginEditing(searchBar)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didSearchBarReturn(searchBar)
        return true
    }
}

class QTSearchTitleView: UIView {
    var searchBar: QTSearchBarView = {
        let view = QTSearchBarView()
        return view
    }()
    
    var delegate: QTSearchBarViewDelegate? {
        didSet {
            searchBar.delegate = delegate
        }
    }
    
    func setupViews() {
        setupSearchBar()
    }
    
    func setupSearchBar() {
        addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
    }
    
    func setTitle(_ title: String) {
        searchBar.setTitle(title)
    }
    
    func setupDelegate(_ delegate: Any) {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var intrinsicContentSize: CGSize {
        let width = UIScreen.main.bounds.width - 100
        return CGSize(width: width, height: 44)
    }
}

class QTSuggestionTableViewCell: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: QTSuggestionTableViewCell.self)
    }
    
    let searchIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "searchIconMain"))
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(17)
        label.text = "Mathmatics"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    func setupViews() {
        backgroundColor = Colors.newScreenBackground
        setupSearchIconImageView()
        setupNameLabel()
    }
    
    func setupSearchIconImageView() {
        addSubview(searchIconImageView)
        searchIconImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 17, paddingLeft: 16, paddingBottom: 17, paddingRight: 0, width: 16, height: 16)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: searchIconImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        nameLabel.centerYAnchor.constraint(equalTo: searchIconImageView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    
    override
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
}

class CategorySearchVC: UIViewController {
    
    let itemsPerBatch: UInt = 10
    var datasource: [AWTutor] = []
    var filteredDatasource: [AWTutor] = []
    var didLoadMore: Bool = false
    var loadedAllTutors = false
    var category: String!
    var subcategory: String!
    var subject: String!
    var lastKey: String?
    
    var filteredSubjects = [(String, String)]()
    var allSubjects = [(String, String)]()
    var searchTimer: Timer?
    var unknownSubject: String?
    let suggestionCellHeight: CGFloat = 50
    var hasNoSubject: Bool = false
    
    private var tableViewHeight: NSLayoutConstraint?
    
    private var _observing = false
    
    var searchFilter: SearchFilter? {
        didSet {
            updateFiltersIcon()
        }
    }
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        didSet {
            if let filter = searchFilter {
                applySearchFilterToDataSource(filter)
            }
        }
    }

    let menuBtn = UIButton(type: .custom)
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.newScreenBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        collectionView.isSkeletonable = true
        return collectionView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = Colors.newScreenBackground
        return tableView
    }()
    
    let maskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()

    let emptyBackground: EmptySearchBackground = {
        let view = EmptySearchBackground()
        view.isHidden = true
        return view
    }()
    
    var titleView = QTSearchTitleView()
    
    func setupEmptyBackgroundView() {
        view.addSubview(emptyBackground)
        emptyBackground.anchor(top: collectionView.topAnchor, left: collectionView.leftAnchor, bottom: collectionView.bottomAnchor, right: collectionView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.bringSubviewToFront(emptyBackground)
    }
    
    func setupTitleView() {
        self.navigationItem.titleView = titleView
        titleView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100).isActive = true
        titleView.delegate = self
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
        }
        
        collectionView.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: TutorCollectionViewCell.reuseIdentifier)
        collectionView.register(TutorLoadMoreCollectionViewCell.self, forCellWithReuseIdentifier: TutorLoadMoreCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        view.bringSubviewToFront(tableView)
        tableView.anchor(top: view.topAnchor,
                         left: view.leftAnchor,
                         bottom: nil,
                         right: view.rightAnchor,
                         paddingTop: 0,
                         paddingLeft: 0,
                         paddingBottom: 0,
                         paddingRight: 0,
                         width: 0,
                         height: 0)
        tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeight?.isActive = true
        
        tableView.register(QTSuggestionTableViewCell.self, forCellReuseIdentifier: QTSuggestionTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = 50
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupMaskView() {
        view.insertSubview(maskView, belowSubview: tableView)
        maskView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        maskView.isUserInteractionEnabled = true
        maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidMaskViewTapped(_:))))
        maskView.isHidden = true
    }
    
    
    func setUpFiltersButton(){
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 18, height: 18)
        updateFiltersIcon()
        menuBtn.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 18)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 18)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    private func updateFiltersIcon() {
        if searchFilter != nil {
            menuBtn.setImage(UIImage(named:"filtersAppliedIcon"), for: .normal)
        } else {
            menuBtn.setImage(UIImage(named:"filterIcon"), for: .normal)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFilters(_:)), name: NotificationNames.QuickSearch.updatedFilters, object: nil)
    }
    
    func queryNeededTutors(lastKnownKey: String?) {
        guard !loadedAllTutors else { return }
        print(subject)
        if category != nil {
            queryTutorsByCategory(lastKnownKey: lastKnownKey)
        } else if subcategory != nil {
            print("=== Search start ====")
            print(Date().description)
            queryTutorsBySubcategory(lastKnownKey: lastKnownKey)
        } else if subject != nil {
            queryTutorsBySubject(lastKnownKey: lastKnownKey)
        }
    }
    
    private func queryTutorsByCategory(lastKnownKey: String?) {
        _observing = true
        TutorSearchService.shared.getTutorsByCategory(category, lastKnownKey: lastKnownKey) { (tutors, loadedAllTutors) in
            self._observing = false
            self.view.hideSkeleton()
            
            guard let tutors = tutors, !tutors.isEmpty else {
                if self.datasource.isEmpty {
                    self.emptyBackground.isHidden = false
                } else {
                    self.emptyBackground.isHidden = true
                }
                self.loadedAllTutors = true
                self.collectionView.reloadData()
                return
            }
            
            self.emptyBackground.isHidden = true
            
            self.lastKey = tutors.last?.uid
            self.loadedAllTutors = loadedAllTutors
            self.datasource.append(contentsOf: tutors)
            self.datasource = self.datasource.sorted() { tutor1, tutor2 -> Bool in
                let categoryReviews1 = tutor1.categoryReviews(self.category).count
                let categoryReviews2 = tutor2.categoryReviews(self.category).count
                return categoryReviews1 > categoryReviews2
                    || (categoryReviews1 == categoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (categoryReviews1 == categoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
            self.filteredDatasource = self.datasource
            if let filter = self.searchFilter, self.datasource.count > 0 {
                self.applySearchFilterToDataSource(filter)
            }
            self.collectionView.reloadData()
        }
    }
    
    private func queryTutorsBySubcategory(lastKnownKey: String?) {
        _observing = true
        TutorSearchService.shared.getTutorsBySubcategory(subcategory, lastKnownKey: lastKnownKey) { (tutors, loadedAllTutors) in
            self._observing = false
            self.view.hideSkeleton()
            
            guard let tutors = tutors, !tutors.isEmpty else {
                if self.datasource.isEmpty {
                    self.emptyBackground.isHidden = false
                } else {
                    self.emptyBackground.isHidden = true
                }
                self.loadedAllTutors = true
                self.collectionView.reloadData()
                return
            }
            
            self.emptyBackground.isHidden = true
            
            self.lastKey = tutors.last?.uid
            self.loadedAllTutors = loadedAllTutors
            self.datasource.append(contentsOf: tutors)
            
            self.datasource = self.datasource.sorted() { tutor1, tutor2 -> Bool in
                let subcategoryReviews1 = tutor1.reviews?.filter({ self.subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                let subcategoryReviews2 = tutor2.reviews?.filter({ self.subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                return subcategoryReviews1 > subcategoryReviews2
                    || (subcategoryReviews1 == subcategoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (subcategoryReviews1 == subcategoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
            self.filteredDatasource = self.datasource
            if let filter = self.searchFilter, self.datasource.count > 0 {
                self.applySearchFilterToDataSource(filter)
            }
            self.collectionView.reloadData()
            
        }
    }
    
    private func queryTutorsBySubject(lastKnownKey: String?) {
        _observing = true
        TutorSearchService.shared.getTutorsBySubject(subject, lastKnownKey: lastKnownKey) { (tutors, loadedAllTutors) in
            self._observing = false
            self.view.hideSkeleton()
            
            guard let tutors = tutors, !tutors.isEmpty else {
                if self.datasource.isEmpty {
                    self.emptyBackground.isHidden = false
                } else {
                    self.emptyBackground.isHidden = true
                }
                self.loadedAllTutors = true
                self.collectionView.reloadData()
                return
            }
            
            self.emptyBackground.isHidden = true
            self.lastKey = tutors.last?.uid
            self.loadedAllTutors = loadedAllTutors
            
            self.datasource.append(contentsOf: tutors)
            self.datasource = self.datasource.sorted() { tutor1, tutor2 -> Bool in
                let subjectReviews1 = tutor1.reviews?.filter({ $0.subject == self.subject }).count ?? 0
                let subjectReviews2 = tutor2.reviews?.filter({ $0.subject == self.subject }).count ?? 0
                return subjectReviews1 > subjectReviews2
                    || (subjectReviews1 == subjectReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (subjectReviews1 == subjectReviews2 && tutor1.reviews?.count == tutor1.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
            self.filteredDatasource = self.datasource
            if let filter = self.searchFilter, self.datasource.count > 0 {
                self.applySearchFilterToDataSource(filter)
            }
            self.collectionView.reloadData()
        }
    }
    
    private func applySearchFilterToDataSource(_ filter: SearchFilter) {
        filteredDatasource = datasource.filter({ (tutor) -> Bool in
            var shouldBeIncluded = true
            if let minHourlyRate = filter.minHourlyRate {
                shouldBeIncluded = tutor.price >= minHourlyRate
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            if let maxHourlyRate = filter.maxHourlyRate {
                shouldBeIncluded = tutor.price <= maxHourlyRate
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            if let ratingType = filter.ratingType {
                if ratingType == 0 {
                    shouldBeIncluded = tutor.tRating >= 5.0
                } else if ratingType == 1 {
                    shouldBeIncluded = tutor.tRating >= 4.0
                }
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            guard filter.sessionType == 1 else { return shouldBeIncluded }
            
            if let minDistance = filter.minDistance {
                let distance = findDistance(location: tutor.location)
                shouldBeIncluded = distance >= Double(minDistance)
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            if let maxDistance = filter.maxDistance {
                let distance = findDistance(location: tutor.location)
                shouldBeIncluded = distance <= Double(maxDistance)
            }
            return shouldBeIncluded
        })
    }
    
    func sendEmail(subject: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["subjects@quicktutor.com"])
            mail.setMessageBody("<p>I’m submitting a subject: <b>\(subject)</b></p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    // MARK: - Actions
    @objc
    func updateFilters(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let filter = userInfo["filter"] as? SearchFilter else { return }
        self.searchFilter = filter
    }
    
    @objc
    func showFilters() {
        let vc = FiltersVC()
        vc.searchFilter = searchFilter
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func showQuickSearch() {
        let vc = QuickSearchVC()
        vc.needDismissWhenPush = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc
    func handleDidMaskViewTapped(_ gesture: UITapGestureRecognizer) {
        self.maskView.isHidden = true
        self.tableViewHeight?.constant = 0
        
        if let category = category {
            self.titleView.setTitle(category)
        } else if let subcategory = subcategory {
            self.titleView.setTitle(subcategory)
        } else if let subject = subject {
            self.titleView.setTitle(subject)
        }
        self.titleView.endEditing(true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        view.backgroundColor = Colors.newScreenBackground
        
        if let subjects = SubjectStore.shared.loadTotalSubjectList() {
            allSubjects = subjects
            allSubjects.shuffle()
        }
        
        setupObservers()
        setupLocationManager()
        
        if category != nil || subcategory != nil || subject != nil {
            setupTitleView()
        }
        
        setupCollectionView()
        setupEmptyBackgroundView()
        setUpFiltersButton()
        setupMaskView()
        setupTableView()
        
        if hasNoSubject {
            if let subject = subject {
                collectionView.setEmptyMessage(subject) {
                    self.sendEmail(subject: subject)
                }
                self.emptyBackground.isHidden = true
                self.loadedAllTutors = true
                self.collectionView.reloadData()
            }
        } else {
            print("=== Prepare Skeleton Start === ")
            print(Date().description)
            if 0 == datasource.count {
                collectionView.prepareSkeleton { _ in
                    self.view.showAnimatedSkeleton(usingColor: Colors.gray)
                    print("=== Prepare Skeleton End === ")
                    print(Date().description)
                    self.queryNeededTutors(lastKnownKey: nil)
                }
            } else {
                filteredDatasource = datasource
                queryNeededTutors(lastKnownKey: nil)
            }
        }
        
        if let category = category {
            titleView.setTitle(category)
        } else if let subcategory = subcategory {
            titleView.setTitle(subcategory)
        } else if let subject = subject {
            titleView.setTitle(subject)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        hideTabBar(hidden: true)
        guard let filter = self.searchFilter, self.datasource.count > 0 else {
            return
        }
        self.applySearchFilterToDataSource(filter)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.titleView.endEditing(true)
        hideTabBar(hidden: false)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension CategorySearchVC: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TutorCollectionViewCell.reuseIdentifier
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return filteredDatasource.count + (self.loadedAllTutors ? 0 : 1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if filteredDatasource.count == indexPath.row {
            if !_observing {
                queryNeededTutors(lastKnownKey: lastKey)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorLoadMoreCollectionViewCell.reuseIdentifier, for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorCollectionViewCell.reuseIdentifier, for: indexPath) as! TutorCollectionViewCell
            cell.updateUI(filteredDatasource[indexPath.item])
            cell.profileImageViewHeightAnchor?.constant = 160
            cell.layoutIfNeeded()
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CategorySearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        return CGSize(width: (screen.width - 60) / 2, height: 225)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

// MARK: - UICollectionViewDelegate
extension CategorySearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TutorCollectionViewCell else {
            return
        }
        
        cell.shrink()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TutorCollectionViewCell else {
            return
        }
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TutorCollectionViewCell else {
            return
        }
        cell.growSemiShrink {
            guard self.filteredDatasource.count > indexPath.item else { return }
            
            let featuredTutor = self.filteredDatasource[indexPath.item]
            let uid = featuredTutor.uid
            FirebaseData.manager.fetchTutor(uid!, isQuery: false, { (tutor) in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller//TutorCardVC()
                controller.subject = featuredTutor.featuredSubject
                controller.profileViewType = .tutor
                controller.user = tutor
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }
}

extension CategorySearchVC: UISearchBarDelegate {
    internal func searchBarTextDidBeginEditing(_: UISearchBar) {
        navigationController?.pushViewController(QuickSearchVC(), animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension CategorySearchVC: CLLocationManagerDelegate {
    
    func findDistance(location: TutorLocation?) -> Double {
        guard let tutorLocation = location?.location else {
            return 0
        }
        
        let currentDistance = currentLocation?.distance(from: tutorLocation) ?? 0
        return currentDistance * 0.00062137
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

// MARK: - UITableViewDelegate
extension CategorySearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.shrink()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.transform = CGAffineTransform.identity
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.growSemiShrink {
            self.handleDidMaskViewTapped(UITapGestureRecognizer())
            
            // Load subject search screen again.
            let vc = CategorySearchVC()
            vc.subject = self.filteredSubjects[indexPath.row].0
            vc.hasNoSubject = false
            AnalyticsService.shared.logSubjectTapped(vc.subject)
            vc.searchFilter = self.searchFilter
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension CategorySearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSubjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTSuggestionTableViewCell.reuseIdentifier, for: indexPath) as! QTSuggestionTableViewCell
        cell.nameLabel.text = self.filteredSubjects[indexPath.row].0
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - QTSearchBarViewDelegate
extension CategorySearchVC: QTSearchBarViewDelegate {
    func didSearchBarBeginEditing(_ sender: PaddedTextField) {
        maskView.isHidden = false
        didSearchBarTextChanged(sender.text)
    }
    
    func didSearchBarTextChanged(_ text: String?) {
        searchTimer?.invalidate()
        self.unknownSubject = nil
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false
            , block: { (_) in
                DispatchQueue.global().async {
                    
                    guard let text = text, !text.isEmpty else {
                        DispatchQueue.main.sync {
                            self.maskView.isHidden = false
                            self.filteredSubjects.removeAll()
                            self.tableViewHeight?.constant = 0
                            self.tableView.reloadData()
                        }
                        return
                    }
                    
                    self.filteredSubjects = self.allSubjects.filter({ $0.0.lowercased().starts(with: text.lowercased())}).sorted(by: {$0.0 < $1.0})
                    if self.filteredSubjects.count == 0 {
                        self.unknownSubject = text
                    }
                    
                    DispatchQueue.main.sync {
                        // Reset the height of tableView
                        let contentSize = CGFloat(self.filteredSubjects.count) * self.suggestionCellHeight
                        let viewSize = self.view.frame.size
                        let maxSize = viewSize.height - CGFloat(DeviceInfo.keyboardHeight)
                        
                        if contentSize >= maxSize {
                            self.tableViewHeight?.constant = maxSize
                        } else {
                            self.tableViewHeight?.constant = contentSize
                        }
                        
                        self.tableView.reloadData()
                    }
                }
        })
    }
    
    func didSearchBarReturn(_ sender: PaddedTextField) {
        guard let text = sender.text else {
            self.handleDidMaskViewTapped(UITapGestureRecognizer())
            return
        }
        
        self.handleDidMaskViewTapped(UITapGestureRecognizer())
        
        var currentKeyword = ""
        if let category = category {
            currentKeyword = category
        } else if let subcategory = subcategory {
            currentKeyword = subcategory
        } else if let subject = subject {
            currentKeyword = subject
        }
        
        if currentKeyword.compare(text) == .orderedSame {
            return
        }
        
        // Load subject search screen again.
        let vc = CategorySearchVC()
        vc.subject = text
        vc.hasNoSubject = filteredSubjects.filter({$0.0.lowercased().compare(text.lowercased()) == .orderedSame}).isEmpty
        AnalyticsService.shared.logSubjectTapped(text)
        vc.searchFilter = searchFilter
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension CategorySearchVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
