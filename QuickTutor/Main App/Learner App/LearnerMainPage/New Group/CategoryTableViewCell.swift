//
//  CategoryCollectionView.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

protocol CategoryTableViewCellDelegate: class {
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelect category: CategoryNew)
}

class CategoryTableViewCell: UITableViewCell {
    
    weak var delegate: CategoryTableViewCellDelegate?

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0)
        return collectionView
    }()

    var view: UIView!

    func configureTableViewCell() {
        addSubview(collectionView)

        backgroundColor = .clear

        view = self

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "categoryCell")

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

    func snapToCenter() {
        let centerPoint = view.convert(view.center, to: collectionView)
        guard let centerIndexPath = collectionView.indexPathForItem(at: centerPoint) else { return }
        collectionView.scrollToItem(at: centerIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CategoryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        cell.label.text = categories[indexPath.row].mainPageData.displayName
        cell.imageView.image = categories[indexPath.row].mainPageData.image
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.growSemiShrink {
            let category = CategoryFactory.shared.getCategoryFor(categories[indexPath.item].subcategory.fileToRead)
            self.delegate?.categoryTableViewCell(self, didSelect: category!)
        }
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 142)
    }
}

extension CategoryTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToCenter()
        }
    }

    func scrollViewDidEndDecelerating(_: UIScrollView) {
        snapToCenter()
    }
}
