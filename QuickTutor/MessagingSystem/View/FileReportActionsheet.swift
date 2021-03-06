//
//  FileReportActionsheet.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class FileReportActionsheet: UIView {
    
    var titles = ["Share profile", "Schedule Session", "Disconnect", "Report"]
    var images = [UIImage(named: "fileReportShareIcon"), UIImage(named: "sessionsTabBarIcon"), UIImage(named: "fileReportDisconnectIcon"), UIImage(named: "fileReportFlag")]
    var tutorTitles = ["Disconnect", "Report"]
    var tutorImages = [UIImage(named: "fileReportDisconnectIcon"), UIImage(named: "fileReportFlag")]
    
    var parentViewController: UIViewController?
    var bottomLayoutMargin: CGFloat = 0
    var actionSheetBottomAnchor: NSLayoutConstraint?
    var alert: CustomModal?
    var reportTypeModal: ReportTypeModal?
    var partnerId: String?
    var name: String!
    var username: String!
    var panelHeight: CGFloat = 250
    var subject: String?
    
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

    let backgroundBlur: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    let actionSheetBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.newScreenBackground
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.text = "Options"
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "closeCircle"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(FileReportActionsheetCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = UIColor(hex: "131317")
        cv.layer.cornerRadius = 8
        cv.isScrollEnabled = false
        if #available(iOS 11.0, *) {
            cv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        return cv
    }()

    func prepareActionSheetData() {
        if isTutorSheet {
            if isConnected {
                guard tutorTitles.count == 1 && tutorImages.count == 1 else {
                    panelHeight = 150
                    return
                }
                tutorTitles.insert("Disconnect", at: 0)
                tutorImages.insert(UIImage(named: "fileReportDisconnectIcon"), at: 0)
                panelHeight = 150
                collectionView.reloadData()
            } else {
                guard tutorTitles.count == 2 && tutorImages.count == 2 else {
                    panelHeight = 100
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
                titles.insert("Schedule Session", at: 2)
                images.insert(UIImage(named: "fileReportDisconnectIcon"), at: 1)
                images.insert(UIImage(named: "sessionsTabBarIcon"), at: 2)
                panelHeight = 250
                collectionView.reloadData()
            } else {
                guard titles.count == 4 && images.count == 4 else { return }
                titles.remove(at: 1)
                titles.remove(at: 1)
                images.remove(at: 1)
                images.remove(at: 1)
                panelHeight = 150
                collectionView.reloadData()
            }
        }
        
    }
    
    func setupViews() {
        setupBackgroundBlur()
        setupActionsheetBackground()
        setupTitleLabel()
        setupDismissButton()
        setupCollectionView()
    }

    func setupBackgroundBlur() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(backgroundBlur)
        backgroundBlur.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundBlur.addGestureRecognizer(dismissTap)
    }

    func setupActionsheetBackground() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(actionSheetBackground)
        actionSheetBackground.frame = CGRect(x: 0, y: window.frame.height - bottomLayoutMargin, width: window.frame.width, height: panelHeight)
        window.bringSubviewToFront(actionSheetBackground)
    }
    
    func setupTitleLabel() {
        actionSheetBackground.addSubview(titleLabel)
        titleLabel.anchor(top: actionSheetBackground.topAnchor, left: actionSheetBackground.leftAnchor, bottom: nil, right: actionSheetBackground.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func setupDismissButton() {
        actionSheetBackground.addSubview(dismissButton)
        dismissButton.anchor(top: actionSheetBackground.topAnchor, left: nil, bottom: nil, right: actionSheetBackground.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 40, height: 40)
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }

    func setupCollectionView() {
        actionSheetBackground.addSubview(collectionView)
        collectionView.anchor(top: actionSheetBackground.topAnchor, left: actionSheetBackground.leftAnchor, bottom: actionSheetBackground.bottomAnchor, right: actionSheetBackground.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func show() {
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.actionSheetBackground.transform = CGAffineTransform(translationX: 0, y: -self.panelHeight)
            self.backgroundBlur.alpha = 1
            self.layoutIfNeeded()
        }.startAnimation()
    }

    @objc func dismiss() {
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.layoutIfNeeded()
            self.actionSheetBackground.transform = CGAffineTransform(translationX: 0, y: self.panelHeight)
            self.backgroundBlur.alpha = 0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "actionSheetDismissed"), object: nil)
        }
        animator.addCompletion { _ in
        }
        animator.startAnimation()
    }

    func handleReportButton() {
        guard let id = partnerId else { return }
        reportTypeModal = ReportTypeModal()
        reportTypeModal?.chatPartnerId = id
        reportTypeModal?.show()
        dismiss()
    }
    
    func handleDisconnectButton() {
        dismiss()
		if let name = name {
			alert = DisconnectModal(title: "Disconnect", message: "Are you sure?", note: "You will be disconnected from \(name).", cancelText: "Never mind", confirmText: "Yes, disconnect")
		} else {
			alert = DisconnectModal(title: "Disconnect", message: "Are you sure?", note: "You will be disconnected from this tutor.", cancelText: "Never mind", confirmText: "Yes, disconnect")
		}
		
        guard let disconnectModal = alert as? DisconnectModal, let id = partnerId else { return }
        disconnectModal.partnerId = id
        disconnectModal.show()
    }
    
    func handleCancelButton() {
        dismiss()
    }
    
    func shareUsernameForUserId() {

        dismiss()
        
        guard let id = partnerId else { return }
        guard let username = self.name, let subject = self.subject else {
            return
        }
        
        var image: UIImage?
        if let vc = self.parentViewController as? ConversationVC {
            image = vc.sharedProfileView.asImage()
        } else if let vc = self.parentViewController as? QTProfileViewController {
            image = vc.sharedProfileView.asImage()
        }
        
        guard let data = image?.jpegData(compressionQuality: 1.0) else { return }
        
        self.parentViewController?.displayLoadingOverlay()
        FirebaseData.manager.uploadProfilePreviewImage(tutorId: id, data: data) { (error, url) in
            if let message = error?.localizedDescription {
                DispatchQueue.main.async {
                    if let vc = self.parentViewController {
                        vc.dismissOverlay()
                        AlertController.genericErrorAlert(vc, message: message)
                    }
                }
                return
            }
            
            DynamicLinkFactory.shared.createLink(userId: id, userName: username, subject: subject, profilePreviewUrl: url) { shareUrl in
                guard let shareUrlString = shareUrl?.absoluteString else {
                    DispatchQueue.main.async {
                        self.parentViewController?.dismissOverlay()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.parentViewController?.dismissOverlay()
                    let ac = UIActivityViewController(activityItems: [shareUrlString], applicationActivities: nil)
                    self.parentViewController?.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
    func requestSession() {
        dismiss()
        guard let id = partnerId else { return }
        FirebaseData.manager.fetchRequestSessionData(uid: id) { requestData in
            let vc = SessionRequestVC()
            FirebaseData.manager.fetchTutor(id, isQuery: false, { (tutorIn) in
                guard let tutor = tutorIn else { return }
                vc.tutor = tutor
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    func removeBlurViews() {
        backgroundBlur.removeFromSuperview()
        actionSheetBackground.removeFromSuperview()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
	init(bottomLayoutMargin: CGFloat, name: String) {
        super.init(frame: .zero)
		self.name = name
        self.bottomLayoutMargin = bottomLayoutMargin
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FileReportActionsheet: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension FileReportActionsheet: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isTutorSheet ? (isConnected ? 2 : 1) : (isConnected ? 4 : 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! FileReportActionsheetCell
        if isTutorSheet {
            cell.button.setTitle(tutorTitles[indexPath.item], for: .normal)
            cell.button.setImage(tutorImages[indexPath.item], for: .normal)
        } else {
            cell.button.setTitle(titles[indexPath.item], for: .normal)
            cell.button.setImage(images[indexPath.item], for: .normal)
        }
        
        cell.button.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cell.delegate = self
        cell.tag = indexPath.item
        return cell
    }
}

extension FileReportActionsheet: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }

}

extension FileReportActionsheet: FileReportActionsheetCellDelegate {
    func fileReportActionSheetCellDidSelect(_ fileReportActionSheetCell: FileReportActionsheetCell) {
        
        if isTutorSheet {
            
            if isConnected {
                switch fileReportActionSheetCell.tag {
                case 0:
                    handleDisconnectButton()
                case 1:
                    handleReportButton()
                default:
                    break
                }
            } else {
                switch fileReportActionSheetCell.tag {
                case 0:
                    
                    handleReportButton()
                default:
                    break
                }
            }
        } else {
            
            if isConnected {
                switch fileReportActionSheetCell.tag {
                case 0:
                    
                    shareUsernameForUserId()
                case 1:
                    requestSession()
                case 2:
                    handleDisconnectButton()
                case 3:
                    handleReportButton()
                default:
                    break
                }
            } else {
                switch fileReportActionSheetCell.tag {
                case 0:
                    
                    shareUsernameForUserId()
                case 1:
                    handleReportButton()
                default:
                    break
                }
            }
        }
    }
}
