//
//  QTLearnerDiscoverCategoriesTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverCategoriesTableViewCell: UITableViewCell {

    var didSelectCategory: ((_ category: Category) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintCollectionViewHeight: NSLayoutConstraint!
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverCategoriesTableViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        
        constraintCollectionViewHeight.constant = getCategoryCellHeight()
    }

    private func getCategoryCellHeight() -> CGFloat {
        let width = ceil((UIScreen.main.bounds.width - 50) / 2.5)
        return width * 18 / 13 + 8
    }
    
}

extension QTLearnerDiscoverCategoriesTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        cell.label.text = categories[indexPath.row].mainPageData.displayName
        if let imageUrl = QTGlobalData.shared.categories[categories[indexPath.row].mainPageData.name]?.imageUrl {
            cell.imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(color: Colors.gray))
        } else {
            cell.imageView.image = UIImage(color: Colors.gray)
        }
        return cell
    }
}

extension QTLearnerDiscoverCategoriesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = ceil((UIScreen.main.bounds.width - 50) / 2.5)
        return CGSize(width: width, height: getCategoryCellHeight())
    }
}

extension QTLearnerDiscoverCategoriesTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.growSemiShrink {
            self.didSelectCategory?(Category.categories[indexPath.item])
        }
    }
}
