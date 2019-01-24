//
//  CategorySearch.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

struct CategorySelected {
    static var title: String!
}

class CategorySearchVC: BaseViewController {
    
//    enum SearchMode {
//        case category, subcategory, subject
//    }

    let itemsPerBatch: UInt = 10
    var datasource = [FeaturedTutor]()
    var didLoadMore: Bool = false
    var category: CategoryNew! {
        didSet {
            queryTutorsByCategory(lastKnownKey: nil)
        }
    }
    
    var subcategory: SubcategoryNew! {
        didSet {
            queryTutorsBySubcategory(lastKnownKey: nil)
        }
    }
    
    override var contentView: CategorySearchVCView {
        return view as! CategorySearchVCView
    }
    
    override func loadView() {
        view = CategorySearchVCView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")
        contentView.collectionView.register(CategorySearchSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isHidden = false
//        navigationItem.title = category
        navigationItem.title = "Arts"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.searchBar.resignFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.collectionView.reloadData()
    }

    private func queryTutorsByCategory(lastKnownKey: String?) {
        displayLoadingOverlay()
        QueryData.shared.queryAWTutorByCategory(category: category, lastKnownKey: lastKnownKey, limit: itemsPerBatch, { tutors in
            if let tutors = tutors {
                let startIndex = self.datasource.count
                self.datasource.append(contentsOf: tutors)
                let endIndex = self.datasource.count

                self.contentView.collectionView.performBatchUpdates({
                    let insertPaths = Array(startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                    self.contentView.collectionView.insertItems(at: insertPaths)
                }, completion: { _ in
                    self.didLoadMore = false
                    self.dismissOverlay()
                })
            }
        })
    }
    
    private func queryTutorsBySubcategory(lastKnownKey: String?) {
    }

}

extension CategorySearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! TutorCollectionViewCell
        cell.updateUI(datasource[indexPath.item])
        cell.profileImageViewHeightAnchor?.constant = 160
        cell.layoutIfNeeded()
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        return CGSize(width: (screen.width - 60) / 2, height: 225)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        cell.shrink()
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        cell.growSemiShrink {
            let featuredTutor = self.datasource[indexPath.item]
            let uid = featuredTutor.uid
            FirebaseData.manager.fetchTutor(uid, isQuery: false, { (tutor) in
                guard let tutor = tutor else { return }
                let vc = TutorCardVC()
                vc.subject = featuredTutor.subject
                vc.tutor = tutor
                vc.contentView.updateUI(tutor)
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
		}
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! CategorySearchSectionHeader
//        cell.category.text = CategorySelected.title
//        return cell
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 70)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension CategorySearchVC: UISearchBarDelegate {
    internal func searchBarTextDidBeginEditing(_: UISearchBar) {
        navigationController?.pushViewController(SearchSubjectsVC(), animated: true)
    }
}

extension CategorySearchVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
			
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            
            if maximumOffset - currentOffset <= 100.0 {
                queryTutorsByCategory(lastKnownKey: datasource[datasource.endIndex - 1].uid)
            }
            
        }
    }
}
