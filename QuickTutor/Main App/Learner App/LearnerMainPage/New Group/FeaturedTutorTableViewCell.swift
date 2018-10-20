//
//  LearnerMainPageTableView.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import SnapKit
import UIKit
import FirebaseUI

class FeaturedTutorTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()

    let itemsPerBatch: UInt = 8
    var allTutorsQueried: Bool = false
    var didLoadMore: Bool = false

    var datasource = [FeaturedTutor]() {
        didSet {
            collectionView.reloadData()
        }
    }

    var category: Category! {
        didSet {
            collectionView.reloadData()
        }
    }

    func configureTableViewCell() {
        addSubview(collectionView)

        backgroundColor = .clear

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FeaturedTutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")

        applyConstraints()
    }

    func applyConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func queryTutorsByCategory(lastKnownKey: String?) {
        QueryData.shared.queryAWTutorByCategory(category: category, lastKnownKey: lastKnownKey, limit: itemsPerBatch, { tutors in
            if let tutors = tutors {
                self.allTutorsQueried = tutors.count != self.itemsPerBatch

                let startIndex = self.datasource.count
                self.collectionView.performBatchUpdates({
                    self.datasource.append(contentsOf: tutors)
                    let endIndex = self.datasource.count

                    let insertPaths = Array(startIndex ..< endIndex).map { IndexPath(item: $0, section: 0) }
                    self.collectionView.insertItems(at: insertPaths)
                }, completion: { _ in
                    self.didLoadMore = false
                })
            }
        })
    }
}

extension FeaturedTutorTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell
		let reference = storageRef.child("featured").child(datasource[indexPath.item].uid).child("featuredImage")

        cell.price.text = datasource[indexPath.item].price.priceFormat()
        cell.view.backgroundColor = Colors.green
        cell.featuredTutor.imageView.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "placeholder-square"))
        cell.featuredTutor.namePrice.text = datasource[indexPath.item].name
        cell.featuredTutor.region.text = datasource[indexPath.item].region
        cell.featuredTutor.subject.text = datasource[indexPath.item].subject
        cell.featuredTutor.ratingLabel.attributedText = NSMutableAttributedString().bold("\(datasource[indexPath.item].rating) ", 14, Colors.gold)
		cell.featuredTutor.numOfRatingsLabel.attributedText = NSMutableAttributedString().regular("Rating", 13, Colors.gold)
		//cell.featuredTutor.numOfRatingsLabel.attributedText = NSMutableAttributedString().regular("(\(datasource[indexPath.item].reviews) ratings)", 13, Colors.gold)

        cell.layer.cornerRadius = 6
        cell.featuredTutor.applyDefaultShadow()

        return cell
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
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard !allTutorsQueried else { return }
		if indexPath.item == self.datasource.count - 2 && !didLoadMore {
			self.didLoadMore = true
			pageMoreTutors()
		}
	}
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        cell.growSemiShrink {
            let vc = TutorConnectVC()
            vc.featuredSubject = cell.featuredTutor.subject.text
            vc.featuredTutorUid = self.datasource[indexPath.item].uid
            vc.contentView.searchBar.placeholder = "\(self.category.mainPageData.displayName) • \(self.datasource[indexPath.item].subject)"
            let transition = CATransition()

            DispatchQueue.main.async {
                let nav = navigationController
                nav.view.layer.add(transition.segueFromBottom(), forKey: nil)
                nav.pushViewController(vc, animated: false)
            }
        }
    }

    func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        attributes?.alpha = 1.0
        attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        return attributes
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds

        if screen.height == 568 || screen.height == 480 {
            return CGSize(width: (screen.width / 2.5) - 13, height: collectionView.frame.height - 20)
        } else {
            return CGSize(width: (screen.width / 2.5) - 13, height: collectionView.frame.height - 20)
        }
    }
	func pageMoreTutors() {
		queryTutorsByCategory(lastKnownKey: datasource[datasource.endIndex - 1].uid)
		self.didLoadMore = false
	}
}
