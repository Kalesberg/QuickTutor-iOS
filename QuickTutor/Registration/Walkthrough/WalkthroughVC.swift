//
//  WalkthroughVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class WalkthroughVC: UIViewController {
    
    let contentView: WalkthroughVCView = {
        let view = WalkthroughVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class WalkthroughVCView: UIView {
    
    let images = [UIImage(named: "walkthroughSearch"), UIImage(named: "walkthroughReachOut"), UIImage(named: "walkthroughInPersonOnline"), UIImage(named: "walkthoughBecomeTutor")]
    let titles = ["SEARCH", "REACH OUT", "IN-PERSON AND ONLINE", "BECOME a QuickTutor"]
    let subtitles = ["Find your tutor.\nThousands of experts await!","Connect with tutors, message them\nand request a session with just a few taps!", "Meet up for in-person sessions or hop on a video\ncall. The app takes care of session timing, billing,\nand payments — automatically.", "Start turning your knowledge into\n dollars and get paid today.\nTeach up to thirty different subjects."]
    let logoView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "qt-small-text")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let collectionView: UICollectionView = {
        let layout = DurationCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.showsHorizontalScrollIndicator = false
        cv.register(WalkthroughCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 4
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = Colors.gray
        control.currentPage = 0
        return control
    }()
    
    let nextButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setTitle("GET STARTED", for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupLogoView()
        setupNextButton()
        setupPageControl()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupLogoView() {
        addSubview(logoView)
        logoView.anchor(top: getTopAnchor(), left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 30)
        addConstraint(NSLayoutConstraint(item: logoView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupNextButton() {
        addSubview(nextButton)
        nextButton.anchor(top: nil, left: nil, bottom: getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 0, width: 145, height: 45)
        addConstraint(NSLayoutConstraint(item: nextButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        nextButton.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
    }
    
    func setupPageControl() {
        addSubview(pageControl)
        pageControl.anchor(top: nil, left: leftAnchor, bottom: nextButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 0, width: 0, height: 15)
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: logoView.bottomAnchor, left: leftAnchor, bottom: pageControl.topAnchor, right: rightAnchor, paddingTop: 60, paddingLeft: 00, paddingBottom: 35, paddingRight: 0, width: 0, height: 1000)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc func handleButton(_ sender: UIButton) {
        guard pageControl.currentPage != 3 else {
            RootControllerManager.shared.configureRootViewController(controller: SignInVC())
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage + 1, section: 0), at: .centeredHorizontally, animated: true)
        sender.setTitle("NEXT", for: .normal)
        pageControl.currentPage += 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WalkthroughVCView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! WalkthroughCell
        cell.imageView.image = images[indexPath.item]
        cell.titleLabel.text = titles[indexPath.item]
        cell.infoLabel.text = subtitles[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 400)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        var indexes = self.collectionView.indexPathsForVisibleItems
        indexes.sort()
        var index = indexes.first!
        let cell = self.collectionView.cellForItem(at: index)!
        let position = self.collectionView.contentOffset.x - cell.frame.origin.x
        if position > cell.frame.size.width/2 {
            index.row = index.row + 1
        }
        self.collectionView.scrollToItem(at: index, at: .left, animated: true )
        self.pageControl.currentPage = index.item
    }
    
}

class WalkthroughCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBlackSize(18)
        label.text = "SEARCH"
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = Colors.registrationGray
        label.font = Fonts.createSize(16)
        label.text = "Find your tutor.\nThousands of experts await!"
        return label
    }()
    
    func setupViews() {
        setupImageView()
        setupInfoLabel()
        setupTitleLabel()
    }
    
    func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 54, paddingBottom: 50, paddingRight: 54, width: 0, height: 0)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: infoLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 22)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
