//
//  QTTutorDiscoverNewsViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

protocol QTTutorDiscoverNewsViewControllerDelegate {
    func didScrollToIndex(index: Int)
    func numberOfNews(number: Int)
}

class QTTutorDiscoverNewsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var newses = [QTNewsModel]()
    var currentIndex = -1
    var delegate: QTTutorDiscoverNewsViewControllerDelegate?
    
    // MARK: - Functions
    func configureViews() {
        
        // Register cells
        collectionView.register(QTTutorDiscoverNewsCollectionViewCell.nib, forCellWithReuseIdentifier: QTTutorDiscoverNewsCollectionViewCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func setupSkeletonView() {
        self.view.isSkeletonable = true
        
        collectionView.prepareSkeleton { (completed) in
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            FirebaseData.manager.getNews(completion: { data in
                if self.collectionView.isSkeletonActive {
                    self.collectionView.hideSkeleton()
                }
                self.newses = data
                self.delegate?.numberOfNews(number: data.count)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }
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
        newses.removeAll()
        collectionView.reloadData()
        setupSkeletonView()
    }
    
    // MARK: - Lifeyclce
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureViews()
        setupSkeletonView()
        addObservers()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            removeObservers()
        }
        super.didMove(toParent: parent)
    }
}

// MARK: - UICollectionViewDelegate
extension QTTutorDiscoverNewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.view.isSkeletonActive {
            return
        }
        
        // TODO: Go to news view controller
    }
}

// MARK: - UICollectionViewDataSource
extension QTTutorDiscoverNewsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTTutorDiscoverNewsCollectionViewCell.reuseIdentifier, for: indexPath) as! QTTutorDiscoverNewsCollectionViewCell
        cell.setData(news: newses[indexPath.row])
        cell.didReadButtonClickedHandler = { news in
            NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.newsItemTapped, object: nil, userInfo: ["news" : news])
        }
        return cell
    }
}

extension QTTutorDiscoverNewsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        return CGSize(width: width, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension QTTutorDiscoverNewsViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTTutorDiscoverNewsCollectionViewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}

extension QTTutorDiscoverNewsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        if index != currentIndex {
            currentIndex = index
            delegate?.didScrollToIndex(index: currentIndex)
        }
    }
}
