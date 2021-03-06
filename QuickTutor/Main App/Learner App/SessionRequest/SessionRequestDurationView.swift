//
//  SessionRequestDurationView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol SessionRequestDurationViewDelegate: class {
    func sessionRequestDurationView(_ durationView: SessionRequestDurationView, didSelect duration: Int)
}

class SessionRequestDurationView: BaseSessionRequestViewSection {
    
    var timeIncrements: [Any] {
        get {
            var increments:[Any] = ["", "", ""]
            for i in stride(from: 5, through: 120, by: 5) {
                increments.append(i)
            }
            for i in stride(from: 135, through: 720, by: 15) {
                increments.append(i)
            }
            increments.append(contentsOf: ["", "", ""])
            return increments
        }
    }
    
    weak var delegate: SessionRequestDurationViewDelegate?
    
    let collectionView: UICollectionView = {
        let layout = DurationCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = UIScrollView.DecelerationRate.fast
        cv.register(DurationCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderColor = Colors.gray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    let selectionLabel: UILabel = {
        let label = UILabel()
        label.text = "mins"
        label.textColor = .white
        label.font = Fonts.createSize(12)
        label.textAlignment = .center
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        setupCollectionView()
        setupSelectionView()
        setupSelectionLabel()
        titleLabel.text = "How long would you like it to be?"
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 90)
        collectionView.contentOffset = CGPoint(x: 200, y: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSelectionView() {
        addSubview(selectionView)
        selectionView.anchor(top: collectionView.topAnchor, left: nil, bottom: collectionView.bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 50, height: 50)
        addConstraint(NSLayoutConstraint(item: selectionView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupSelectionLabel() {
        addSubview(selectionLabel)
        selectionLabel.anchor(top: selectionView.bottomAnchor, left: selectionView.leftAnchor, bottom: nil, right: selectionView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 14)
    }
    
    func setDuration(duration: Int, animated: Bool = true) {
        var incrementIndex = 6
        for (index, increment) in timeIncrements.enumerated() {
            if let item = increment as? Int {
                if item == duration {
                    incrementIndex = index
                    break
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            if self.collectionView.cellForItem(at: IndexPath(item: incrementIndex, section: 0)) != nil {
                self.collectionView.scrollToItem(at: IndexPath(item: incrementIndex, section: 0),
                                            at: .centeredHorizontally,
                                            animated: animated)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SessionRequestDurationView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeIncrements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! DurationCollectionViewCell
        cell.titleLabel.text = "\(timeIncrements[indexPath.item])"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestCell(collectionView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        snapToNearestCell(collectionView)
    }
    
    func snapToNearestCell(_ collectionView: UICollectionView) {
        let middlePoint = Int(collectionView.contentOffset.x + UIScreen.main.bounds.width / 2)
        if let indexPath = self.collectionView.indexPathForItem(at: CGPoint(x: middlePoint, y: 0)) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            let index = timeIncrements[indexPath.item] as? Int
            self.delegate?.sessionRequestDurationView(self, didSelect: index ?? 5)
        }
    }
    
}
