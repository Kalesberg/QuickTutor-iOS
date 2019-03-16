//
//  ProfileVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import MessageUI

class ProfileVC: UIViewController {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.gray
        cv.allowsMultipleSelection = false
        cv.register(ProfileCVCell.self, forCellWithReuseIdentifier: "cellId")
        cv.register(ProfileVCFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerCell")
        cv.register(ProfileVCHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        cv.isScrollEnabled = false
        return cv
    }()
    
    let cellTitles = ["Payment", "Settings", "Legal", "Help", "Leave a review", "Give us feedback"]
    let cellImages = [UIImage(named: "cardIconProfile"), UIImage(named: "settingsIcon"), UIImage(named: "fileIcon"), UIImage(named: "questionMarkIcon"), UIImage(named: "thumbsUpIcon"), UIImage(named: "feedbackIcon")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.barTintColor = Colors.darkBackground
        navigationController?.navigationBar.backgroundColor = Colors.darkBackground
        view.backgroundColor = Colors.newBackground
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ProfileCVCell
        cell.titleLabel.text = cellTitles[indexPath.item]
        cell.icon.image = cellImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (collectionView.frame.height - 175) / 7
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerCell", for: indexPath) as! ProfileVCFooterCell
            footer.delegate = self
            return footer
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as! ProfileVCHeaderCell
            header.parentViewController = self
            header.didClickProfileHeader = {
                self.showMyProfile()
            }
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let height = (collectionView.frame.height - 175) / 7
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            showPayment()
        case 1:
            showSettings()
        case 2:
            showLegal()
        case 3:
            showHelp()
        case 4:
            showRatingView()
        case 5:
            showFeedback()
        default:
            navigationController?.pushViewController(InviteOthersVC(), animated: true)
        }
    }
    
    func showMyProfile() {
        if AccountService.shared.currentUserType == .learner {
            let controller = QTProfileViewController.controller
            let tutor = CurrentUser.shared.tutor ?? AWTutor(dictionary: [:])
            controller.user = tutor.copy(learner: CurrentUser.shared.learner)
            controller.profileViewType = .myLearner
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = QTProfileViewController.controller
            controller.user = CurrentUser.shared.tutor
            controller.profileViewType = .myTutor
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showPayment() {
        let vc = AccountService.shared.currentUserType == .learner ? CardManagerVC() : BankManager()
        navigationItem.hidesBackButton = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSettings() {
        navigationController?.pushViewController(QTSettingsViewController.controller, animated: true)
    }
    
    func showLegal() {
        let next = WebViewVC()
        next.navigationItem.title = "Terms of Service"
        next.url = "https://www.quicktutor.com/legal/terms-of-service"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    func showHelp() {
        let vc = AccountService.shared.currentUserType == .learner ? LearnerHelpVC() : TutorHelp()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showShop() {
        let next = WebViewVC()
        next.navigationItem.title = "Shop"
        next.url = "https://www.quicktutor.com/shop"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    func showRatingView() {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
    
    func showFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["contact@quicktutor.com"])
            mail.setMessageBody("<p>Thanks for reaching out. Please leave your feedback below:\n</p>", isHTML: true)
            present(mail, animated: true)
        }
    }
    
    func inviteOthers() {
        navigationController?.pushViewController(InviteOthersVC(), animated: true)
    }
    
}

extension ProfileVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension ProfileVC: ProfileModeToggleViewDelegate {
    func profleModeToggleView(_ profileModeToggleView: MockCollectionViewCell, shouldSwitchTo side: UserType) {
        side == .learner ? switchToLearner() : switchToTutor()
    }
    
    func switchToLearner() {
        RootControllerManager.shared.configureRootViewController(controller: LearnerMainPageVC())
    }
    
    func switchToTutor() {
        if CurrentUser.shared.learner.isTutor {
            displayLoadingOverlay()
            prepareForSwitchToTutor { success in
                if success {
                    AccountService.shared.currentUserType = .tutor
                    self.dismissOverlay()
                    RootControllerManager.shared.configureRootViewController(controller: QTTutorDashboardViewController.controller)
                }
            }
        } else {
            AccountService.shared.currentUserType = .tRegistration
            navigationController?.pushViewController(BecomeTutorVC(), animated: true)
        }
    }
    
    private func prepareForSwitchToTutor(_ completion: @escaping (Bool) -> Void) {
        FirebaseData.manager.fetchTutor(CurrentUser.shared.learner.uid!, isQuery: false) { tutor in
            guard let tutor = tutor else {
                AlertController.genericErrorAlert(self, title: "Oops!", message: "Unable to find your tutor account! Please try again.")
                return completion(false)
            }
            CurrentUser.shared.tutor = tutor
            Stripe.retrieveConnectAccount(acctId: tutor.acctId, { error, account in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                    return completion(false)
                } else if let account = account {
                    CurrentUser.shared.connectAccount = account
                    return completion(true)
                }
            })
        }
    }

}

extension ProfileVC: ProfileVCFooterCellDelegate {
    func profileVCFooterCell(_ cell: ProfileVCFooterCell, didTap button: UIButton) {
        inviteOthers()
    }
}
