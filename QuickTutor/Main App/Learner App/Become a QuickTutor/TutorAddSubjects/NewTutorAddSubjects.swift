//
//  NewTutorAddSubjects.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class TutorAddSubjectsVC: UIViewController {
    
    var isViewing = false {
        didSet {
            let bottomPadding: CGFloat = isViewing ? 0 : 90
            contentView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0)
        }
    }
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
        TutorRegistrationService.shared.shouldSaveSubjects = isViewing
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
        contentView.accessoryView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    }
    
    @objc func handleNext() {
        navigationController?.pushViewController(TutorPreferencesVC(), animated: true)
    }
}

extension TutorAddSubjectsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

extension TutorAddSubjectsVC: CustomSearchBarDelegate {
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

extension TutorAddSubjectsVC: UITextFieldDelegate {
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

extension TutorAddSubjectsVC: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension TutorAddSubjectsVC: QuickSearchCategoryCellDelegate {
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
