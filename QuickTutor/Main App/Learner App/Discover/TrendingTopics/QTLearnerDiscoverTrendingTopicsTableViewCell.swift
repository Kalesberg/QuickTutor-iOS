//
//  QTLearnerDiscoverTrendingTopicsTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 10/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverTrendingTopicsTableViewCell: UITableViewCell {

    var didClickTopic: ((_ topic: String) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var aryTopics: [String] = []
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverTrendingTopicsTableViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(QTLearnerDiscoverTrendingTopicCollectionViewCell.nib, forCellWithReuseIdentifier: QTLearnerDiscoverTrendingTopicCollectionViewCell.reuseIdentifier)
    }

    func setTopics(_ topics: [String]) {
        aryTopics = topics
        collectionView.reloadData()
    }
}

extension QTLearnerDiscoverTrendingTopicsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryTopics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerDiscoverTrendingTopicCollectionViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTrendingTopicCollectionViewCell
        cell.lblTopic.text = aryTopics[indexPath.item]
        
        return cell
    }
}

extension QTLearnerDiscoverTrendingTopicsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topic = aryTopics[indexPath.item]
        let estimatedWidth = topic.estimateFrameForFontSize(12, extendedWidth: true).width + 20
        
        return CGSize(width: estimatedWidth > 50 ? estimatedWidth : 50, height: 34)
    }
}

extension QTLearnerDiscoverTrendingTopicsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTLearnerDiscoverTrendingTopicCollectionViewCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QTLearnerDiscoverTrendingTopicCollectionViewCell else { return }
        cell.growSemiShrink {
            self.didClickTopic?(self.aryTopics[indexPath.item])
        }
    }
}


