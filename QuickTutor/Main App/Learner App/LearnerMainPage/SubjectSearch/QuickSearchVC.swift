//
//  SearchSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import CoreLocation
import UIKit

protocol UpdatedFiltersCallback {
    func filtersUpdated(filters: Filters)
}

struct Filters {
    let distance: Int?
    let price: Int?
    let sessionType: Bool
    let location: CLLocation?

    init(distance: Int?, price: Int?, inPerson: Bool, location: CLLocation?) {
        self.distance = distance
        self.price = price
        sessionType = inPerson
        self.location = location
    }
}

class QuickSearchVC: UIViewController {
    
    var connectedTutor: AWTutor!
    var sectionHeights = [Int: CGFloat]()

    var categories: [Category] = [.academics, .business, .lifestyle, .language,  .arts,  .sports, .health, .tech, .outdoors, .auto, .trades,  .remedial]

    var filters: Filters?

    var searchTimer = Timer()
    var automaticScroll: Bool = false
    var shouldUpdateSearchResults = false

    var inlineCellIndexPath: IndexPath?
    
    let child = QuickSearchResultsVC()

    var filteredSubjects = [(String, String)]()

    var allSubjects = [(String, String)]()

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
//        contentView.searchBar.becomeFirstResponder()

        if let subjects = SubjectStore.loadTotalSubjectList() {
            allSubjects = subjects
            allSubjects.shuffle()
        }
        contentView.searchBarContainer.searchBar.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.searchBarContainer.searchBar.becomeFirstResponder()
    }

    private func configureDelegates() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.searchBarContainer.delegate = self
    }
}

extension QuickSearchVC: UpdatedFiltersCallback {
    func filtersUpdated(filters: Filters) {
        self.filters = filters
    }
}

extension QuickSearchVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contentView.searchBarContainer.shouldBeginEditing()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        beginEditing()
        child.inSearchMode = true
        guard let text = textField.text, !text.isEmpty else { return true}
        child.filteredSubjects = child.subjects.filter({ $0.0.range(of: text, options: .caseInsensitive) != nil }).sorted(by: { $0.0.count < $1.0.count })
        child.contentView.collectionView.reloadData()
        return true
    }
    
    func beginEditing() {
        guard child.view?.superview == nil else { return }
        addChild(child)
        contentView.addSubview(child.view)
        child.view.anchor(top: contentView.searchBarContainer.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.getBottomAnchor(), right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        child.didMove(toParent: self)
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
        vc.subcategory = subcategory
        vc.navigationItem.title = subcategory.capitalized
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
    func customSearchBarDidTapLeftView(_ searchBar: PaddedTextField) {
        
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldBeginEditing: Bool) {
        
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldEndEditing: Bool) {
        removeChild()
    }
    
    func removeChild() {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        navigationController?.popViewController(animated: false)
    }
}