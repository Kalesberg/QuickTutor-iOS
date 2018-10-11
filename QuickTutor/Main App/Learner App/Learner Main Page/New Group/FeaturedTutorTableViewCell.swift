//
//  LearnerMainPageTableView.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class FeaturedTutorTableViewCell: UITableViewCell {
    var sectionIndex: Int! {
        didSet {
            print(sectionIndex)

            collectionView.reloadData()
        }
    }

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0

        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var view: UIView!

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
}

extension FeaturedTutorTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return spotlights[category[sectionIndex - 1]]!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell

        cell.price.text = spotlights[category[sectionIndex - 1]]![indexPath.item].price
        cell.featuredTutor.namePrice.text = spotlights[category[sectionIndex - 1]]![indexPath.item].name
        cell.featuredTutor.region.text = spotlights[category[sectionIndex - 1]]![indexPath.item].region
        cell.featuredTutor.subject.text = spotlights[category[sectionIndex - 1]]![indexPath.item].topic

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
        if let current = UIApplication.getPresentedViewController() {
            current.present(TutorConnect(), animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        let width = (screen.width / 3) - 13
        let height = collectionView.frame.height - 15
        return CGSize(width: width, height: height)
    }
}
