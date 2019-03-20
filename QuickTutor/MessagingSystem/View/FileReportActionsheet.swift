//
//  FileReportActionsheet.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class FileReportActionsheet: UIView {
    
    var titles = ["Share profile", "Disconnect", "Report"]
    var images = [UIImage(named: "fileReportShareIcon"), UIImage(named: "fileReportDisconnectIcon"), UIImage(named: "fileReportFlag")]
    var parentViewController: UIViewController?
    var bottomLayoutMargin: CGFloat = 0
    var actionSheetBottomAnchor: NSLayoutConstraint?
    var alert: CustomModal?
    var reportTypeModal: ReportTypeModal?
    var partnerId: String?
    var name: String!
    var panelHeight: CGFloat = 200
    
    var isConnected = true {
        didSet {
            if isConnected {
                guard titles.count == 2 && images.count == 2 else { return }
                titles.insert("Disconnect", at: 1)
                images.insert(UIImage(named: "fileReportDisconnectIcon"), at: 1)
                panelHeight = 200
                collectionView.reloadData()
            } else {
                guard titles.count == 3 && images.count == 3 else { return }
                titles.remove(at: 1)
                images.remove(at: 1)
                panelHeight = 150
                collectionView.reloadData()
            }
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
        view.backgroundColor = Colors.darkBackground
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
    }
    
    func setupTitleLabel() {
        actionSheetBackground.addSubview(titleLabel)
        titleLabel.anchor(top: actionSheetBackground.topAnchor, left: actionSheetBackground.leftAnchor, bottom: nil, right: actionSheetBackground.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func setupDismissButton() {
        actionSheetBackground.addSubview(dismissButton)
        dismissButton.anchor(top: actionSheetBackground.topAnchor, left: nil, bottom: nil, right: actionSheetBackground.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 20, height: 20)
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
            self.layoutIfNeeded()
            self.actionSheetBackground.transform = CGAffineTransform(translationX: 0, y: -self.panelHeight)
            self.backgroundBlur.alpha = 1
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
        DynamicLinkFactory.shared.createLink(userId: id) { shareUrl in
            guard let shareUrlString = shareUrl?.absoluteString else { return }
            let ac = UIActivityViewController(activityItems: [shareUrlString], applicationActivities: nil)
            self.parentViewController?.present(ac, animated: true, completion: nil)
        }
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
        return isConnected ? 3 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! FileReportActionsheetCell
        cell.button.setTitle(titles[indexPath.item], for: .normal)
        cell.button.setImage(images[indexPath.item], for: .normal)
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
        if isConnected {
            switch fileReportActionSheetCell.tag {
            case 0:
                shareUsernameForUserId()
            case 1:
                handleDisconnectButton()
            case 2:
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
