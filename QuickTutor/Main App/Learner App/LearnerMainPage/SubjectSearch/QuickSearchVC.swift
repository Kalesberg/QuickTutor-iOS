//
//  SearchSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import CoreLocation
import UIKit

class QuickSearchVC: UIViewController {
    
    var connectedTutor: AWTutor!
    var sectionHeights = [Int: CGFloat]()

    var categories: [Category] = [.academics, .business, .lifestyle, .language,  .arts,  .sports, .health, .tech, .outdoors, .auto, .trades,  .remedial]

    var automaticScroll: Bool = false
    var shouldUpdateSearchResults = false

    var inlineCellIndexPath: IndexPath?
    
    let child = QuickSearchResultsVC()

    var filteredSubjects = [(String, String)]()

    var allSubjects = [(String, String)]()
    
    var searchFilter: SearchFilter? {
        didSet {
            updateFiltersIcon()
        }
    }

    var searchTimer: Timer?
    var needDismissWhenPush = false

    var tableViewIsActive: Bool = false {
        didSet {
            shouldUpdateSearchResults = tableViewIsActive
        }
    }
    
    let contentView: QuickSearchVCView = {
        let view = QuickSearchVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureDelegates()
        setupObservers()

        if let subjects = SubjectStore.shared.loadTotalSubjectList() {
            allSubjects = subjects
            allSubjects.shuffle()
        }
        contentView.searchBarContainer.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        hideTabBar(hidden: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.searchBarContainer.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabBar(hidden: false)
    }

    private func configureDelegates() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.searchBarContainer.delegate = self
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextField.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFilters(_:)), name: NotificationNames.QuickSearch.updatedFilters, object: nil)
    }
    
    @objc func updateFilters(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let filter = userInfo["filter"] as? SearchFilter else { return }
        self.searchFilter = filter
    }
    
    private func updateFiltersIcon() {
        if searchFilter != nil {
            contentView.searchBarContainer.filtersButton.setImage(UIImage(named:"filtersAppliedIcon"), for: .normal)
        } else {
            contentView.searchBarContainer.filtersButton.setImage(UIImage(named:"filterIcon"), for: .normal)
        }
    }
}

extension QuickSearchVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contentView.searchBarContainer.shouldBeginEditing()
        contentView.searchBarContainer.searchBar.clearButtonTintColor = .white
    }
    
    private func filterSubjects(_ text: String) {
        searchTimer?.invalidate()
        self.child.unknownSubject = nil
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false
            , block: { (_) in
                DispatchQueue.global().async {
                    self.child.filteredSubjects = self.child.subjects.filter({ $0.0.starts(with: text)}).sorted(by: {$0.0 < $1.0})
                    if self.child.filteredSubjects.count == 0 {
                        self.child.unknownSubject = text
                    }
                    
                    DispatchQueue.main.sync {
                        self.child.contentView.collectionView.reloadData()
                    }
                }
        })
    }
    
    @objc func handleTextChange() {
        let sender = contentView.searchBarContainer.searchBar
        contentView.searchBarContainer.showSearchClearButton()
        beginEditing()
        child.inSearchMode = true
        
        guard let text = sender.text, !text.isEmpty else {
            contentView.searchBarContainer.showSearchClearButton(false)
            contentView.searchBarContainer.filtersButton.isHidden = false
            removeChild(popViewController: false)
            return
        }
        
        contentView.searchBarContainer.filtersButton.isHidden = true
        filterSubjects(text)
    }
    
    func beginEditing() {
        guard child.view?.superview == nil else { return }
        addChild(child)
        child.needDismissWhenPush = needDismissWhenPush
        child.scrollViewDraggedClosure = {
            self.contentView.searchBarContainer.searchBar.endEditing(true)
        }
        contentView.insertSubview(child.view, at: 1)
        child.view.anchor(top: contentView.searchBarContainer.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.getBottomAnchor(), right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        child.didMove(toParent: self)
        contentView.searchBarContainer.showSearchClearButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.searchBarContainer.searchBar.resignFirstResponder()
        return true
    }
}

extension QuickSearchVC: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }

}

extension QuickSearchVC: QuickSearchCategoryCellDelegate {
    func quickSearchCategoryCell(_ cell: QuickSearchCategoryCell, didSelect subcategory: String, at indexPath: IndexPath) {
        let vc = CategorySearchVC()
        AnalyticsService.shared.logSubcategoryTapped(subcategory)
        vc.subcategory = subcategory
        vc.searchFilter = searchFilter
        vc.navigationItem.title = subcategory
        
        if needDismissWhenPush {
            var controllers = self.navigationController?.viewControllers
            controllers?.removeLast()
            controllers?.append(vc)
            guard let viewControllers = controllers else { return }
            self.navigationController?.setViewControllers(viewControllers, animated: true)
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func quickSeachCateogryCell(_ cell: QuickSearchCategoryCell, needsHeight height: CGFloat) {
        let section = contentView.collectionView.indexPath(for: cell)?.section ?? -1
        sectionHeights[section] = height
        contentView.collectionView.reloadSections(IndexSet(arrayLiteral: section))
    }
}

extension QuickSearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            header.icon.layer.borderColor = Colors.purple.cgColor
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

extension QuickSearchVC: CustomSearchBarDelegate {
    func customSearchBarDidTapClearButton(_ searchBar: PaddedTextField) {
        
    }
    
    func customSearchBarDidTapLeftView(_ searchBar: PaddedTextField) {
        
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldBeginEditing: Bool) {
        
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldEndEditing: Bool) {
        removeChild(popViewController: true)
    }
    
    func customSearchBarDidTapFiltersButton(_ searchBar: PaddedTextField) {
        let vc = FiltersVC()
        vc.hidesBottomBarWhenPushed = true
        vc.searchFilter = searchFilter
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func customSearchBarDidTapCancelEditButton(_ searchBar: PaddedTextField) {
        removeChild(popViewController: true)
    }
    
    func removeChild(popViewController: Bool) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        guard popViewController else { return }
        navigationController?.popViewController(animated: false)
    }
}
