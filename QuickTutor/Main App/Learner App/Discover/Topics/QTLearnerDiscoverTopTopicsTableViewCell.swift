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
            return ["Advertising", "Algebra", "Break Pads", "Communications", "Computer Programming", "Dating Advice", "ESL", "Essays", "Fortnite", "Poetry", "Self-Care"].map({ QTLearnerDiscoverTopicInterface(topic: $0) })
        case .online:
            return ["Accounting", "Acting", "C++", "Calclus", "Chemistry", "Cosmetology", "Financial Accounting", "Fortnite", "Guitar", "Hair Styling", "HTML", "Life Motivation", "Makeup", "Mathematics", "Motivation", "Nutrition", "Physics", "Singing", "Spanish (Speaking)"].map({ QTLearnerDiscoverTopicInterface(topic: $0) })
        }
    }
}

class QTLearnerDiscoverTopicInterface {
    var topic: String!
    var image: UIImage!
    
    init(topic: String) {
        self.topic = topic
        self.image = UIImage(named: topic)
    }
}

class QTLearnerDiscoverTopTopicsTableViewCell: UITableViewCell {
    
    var type: QTLearnerDiscoverTopicType = .inperson
    var didClickTopic: ((_ topic: String) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        return type.topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        cell.label.text = type.topics[indexPath.row].topic
        if .recommended == type {
            cell.label.font = .qtHeavyFont(size: 17)
        } else {
            cell.label.font = .qtHeavyFont(size: 20)
        }
        cell.imageView.image = type.topics[indexPath.row].image
        
        return cell
    }
}

extension QTLearnerDiscoverTopTopicsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        var width: CGFloat
        switch type {
        case .inperson, .online:
            width = ceil((UIScreen.main.bounds.width - 35) / 1.1)
        case .recommended:
            width = 180
        }
        
        return CGSize(width: width, height: 180)
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
            self.didClickTopic?(self.type.topics[indexPath.item].topic)
        }
    }
}
