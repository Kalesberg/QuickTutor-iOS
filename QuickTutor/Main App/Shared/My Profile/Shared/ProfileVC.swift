//
//  ProfileVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.profileGray
        cv.allowsMultipleSelection = false
        cv.register(ProfileCVCell.self, forCellWithReuseIdentifier: "cellId")
        cv.register(ProfileVCFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerCell")
        cv.register(ProfileVCHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        cv.isScrollEnabled = false
        return cv
    }()
    
    let cellTitles = ["Payment", "Settings", "Legal", "Help", "Shop", "Give us feedback"]
    let cellImages = [UIImage(named: "cardIconProfile"), UIImage(named: "settingsIcon"), UIImage(named: "fileIcon"), UIImage(named: "questionMarkIcon"), UIImage(named: "cartIcon"), UIImage(named: "thumbsUpIcon")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        navigationController?.navigationBar.isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: nil, action: nil)
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
            return footer
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as! ProfileVCHeaderCell
            header.parentViewController = self
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
            showShop()
        default:
            navigationController?.pushViewController(InviteOthersVC(), animated: true)
        }
    }
    
    func showPayment() {
        let vc = AccountService.shared.currentUserType == .learner ? CardManagerVC() : BankManager()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSettings() {
        navigationController?.pushViewController(SettingsVC(), animated: true)
    }
    
    func showLegal() {
        let next = WebViewVC()
        next.contentView.title.label.text = "Terms of Service"
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
        next.contentView.title.label.text = "Shop"
        next.url = "https://www.quicktutor.com/shop"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    func inviteOthers() {
        navigationController?.pushViewController(InviteOthersVC(), animated: true)
    }
    
}

extension ProfileVC: ProfileModeToggleViewDelegate {
    func profleModeToggleView(_ profileModeToggleView: ProfileModeToggleView, shouldSwitchTo side: UserType) {
        let vc = side == .learner ? LearnerMainPageVC() : TutorMainPage()
        RootControllerManager.shared.configureRootViewController(controller: vc)
    }
}
