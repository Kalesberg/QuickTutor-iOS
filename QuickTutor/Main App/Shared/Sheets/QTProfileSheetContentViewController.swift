//
//  QTProfileSheetContentViewController.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/10/5.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Sheet

class QTProfileSheetContentViewController: SheetContentsViewController {
    
    private var titles = ["Share profile", "Request Session", "Disconnect", "Report"]
    private var images = [UIImage(named: "fileReportShareIcon"), UIImage(named: "sessionsTabBarIcon"), UIImage(named: "fileReportDisconnectIcon"), UIImage(named: "fileReportFlag")]
    private var tutorTitles = ["Disconnect", "Report"]
    private var tutorImages = [UIImage(named: "fileReportDisconnectIcon"), UIImage(named: "fileReportFlag")]
    
    private var alert: CustomModal?
    private var reportTypeModal: ReportTypeModal?
    
    var name: String?
    var partnerId: String?
    var subject: String?
    var parentVC: UIViewController?
    var panelHeight: CGFloat = 250
    
    var isConnected = true {
        didSet {
            prepareActionSheetData()
        }
    }
    
    var isTutorSheet = false {
        didSet {
            prepareActionSheetData()
        }
    }
    
    var dismissHandler: ((_ type:Int) -> ())?
    
    static var controller: QTProfileSheetContentViewController {
        return QTProfileSheetContentViewController(nibName: String(describing: QTProfileSheetContentViewController.self), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func registCollectionElement() {
        collectionView?.register(QTProfileSheetTitleViewCell.nib, forCellWithReuseIdentifier: QTProfileSheetTitleViewCell.reuseIdentifier)
        collectionView?.register(QTProfileSheetContentViewCell.nib, forCellWithReuseIdentifier: QTProfileSheetContentViewCell.reuseIdentifier)
    }
    
    override func setupSheetLayout(_ layout: SheetContentsLayout) {
        layout.settings.itemSize = { indexPath in
            if indexPath.item == 0 {
                return CGSize(width: UIScreen.main.bounds.width, height: 60)
            }
            return CGSize(width: UIScreen.main.bounds.width, height: 50)
        }
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isTutorSheet ? (isConnected ? 3 : 2) : (isConnected ? 5 : 2)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTProfileSheetTitleViewCell.reuseIdentifier, for: indexPath) as! QTProfileSheetTitleViewCell
            cell.didClickClose = {
                self.dismiss()
                self.dismissHandler?(0)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTProfileSheetContentViewCell.reuseIdentifier, for: indexPath) as! QTProfileSheetContentViewCell
            cell.delegate = self
            if isTutorSheet {
                cell.button.setTitle(tutorTitles[indexPath.item - 1], for: .normal)
                cell.button.setImage(tutorImages[indexPath.item - 1], for: .normal)
            } else {
                cell.button.setTitle(titles[indexPath.item - 1], for: .normal)
                cell.button.setImage(images[indexPath.item - 1], for: .normal)
            }
            return cell
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let velocity = scrollView.panGestureRecognizer.velocity(in: nil)
        if scrollView.contentOffset.y <= -10/* && velocity.y >= 100*/ {
            dismiss()
            dismissHandler?(0)
        }
    }
    
    
    
    // MARK: - Event Handlers
    private func dismiss () {
        dismiss(animated: true, completion: nil)
    }
    
    private func onClickDisconnectButton() {
        dismiss()
        if let name = name {
            alert = DisconnectModal(title: "Disconnect", message: "Are you sure?", note: "You will be disconnected from \(name).", cancelText: "Never mind", confirmText: "Yes, disconnect")
        } else {
            alert = DisconnectModal(title: "Disconnect", message: "Are you sure?", note: "You will be disconnected from this tutor.", cancelText: "Never mind", confirmText: "Yes, disconnect")
        }
        
        guard let disconnectModal = alert as? DisconnectModal, let id = partnerId else { return }
        disconnectModal.partnerId = id
        disconnectModal.show()
        
        dismissHandler?(1)
    }
    
    private func onClickReportButton() {
        guard let id = partnerId else { return }
        reportTypeModal = ReportTypeModal()
        reportTypeModal?.chatPartnerId = id
        reportTypeModal?.show()
        reportTypeModal?.parentVC = parentVC
        dismiss()
        dismissHandler?(2)
    }
    
    private func shareUsernameForUserId() {
        dismiss()
        dismissHandler?(0)
        
        guard let id = partnerId else { return }
        guard let username = self.name, let subject = self.subject else {
            return
        }
        
        var image: UIImage?
        if let vc = self.parentVC as? QTProfileViewController {
            image = vc.sharedProfileView.asImage()
        }
        if let vc = self.parentVC as? ConversationVC  {
            image = vc.sharedProfileView.asImage()
        }
        
        guard let data = image?.jpegData(compressionQuality: 1.0) else { return }
        
        self.parentVC?.displayLoadingOverlay()
        FirebaseData.manager.uploadProfilePreviewImage(tutorId: id, data: data) { (error, url) in
            if let message = error?.localizedDescription {
                DispatchQueue.main.async {
                    if let vc = self.parentVC {
                        
                        vc.dismissOverlay()
                        AlertController.genericErrorAlert(vc, message: message)
                    }
                }
                return
            }
            
            DynamicLinkFactory.shared.createLink(userId: id, userName: username, subject: subject, profilePreviewUrl: url) { shareUrl in
                guard let shareUrlString = shareUrl?.absoluteString else {
                    DispatchQueue.main.async {
                        
                        self.parentVC?.dismissOverlay()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.parentVC?.dismissOverlay()
                    let ac = UIActivityViewController(activityItems: [shareUrlString], applicationActivities: nil)
                    self.parentVC?.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func requestSession() {
        dismiss()
        dismissHandler?(0)
        guard let id = partnerId else { return }
        FirebaseData.manager.fetchRequestSessionData(uid: id) { requestData in
            let vc = SessionRequestVC()
            FirebaseData.manager.fetchTutor(id, isQuery: false, { (tutorIn) in
                guard let tutor = tutorIn else { return }
                vc.tutor = tutor
                self.parentVC?.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    
    // MARK: - Prepare Data Handler
    private func prepareActionSheetData() {
        if isTutorSheet {
            if isConnected {
                guard tutorTitles.count == 1 && tutorImages.count == 1 else {
                    panelHeight = 180
                    return
                }
                tutorTitles.insert("Disconnect", at: 0)
                tutorImages.insert(UIImage(named: "fileReportDisconnectIcon"), at: 0)
                panelHeight = 180
                collectionView.reloadData()
            } else {
                guard tutorTitles.count == 2 && tutorImages.count == 2 else {
                    panelHeight = 130
                    return
                }
                tutorTitles.remove(at: 0)
                tutorImages.remove(at: 0)
                collectionView.reloadData()
            }
        } else {
            if isConnected {
                guard titles.count == 2 && images.count == 2 else { return }
                titles.insert("Disconnect", at: 1)
                titles.insert("Request Session", at: 2)
                images.insert(UIImage(named: "fileReportDisconnectIcon"), at: 1)
                images.insert(UIImage(named: "sessionsTabBarIcon"), at: 2)
                panelHeight = 280
                collectionView.reloadData()
            } else {
                guard titles.count == 4 && images.count == 4 else { return }
                titles.remove(at: 1)
                titles.remove(at: 1)
                images.remove(at: 1)
                images.remove(at: 1)
                panelHeight = 180
                collectionView.reloadData()
            }
        }
    }
}

extension QTProfileSheetContentViewController: QTProfileSheetContentViewCellDelegate {
    func profileSheetContentViewDidSelect(_ contentViewCell: QTProfileSheetContentViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: contentViewCell) else { return }
        
        if isTutorSheet {
        
            if isConnected {
                switch indexPath.item - 1 {
                case 0:
                    onClickDisconnectButton()
                case 1:
                    onClickReportButton()
                default:
                    break
                }
            } else {
                switch indexPath.item - 1 {
                case 0:
                    onClickReportButton()
                default:
                    break
                }
            }
        } else {
            
            if isConnected {
                switch indexPath.item - 1 {
                case 0:
                    shareUsernameForUserId()
                case 1:
                    requestSession()
                case 2:
                    onClickDisconnectButton()
                case 3:
                    onClickReportButton()
                default:
                    break
                }
            } else {
                
                switch indexPath.item - 1 {
                case 0:
                    shareUsernameForUserId()
                case 1:
                    onClickReportButton()
                default:
                    break
                }
            }
        }
    }
}
