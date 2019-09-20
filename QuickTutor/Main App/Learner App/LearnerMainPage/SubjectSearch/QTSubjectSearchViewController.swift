//
//  QTSubjectSearchViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTSubjectSearchViewController: UIViewController {
    
    static var controller: QTSubjectSearchViewController {
        return QTSubjectSearchViewController(nibName: String(describing: QTSubjectSearchViewController.self), bundle: nil)
    }
    
    var connectedTutor: AWTutor!
    var sectionHeights = [Int: CGFloat]()
    
    var categories: [Category] = [.academics, .business, .lifestyle, .language,  .arts,  .sports, .health, .tech, .outdoors, .auto, .trades,  .remedial]
    
    var automaticScroll: Bool = false
    var shouldUpdateSearchResults = false
    
    var inlineCellIndexPath: IndexPath?
    
    let child = QuickSearchResultsVC()
    
    var filteredSubjects = [(String, String)]()
    var allSubjects = [(String, String)]()
    var searchFilter: SearchFilter?
    var searchTimer: Timer?
    var tableViewIsActive: Bool = false {
        didSet {
            shouldUpdateSearchResults = tableViewIsActive
        }
    }
    
    // MARK: - Properties
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.delaysContentTouches = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cv.register(QuickSearchCategoryCell.self, forCellWithReuseIdentifier: "cellId")
        cv.register(QuickSearchSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        return cv
    }()
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        hideKeyboardWhenTappedAround()
        configureDelegates()
        setupDelegates()
        
        if let subjects = SubjectStore.shared.loadTotalSubjectList() {
            allSubjects = subjects
            allSubjects.shuffle()
        }
    }

    // MARK: - Actions
    @objc
    func searchText(_ notification: Notification) {
        child.inSearchMode = true
        child.isNewQuickSearch = true
        
        if let searchText = notification.userInfo?[QTNotificationName.quickSearchSubjects] as? String {
            searchSubjects(searchText: searchText)
        } else {
            removeChild(popViewController: false)
        }
    }
    
    @objc
    func handleQuickSearchBegin(_ notification: Notification) {
        
    }
    
    @objc
    func handleQuickSearchEnd(_ notification: Notification) {
        removeChild(popViewController: true)
    }
    
    @objc
    func handleQuickSearchClearSearchKey(_ notification: Notification) {
        searchSubjects(searchText: "")
    }
    
    // MARK: - Functions
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        self.view.backgroundColor = Colors.newScreenBackground
    }
    
    func setupCollectionView() {
        self.view.insertSubview(collectionView, at: 0)
        
        var guide = self.view.layoutMarginsGuide
        if #available(iOS 11.0, *) {
            guide = self.view.safeAreaLayoutGuide
        }
        collectionView.anchor(top: guide.topAnchor, left: guide.leftAnchor, bottom: guide.bottomAnchor, right: guide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    func setupSearchResultScreen() {
        guard child.view?.superview == nil else { return }
        addChild(child)
        child.scrollViewDraggedClosure = {
            //searchBarContainer.searchBar.endEditing(true)
        }
        self.view.insertSubview(child.view, at: 1)
        
        var guide = self.view.layoutMarginsGuide
        if #available(iOS 11.0, *) {
            guide = self.view.safeAreaLayoutGuide
        }
        
        child.view.anchor(top: guide.topAnchor, left: guide.leftAnchor, bottom: guide.bottomAnchor, right: guide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        child.didMove(toParent: self)
    }
    
    private func configureDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupDelegates() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(searchText(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchSubjects),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleQuickSearchBegin(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchBegin),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleQuickSearchEnd(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchEnd),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleQuickSearchClearSearchKey(_:)),
                                               name: NSNotification.Name(QTNotificationName.quickSearchClearSearchKey),
                                               object: nil)
        
    }
    
    private func searchSubjects(searchText: String) {
        if searchText.isEmpty {
            removeChild(popViewController: false)
            return
        }
        setupSearchResultScreen()
        // Whenver search again with different searchText, just remove no result screen and show loading animation.
        self.child.unknownSubject = nil
        if self.child.filteredSubjects.isEmpty {
            DispatchQueue.main.async {
                self.child.indicatorView.startAnimation(updatedText: "Searching for \"\(searchText)\"")
            }
        } else {
            DispatchQueue.main.async {
                self.child.indicatorView.stopAnimation()
            }
        }
        
        searchTimer?.invalidate()
        self.child.unknownSubject = nil
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false
            , block: { (_) in
                DispatchQueue.global().async {
                    self.child.filteredSubjects = self.child.subjects.filter({ $0.0.lowercased().starts(with: searchText.lowercased())}).sorted(by: {$0.0 < $1.0})
                    
                    DispatchQueue.main.async {
                        self.child.indicatorView.stopAnimation()
                        // If there is no subjects to be matched, show no result view.
                        if self.child.filteredSubjects.count == 0 {
                            self.child.unknownSubject = searchText
                        }
                    }
                    
                    DispatchQueue.main.sync {
                        self.child.contentView.collectionView.reloadData()
                    }
                }
        })
    }
    
    func removeChild(popViewController: Bool) {
        child.indicatorView.stopAnimation()
        child.filteredSubjects.removeAll()
        child.contentView.collectionView.reloadData()
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        guard popViewController else { return }
        navigationController?.popViewController(animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension QTSubjectSearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        if !automaticScroll {
            NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
            view.endEditing(true)
        }
    }
    
    func scrollViewWillBeginDragging(_: UIScrollView) {
        if !automaticScroll {
            NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
            view.endEditing(true)
        }
    }
    
}

extension QTSubjectSearchViewController: QuickSearchCategoryCellDelegate {
    func quickSearchCategoryCell(_ cell: QuickSearchCategoryCell, didSelect subcategory: String, at indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchDismissKeyboard), object: nil)
        let vc = CategorySearchVC()
        AnalyticsService.shared.logSubcategoryTapped(subcategory)
        vc.subcategory = subcategory
        vc.searchFilter = searchFilter
        vc.navigationItem.title = subcategory
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func quickSeachCateogryCell(_ cell: QuickSearchCategoryCell, needsHeight height: CGFloat) {
        let section = collectionView.indexPath(for: cell)?.section ?? -1
        sectionHeights[section] = height
        collectionView.reloadSections(IndexSet(arrayLiteral: section))
    }
}

extension QTSubjectSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            let category = categories[indexPath.section]
            header.titleLabel.text = category.mainPageData.displayName
            header.icon.image = categoryIcons[indexPath.section]
            header.icon.layer.borderColor = category.color.cgColor
            header.icon.layer.borderWidth = 1
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
