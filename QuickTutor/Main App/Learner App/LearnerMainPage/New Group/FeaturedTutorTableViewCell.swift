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

protocol FeaturedTutorTableViewCellDelegate {
    func featuredTutorTableViewCell(_ featuredTutorTableViewCell: FeaturedTutorTableViewCell, didSelect featuredTutor: FeaturedTutor)
    func featuredTutorTableViewCell(_ featuredTutorTableViewCell: FeaturedTutorTableViewCell, didSelect cell: TutorCollectionViewCell)
}

class FeaturedTutorTableViewCell: UITableViewCell {

	let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    var delegate: FeaturedTutorTableViewCellDelegate?

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        return collectionView
    }()

	var parentViewController : UIViewController? = nil
	
    let itemsPerBatch: UInt = 8
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
        collectionView.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")
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
                let startIndex = self.datasource.count
                self.collectionView.performBatchUpdates({
                    self.datasource.append(contentsOf: tutors)
                    let insertPaths = Array(startIndex..<self.datasource.count).map { IndexPath(item: $0, section: 0) }
                    self.collectionView.insertItems(at: insertPaths)
                }, completion: { _ in
                    self.didLoadMore = false
                })
            }
        })
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeaturedTutorTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! TutorCollectionViewCell
        cell.updateUI(datasource[indexPath.item])
        return cell
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
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if indexPath.item == self.datasource.count - 2 && !didLoadMore {
			self.didLoadMore = true
			pageMoreTutors()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        cell.growSemiShrink {
            let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
            self.delegate?.featuredTutorTableViewCell(self, didSelect: cell)
            self.delegate?.featuredTutorTableViewCell(self, didSelect: self.datasource[indexPath.item])
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
        return CGSize(width: (screen.width / 2.5) - 13, height: collectionView.frame.height - 20)
    }
    
	func pageMoreTutors() {
		queryTutorsByCategory(lastKnownKey: datasource[datasource.endIndex - 1].uid)
		self.didLoadMore = false
	}
}
