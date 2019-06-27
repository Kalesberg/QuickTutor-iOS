//
//  SavedTutorsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SavedTutorsVC: UIViewController {
    
    var datasource = [AWTutor]()
    
    let refreshControl = UIRefreshControl()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceHorizontal = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    var emptyBackground: EmptySavedTutorsBackground = {
        return EmptySavedTutorsBackground()
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        return view
    }()
    
    let btnFindTutor: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.setTitle("Find tutors", for: .normal)
        button.titleLabel?.font = Fonts.createSemiBoldSize(16)
        
        return button
    }()
    
    var collectionViewBottomMargin: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        setupCollectionView()
        setupEmptyBackground()
        setupFindTutorView()
        setupRefreshControl()
        setupObservers()
        loadSavedTutors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        navigationController?.setNavigationBarHidden(false, animated: true)
        loadSavedTutors()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.newScreenBackground
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Saved"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 61, paddingRight: 20, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadSavedTutors), name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    private func setupEmptyBackground() {
        emptyBackground.isHidden = true
        collectionView.addSubview(emptyBackground)
        emptyBackground.anchor(top: collectionView.getTopAnchor(), left: collectionView.leftAnchor, bottom: nil, right: collectionView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        emptyBackground.widthAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    private func setupFindTutorView() {
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -5, paddingRight: 0, width: 0, height: 61)
        view.layoutIfNeeded()
        containerView.clipsToBounds = true
        
        containerView.addSubview(btnFindTutor)
        btnFindTutor.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 61)
        containerView.layoutIfNeeded()
        
        btnFindTutor.addTarget(self, action: #selector(onClickBtnFindTutor), for: .touchUpInside)
    }
    
    func setupRefreshControl() {
        if #available(iOS 11.0, *) {
            // Extend the view to the top of screen.
            self.edgesForExtendedLayout = UIRectEdge.top
            self.extendedLayoutIncludesOpaqueBars = true
            self.navigationController?.navigationBar.isTranslucent = false
        }
        
        refreshControl.tintColor = Colors.purple
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshTutors), for: .valueChanged)
    }
    
    @objc
    func refreshTutors() {
        // Start the animation of refresh control
        self.refreshControl.layoutIfNeeded()
        self.refreshControl.beginRefreshing()
        
        loadSavedTutors()
        
        // End the animation of refersh control
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.refreshControl.endRefreshing()
            
            // Update the content offset of collection view for refersh control
            var top: CGFloat = 0
            if #available(iOS 11.0, *) {
                top = self.collectionView.adjustedContentInset.top
            }
            let y = CGFloat.maximum(self.refreshControl.frame.minY, 0) + top
            self.collectionView.setContentOffset(CGPoint(x: 0, y: -y), animated:true)
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func loadSavedTutors() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let myGroup = DispatchGroup()
        var tutors = [AWTutor]()
        
        Database.database().reference().child("saved-tutors").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let tutorIds = snapshot.value as? [String: Any] else {
                self.datasource.removeAll()
                self.collectionView.reloadData()
                return }
            tutorIds.forEach({ uid, _ in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        return
                    }
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutors.append(tutor)
                    }
                    myGroup.leave()
                })
            })
            myGroup.notify(queue: .main, execute: {
                tutors.sort(by: { (a1: AWTutor, a2: AWTutor) -> Bool in
                    a1.username.lexicographicallyPrecedes(a2.username)
                })
                
                self.datasource.removeAll()
                self.datasource = tutors
                self.collectionView.reloadData()
            })
        }
    }
    
    @objc
    private func onClickBtnFindTutor() {
        navigationController?.pushViewController(QuickSearchVC(), animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SavedTutorsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.emptyBackground.isHidden = !datasource.isEmpty

        
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TutorCollectionViewCell
        cell.updateUI(datasource[indexPath.item])
        cell.profileImageViewHeightAnchor?.constant = 160
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        return CGSize(width: (screen.width - 60) / 2, height: 225)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        cell.shrink()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
        cell.growSemiShrink {
            let featuredTutor = self.datasource[indexPath.item]
            let uid = featuredTutor.uid
            FirebaseData.manager.fetchTutor(uid!, isQuery: false, { (tutor) in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller
                controller.subject = featuredTutor.featuredSubject
                controller.profileViewType = .tutor
                controller.user = tutor
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

protocol TutorDataSource {
    var tutor: AWTutor? { get set }
}

class LearnerMainPageAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let toView = toViewController.view!
        let finalFrame = toView.frame
        transitionContext.containerView.addSubview(toView)
        toView.frame = originFrame
        toView.alpha = 0
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1
            toView.frame = finalFrame
            toView.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}
