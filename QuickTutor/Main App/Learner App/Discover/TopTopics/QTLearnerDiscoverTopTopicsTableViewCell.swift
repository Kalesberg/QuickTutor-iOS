//
//  QTLearnerDiscoverTopTopicsTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

enum QTLearnerDiscoverTopicType {
    case inperson, recommended, online
}

extension QTLearnerDiscoverTopicType {
    var topics: [QTLearnerDiscoverTopicInterface] {
        switch self {
        case .inperson:
            return ["Astronomy", "Baking", "Bartending", "Behavioral Management", "Card Games", "Cooking", "Dancing", "Drawing", "Fishing", "Fitness", "Hiking", "Hunting", "Painting", "Public Speaking", "Resistance Training", "Travel Help", "Wrestling"].map({ QTLearnerDiscoverTopicInterface(topic: $0) })
        case .recommended:
            return ["Advertising", "Algebra", "Break Pads", "Communications", "Dating Advice", "ESL", "Essays", "Fortnite", "Poetry", "Self-Care"].map({ QTLearnerDiscoverTopicInterface(topic: $0) })
        case .online:
            return ["Accounting", "Acting", "C++", "Calclus", "Chemistry", "Cosmetology", "Financial Accounting", "Fortnite", "Guitar", "Hair Styling", "HTML", "Life Motivation", "Makeup", "Mathematics", "Motivation", "Nutrition", "Physics", "Singing", "Spanish (Speaking)"].map({ QTLearnerDiscoverTopicInterface(topic: $0) })
        }
    }
    
    var settings: QTLearnerDiscoverTopicSettings {
        switch self {
        case .inperson, .online:
            return QTLearnerDiscoverTopicSettings(font: .qtHeavyFont(size: 20),
                                                  size: CGSize(width: ceil((UIScreen.main.bounds.width - 35) / 1.1), height: 180))
        case .recommended:
            return QTLearnerDiscoverTopicSettings(font: .qtHeavyFont(size: 17),
                                                  size: CGSize(width: ceil((UIScreen.main.bounds.width - 50) / 2.2), height: 180))
        }
    }
}

class QTLearnerDiscoverTopicInterface {
    var topic: String!
    var image: UIImage!
    
    init(topic: String, image: UIImage? = nil) {
        self.topic = topic
        if let image = image {
            self.image = image
        } else {
            self.image = UIImage(named: topic)
        }
    }
}

class QTLearnerDiscoverTopicSettings {
    var font: UIFont!
    var size: CGSize!
    
    init(font: UIFont, size: CGSize) {
        self.font = font
        self.size = size
    }
}

class QTLearnerDiscoverTopTopicsTableViewCell: UITableViewCell {
    
    var topicSettings: QTLearnerDiscoverTopicSettings!
    var aryTopics: [QTLearnerDiscoverTopicInterface] = []
    var didClickTopic: ((_ topic: String) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintCollectionHeight: NSLayoutConstraint!
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTLearnerDiscoverTopTopicsTableViewCell.self), bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
    }
    
}

extension QTLearnerDiscoverTopTopicsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryTopics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        cell.label.text = aryTopics[indexPath.row].topic
        cell.label.font = topicSettings.font
        cell.imageView.image = aryTopics[indexPath.row].image
        
        return cell
    }
}

extension QTLearnerDiscoverTopTopicsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return topicSettings.size
    }
}

extension QTLearnerDiscoverTopTopicsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        cell.growSemiShrink {
            self.didClickTopic?(self.aryTopics[indexPath.item].topic)
        }
    }
}
