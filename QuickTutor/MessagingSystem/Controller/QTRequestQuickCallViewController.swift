//
//  QTRequestQuickCallViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/10/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Cosmos

class QTRequestQuickCallViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var quickCallPriceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var totalReviewsLabel: UILabel!
    @IBOutlet weak var callButton: QTCustomButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    static var controller: QTRequestQuickCallViewController {
        return QTRequestQuickCallViewController(nibName: String(describing: QTRequestQuickCallViewController.self), bundle: nil)
    }
    
    // Paramters
    var tutor: AWTutor!
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    // Variables
    var subject: String?
    var addPaymentModal: AddPaymentModal?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()

        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        initUserInfo()
        initSubjects()
    }
    
    // MARK: - Actions
    @IBAction func onCloseButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCallButtonClicked(_ sender: Any) {
        // Request a quick call.
        
        currentUserHasPayment { (hasPayment) in
            guard hasPayment else { return }
            
            var session = [String: Any] ()
            let price: Double = self.tutor.quickCallPrice < 5 ? 5.0 : Double(self.tutor.quickCallPrice ?? 0)
            guard let subject = self.subject, let uid = Auth.auth().currentUser?.uid else { return }
            
            let now = Date()
            session["subject"] = subject
            session["date"] = now.timeIntervalSince1970
            session["startTime"] = now.timeIntervalSince1970
            session["endTime"] = now.adding(minutes: 15).timeIntervalSince1970
            session["type"] = QTSessionType.quickCalls.rawValue
            session["price"] = price
            session["status"] = "accepted"
            session["senderId"] = uid
            session["receiverId"] = self.tutor.uid
            session["paymentType"] = QTSessionPaymentType.hour.rawValue
            session["duration"] = 60 * 60 // 1 hour
            guard let _ = session["subject"], let _ = session["date"], let _ = session["startTime"], let _ = session["endTime"], let _ = session["type"], let _ = session["price"] else {
                return
            }
            let sessionRequest = SessionRequest(data: session)
            DataService.shared.sendQuickCallRequestToId(sessionRequest: sessionRequest, self.tutor.uid, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    // MARK: - Functions
    func setupDelegates() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PillCollectionViewCell.self, forCellWithReuseIdentifier: PillCollectionViewCell.reuseIdentifier)
        let layout = AlignedCollectionViewFlowLayout(
            horizontalAlignment: .left,
            verticalAlignment: .center
        )
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
        collectionView.isUserInteractionEnabled = true
    }
    
    func initUserInfo() {
        callButton.layer.cornerRadius = 3
        callButton.clipsToBounds = true
        callButton.setupTargets()
        callButton.isEnabled = false
        callButton.backgroundColor = Colors.gray
        
        guard let price = tutor.quickCallPrice else { return }
        quickCallPriceLabel.text = "\(tutor.firstName ?? "")'s QuickCall rate is $\(price)/hr."
        usernameLabel.text = tutor.formattedName
        ratingView.rating = tutor.tRating
        totalReviewsLabel.text = "\(tutor.reviews?.count ?? 0)"
        
        UserFetchService.shared.getUserWithId(tutor.uid, type: .tutor) { (tutor) in
            self.avatarImageView.sd_setImage(with: tutor?.profilePicUrl)
        }
    }
    
    func initSubjects() {
        guard let _ = tutor else { return }
        collectionView.reloadData()
    }
    
    func updateSubjectsHeight() {
        collectionViewHeight.constant = collectionView.contentSize.height
        collectionView.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    func currentUserHasPayment(completion: @escaping (Bool) -> Void) {
        guard AccountService.shared.currentUserType == .learner else {
            completion(true)
            return
        }
        
        guard CurrentUser.shared.learner.hasPayment else {
            completion(false)
            self.addPaymentModal = AddPaymentModal()
            self.addPaymentModal?.delegate = self
            self.addPaymentModal?.show()
            return
        }
        
        completion(true)
    }
}

// MARK: - UICollectionViewDelegate
extension QTRequestQuickCallViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        subject = tutor.subjects?[indexPath.row]
        callButton.isEnabled = true
        callButton.backgroundColor = Colors.purple
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension QTRequestQuickCallViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 60
        if let subjects = tutor.subjects {
            width = subjects[indexPath.item].estimateFrameForFontSize(14, extendedWidth: true).width + 20
        } else if let featuredSubject = tutor.featuredSubject {
            width = featuredSubject.estimateFrameForFontSize(14, extendedWidth: true).width + 20
        }
        return CGSize(width: width, height: 30)
    }
}

// MARK: - UICollectionViewDataSource
extension QTRequestQuickCallViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let subjects = tutor.subjects, subjects.count > 0 {
            return subjects.count
        } else if let featuredSubject = tutor.featuredSubject, !featuredSubject.isEmpty {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PillCollectionViewCell.reuseIdentifier, for: indexPath) as! PillCollectionViewCell
        if let subjects = tutor.subjects {
            cell.titleLabel.text = subjects[indexPath.item]
        } else if let featuredSubject = tutor.featuredSubject, !featuredSubject.isEmpty {
            cell.titleLabel.text = featuredSubject
        }
        updateSubjectsHeight()
        return cell
    }
}

// MARK: - CustomModalDelegate
extension QTRequestQuickCallViewController: CustomModalDelegate {
    func handleNevermind() {}
    
    func handleConfirm() {
        let next = CardManagerViewController()
        next.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    func handleCancel(id: String) {
        
    }
}
