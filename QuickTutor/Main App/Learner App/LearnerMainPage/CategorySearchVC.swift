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
    override var contentView: CategorySearchVCView {
        return view as! CategorySearchVCView
    }

    override func loadView() {
        view = CategorySearchVCView()
    }

    let itemsPerBatch: UInt = 10

    var datasource = [FeaturedTutor]()
    var didLoadMore: Bool = false
    var allTutorsQueried: Bool = false

    var category: Category! {
        didSet {
            queryTutorsByCategory(lastKnownKey: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(FeaturedTutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")
        contentView.collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        contentView.searchBar.delegate = self
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
                self.allTutorsQueried = tutors.count != self.itemsPerBatch

                let startIndex = self.datasource.count
                self.datasource.append(contentsOf: tutors)
                let endIndex = self.datasource.count

                self.contentView.collectionView.performBatchUpdates({
                    let insertPaths = Array(startIndex ..< endIndex).map { IndexPath(item: $0, section: 0) }
                    self.contentView.collectionView.insertItems(at: insertPaths)
                }, completion: { _ in
                    self.didLoadMore = false
                    self.dismissOverlay()
                })
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func handleNavigation() {}
}

extension CategorySearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell

        cell.featuredTutor.imageView.sd_setImage(with: URL(string: datasource[indexPath.item].imageUrl))
        cell.price.text = datasource[indexPath.item].price.priceFormat()
        cell.featuredTutor.namePrice.text = datasource[indexPath.item].name
        cell.featuredTutor.region.text = datasource[indexPath.item].region
        cell.featuredTutor.subject.text = datasource[indexPath.item].subject

        let formattedString = NSMutableAttributedString()

        formattedString
            .bold("\(datasource[indexPath.item].rating) ", 14, Colors.gold)

        cell.featuredTutor.ratingLabel.attributedText = formattedString

        let formattedString2 = NSMutableAttributedString()

        formattedString2
            .regular("(\(datasource[indexPath.item].reviews) ratings)", 12, Colors.gold)

        cell.featuredTutor.numOfRatingsLabel.attributedText = formattedString2

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds

        if screen.height == 568 || screen.height == 480 {
            return CGSize(width: (screen.width / 2.5) - 13, height: 190)
        } else {
            return CGSize(width: (screen.width / 3) - 13, height: 190)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        cell.shrink()
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        cell.growSemiShrink {
            let next = TutorConnectVC()
            next.featuredTutorUid = self.datasource[indexPath.item].uid
            let nav = self.navigationController
            DispatchQueue.main.async {
                nav?.view.layer.add(CATransition().segueFromBottom(), forKey: nil)
                nav?.pushViewController(next, animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! SectionHeader
        cell.category.text = CategorySelected.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
}

extension CategorySearchVC: UISearchBarDelegate {
    internal func searchBarTextDidBeginEditing(_: UISearchBar) {
        navigationController?.pushViewController(SearchSubjectsVC(), animated: true)
    }
}

extension CategorySearchVC: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        if allTutorsQueried { return }

        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maximumOffset - currentOffset <= 100.0 {
            queryTutorsByCategory(lastKnownKey: datasource[datasource.endIndex - 1].uid)
        }
    }
}
