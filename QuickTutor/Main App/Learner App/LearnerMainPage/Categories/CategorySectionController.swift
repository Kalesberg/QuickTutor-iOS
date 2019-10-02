//
//  CategorySectionController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class CategorySectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 15
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addObservers()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            removeObservers()
        }
        super.didMove(toParent: parent)
    }
    
    
    func setupViews() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 180)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedRefershDiscoverPage),
                                               name: NotificationNames.TutorDiscoverPage.refreshDiscoverPage,
                                               object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc
    func onReceivedRefershDiscoverPage() {
        DataService.shared.getCategoriesInfo {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        cell.label.text = categories[indexPath.row].mainPageData.displayName
        if let imagePath = QTGlobalData.shared.categories[categories[indexPath.row].mainPageData.name]?.imageUrl, let imageUrl = URL(string: imagePath)  {
            cell.imageView.setImage(url: imageUrl)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.growSemiShrink {
            let category = CategoryFactory.shared.getCategoryFor(categories[indexPath.item].subcategory.fileToRead)
            let userInfo = ["category": category?.name ?? ""]
            
            if AccountService.shared.currentUserType == UserType.tutor {
                NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.tutorCategoryTapped,
                                                object: nil,
                                                userInfo: userInfo)
            } else {
                NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.categoryTapped,
                                                object: nil,
                                                userInfo: userInfo)
            }
        }
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 180)
    }
    
}
