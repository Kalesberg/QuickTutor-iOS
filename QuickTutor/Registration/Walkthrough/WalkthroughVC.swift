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
        automaticallyAdjustsScrollViewInsets = false
    }
    
}

class WalkthroughVCView: UIView {
    
    let images = [UIImage(named: "walkthroughSearch"),
                  UIImage(named: "walkthroughReachOut"),
                  UIImage(named: "walkthroughInPersonOnline"),
                  UIImage(named: "walkthoughBecomeTutor"),
                  UIImage(named: "img_walkthrough_bg")]
    let titles = ["Learn Anything.\nTeach Anyone.",
                  "Reach Out",
                  "Online And In-person",
                  "Become a QuickTutor",
                  ""]
    let subtitles = ["",
                     "Connect with tutors, message them\nand request a session with just a few taps!",
                     "Meet up for in-person sessions or hop on a video\ncall. The app takes care of session timing, billing,\nand payments — automatically.",
                     "Start turning your knowledge into\n dollars and get paid today.\nTeach up to twenty different subjects.",
                    ""]
    
    let nextButtonTitles = ["Next", "Next", "Next", "Ok, got it", "Get started"]
    
    let logoView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ic_icon_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let collectionView: UICollectionView = {
        let layout = DurationCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.register(WalkthroughCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 5
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = Colors.gray
        control.currentPage = 0
        return control
    }()
    
    let nextButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setTitle("NEXT", for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()
    
    func setupViews() {
        setupCollectionView()
        setupMainView()
        setupLogoView()
        setupNextButton()
        setupPageControl()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupLogoView() {
        addSubview(logoView)
        logoView.anchor(top: getTopAnchor(), left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 183, height: 39)
        addConstraint(NSLayoutConstraint(item: logoView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupNextButton() {
        addSubview(nextButton)
        nextButton.anchor(top: nil, left: nil, bottom: getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 0, width: 220, height: 45)
        addConstraint(NSLayoutConstraint(item: nextButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        nextButton.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
    }
    
    func setupPageControl() {
        addSubview(pageControl)
        pageControl.anchor(top: nil, left: leftAnchor, bottom: nextButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 0, width: 0, height: 15)
    }
    
    @objc func handleButton(_ sender: UIButton) {
        guard pageControl.currentPage != 4 else {
            UserDefaults.standard.setValue(true, forKey: "hasBeenOnboarded")
            RootControllerManager.shared.configureRootViewController(controller: SignInVC())
            return
        }
        self.nextButton.setTitle(nextButtonTitles[pageControl.currentPage + 1].uppercased(), for: .normal)
        collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage + 1, section: 0), at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
        if pageControl.currentPage == 4 {
            pageControl.isHidden = true
            collectionView.isScrollEnabled = false
        }
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
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! WalkthroughCell
        if indexPath.row == 4 {
            cell.imageView.isHidden = true
            cell.fullImageView.isHidden = false
            cell.fullImageView.image = images[indexPath.item]
        } else {
            cell.imageView.isHidden = false
            cell.fullImageView.isHidden = true
            cell.imageView.image = images[indexPath.item]
        }
        
        cell.titleLabel.text = titles[indexPath.item]
        cell.infoLabel.text = subtitles[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        self.pageControl.currentPage = currentPage
        self.nextButton.setTitle(nextButtonTitles[currentPage].uppercased(), for: .normal)
        if currentPage == 4 {
            pageControl.isHidden = true
            collectionView.isScrollEnabled = false
        }
    }
    
}

class WalkthroughCell: UICollectionViewCell {
    
    let fullImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBlackSize(18)
        label.text = "SEARCH"
        label.numberOfLines = 0
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
        setupFullImageView()
        setupImageView()
        setupInfoLabel()
        setupTitleLabel()
    }
    
    func setupFullImageView() {
        addSubview(fullImageView)
        fullImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 400, paddingLeft: 0, paddingBottom: 257, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 175, paddingRight: 0, width: 0, height: 60)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: infoLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
