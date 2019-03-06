//
//  TrendingCategories.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

struct TopSubcategory {
    var subcategory = ""
    let hours: Int
    let numSessions: Int
    let rating: Double
    let subjects: String
    
    init(dictionary: [String: Any]) {
        hours = dictionary["hr"] as? Int ?? 0
        numSessions = dictionary["nos"] as? Int ?? 0
        rating = dictionary["r"] as? Double ?? 0.0
        subjects = dictionary["sbj"] as? String ?? ""
    }
}


class TrendingCategoriesView: UIView {
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let customLayout = CategorySearchCollectionViewLayout(cellsPerRow: 2, minimumInteritemSpacing: 5, minimumLineSpacing: 50, sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
        customLayout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 70)
        collectionView.collectionViewLayout = customLayout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    func configureView() {
        addSubview(collectionView)
        backgroundColor = Colors.darkBackground
    }

    func applyConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TrendingCategories: BaseViewController {
    override var contentView: TrendingCategoriesView {
        return view as! TrendingCategoriesView
    }

    override func loadView() {
        view = TrendingCategoriesView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "trendingCell")
        contentView.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        navigationItem.title = "Trending"
    }
}

extension TrendingCategories: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)

            let label = UILabel()
            label.text = "Top Categories"
            label.textColor = .white
            label.font = Fonts.createBoldSize(20)
            headerView.addSubview(label)
            label.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.9)
                make.center.equalToSuperview()
            }

            return headerView
        }
        fatalError()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as! CategoryCollectionViewCell

        cell.label.text = categories[indexPath.item].mainPageData.displayName
        cell.imageView.image = categories[indexPath.item].mainPageData.image

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.growSemiShrink {
            let next = CategoryInfo()
            next.category = categories[indexPath.item]
            self.navigationController?.pushViewController(next, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.shrink()
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        let width = (screen.width / 2) - 25
        let height = (screen.height / 3)

        return CGSize(width: width, height: height)
    }
}
