//
//  QTLearnerDiscoverRecentlyActiveViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

public enum QTCarouselFlowLayoutSpacingMode {
    case fixed(spacing: CGFloat)
    case overlap(visibleOffset: CGFloat)
}

class QTCollectionViewFlowLayout: UICollectionViewFlowLayout {
    fileprivate struct LayoutState {
        var size: CGSize
        var direction: UICollectionView.ScrollDirection
        func isEqual(_ otherState: LayoutState) -> Bool {
            return size.equalTo(otherState.size) && direction == otherState.direction
        }
    }
    
    @IBInspectable open var sideItemScale: CGFloat = 0.6
    @IBInspectable open var sideItemAlpha: CGFloat = 0.6
    @IBInspectable open var sideItemShift: CGFloat = 0.0
    @IBInspectable open var swipeVelocityThreshold: CGFloat = 0.2
    
    open var spacingMode = QTCarouselFlowLayoutSpacingMode.fixed(spacing: 40)
    
    fileprivate var state = LayoutState(size: CGSize.zero, direction: .horizontal)
    
    override open func prepare() {
        super.prepare()
        let currentState = LayoutState(size: collectionView!.bounds.size, direction: scrollDirection)
        
        if !state.isEqual(currentState) {
            setupCollectionView()
            updateLayout()
            state = currentState
        }
    }
    
    fileprivate func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        
        if .fast != collectionView.decelerationRate {
            collectionView.decelerationRate = .fast
        }
    }
    
    fileprivate func updateLayout() {
        guard let collectionView = collectionView else { return }
        
        let collectionSize = collectionView.bounds.size
        let isHorizontal = scrollDirection == .horizontal
        
        let yInset = (collectionSize.height - itemSize.height) / 2
        let xInset = (collectionSize.width - itemSize.width) / 2
        
        let side = isHorizontal ? itemSize.width : itemSize.height
        let scaledItemOffset = (side - side * sideItemScale) / 2
        switch spacingMode {
        case .fixed(let spacing):
            minimumLineSpacing = spacing - scaledItemOffset
        case .overlap(let visibleOffset):
            let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
            let inset = isHorizontal ? xInset : yInset
            minimumLineSpacing = inset - fullSizeSideItemOverlap
        }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
            let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
            else { return nil }
        return attributes.map({ transformLayoutAttributes($0) })
    }
    
    fileprivate func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView else { return attributes }
        let isHorizontal = scrollDirection == .horizontal
        
        let collectionCenter = isHorizontal ? collectionView.frame.size.width/2 : collectionView.frame.size.height/2
        let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset
        
        let maxDistance = (isHorizontal ? itemSize.width : itemSize.height) + minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance)/maxDistance
        
        let alpha = ratio * (1 - sideItemAlpha) + sideItemAlpha
        let scale = ratio * (1 - sideItemScale) + sideItemScale
        let shift = (1 - ratio) * sideItemShift
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 10)
        
        if isHorizontal {
            attributes.center.y = attributes.center.y + shift
        } else {
            attributes.center.x = attributes.center.x + shift
        }
        
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView , !collectionView.isPagingEnabled,
            let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds)
            else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        
        let isHorizontal = scrollDirection == .horizontal
        
        let hasEnoughVelocity = abs(isHorizontal ? velocity.x : velocity.y) > swipeVelocityThreshold
        let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
        let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide
        
        var targetContentOffset: CGPoint
        if isHorizontal {
            let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
            if hasEnoughVelocity {
                if 0 < velocity.x {
                    if targetContentOffset.x < proposedContentOffset.x,
                        targetContentOffset.x + closest.bounds.size.width < collectionView.contentSize.width {
                        targetContentOffset.x += closest.bounds.size.width
                    }
                } else {
                    if targetContentOffset.x > proposedContentOffset.x,
                        targetContentOffset.x > closest.bounds.size.width {
                        targetContentOffset.x -= closest.bounds.size.width
                    }
                }
            }
        } else {
            let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
            if 0 < velocity.y {
                if targetContentOffset.y < proposedContentOffset.y,
                    targetContentOffset.y + closest.bounds.size.height < collectionView.contentSize.height {
                    targetContentOffset.y += closest.bounds.size.height
                }
            } else {
                if targetContentOffset.y > proposedContentOffset.y,
                    targetContentOffset.y > closest.bounds.size.height {
                    targetContentOffset.y -= closest.bounds.size.height
                }
            }
        }
        
        return targetContentOffset
    }
}

class QTLearnerDiscoverRecentlyActiveViewController: UIViewController {
    
    var delegate: QTLearnerDiscoverRecentlyActiveDelegate?
    var category: Category?
    var subcategory: String?
        
    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    var didClickBtnMessage: ((_ tutor: AWTutor) -> ())?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var aryActiveTutors: [AWTutor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.register(ConnectionCell.self, forCellWithReuseIdentifier: ConnectionCell.reuseIdentifier)
                
        if let layout = collectionView.collectionViewLayout as? QTCollectionViewFlowLayout {
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 30, height: 60)
            layout.spacingMode = .fixed(spacing: 0)
        }
        
        collectionView.prepareSkeleton { _ in
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.showAnimatedSkeleton(usingColor: Colors.gray)
            self.loadRecentlyActiveTutors()
        }
    }
    
    private func loadRecentlyActiveTutors() {
        TutorSearchService.shared.fetchRecentlyActiveTutors(category: category?.mainPageData.name, subcategory: subcategory) { tutors in
            let group = DispatchGroup()
            tutors.forEach { tutor in
                group.enter()
                ConnectionService.shared.getConnectionStatus(partnerId: tutor.uid) { connected in
                    tutor.isConnected = connected
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                if self.collectionView.isSkeletonActive {
                    self.collectionView.hideSkeleton()
                    self.collectionView.isUserInteractionEnabled = true
                }
                self.aryActiveTutors = tutors
                self.delegate?.onDidUpdateRecentlyActive(tutors)
                self.collectionView.reloadData()
            }
        }
    }
}
    
extension QTLearnerDiscoverRecentlyActiveViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return ConnectionCell.reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryActiveTutors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConnectionCell.reuseIdentifier, for: indexPath) as! ConnectionCell
        cell.updateUI(user: aryActiveTutors[indexPath.item])
        cell.updateToMainFeedLayout()
        cell.delegate = self
        
        return cell
    }
}

extension QTLearnerDiscoverRecentlyActiveViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConnectionCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConnectionCell else { return }
        cell.growSemiShrink {
            self.didClickTutor?(self.aryActiveTutors[indexPath.item])
        }
    }
}

extension QTLearnerDiscoverRecentlyActiveViewController: ConnectionCellDelegate {
    func connectionCell(_ connectionCell: ConnectionCell, shouldShowConversationWith user: User) {
        guard let tutor = user as? AWTutor else { return }
        didClickBtnMessage?(tutor)
    }
    
    func connectionCell(_ connectionCell: ConnectionCell, shouldRequestSessionWith user: User) {
        
    }
}
