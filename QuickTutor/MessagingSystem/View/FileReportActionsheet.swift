//
//  FileReportActionsheet.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class FileReportActionsheet: UIView {
    
    let titles = ["Report", "Disconnect", "Cancel"]
    var bottomLayoutMargin: CGFloat!
    var actionSheetBottomAnchor: NSLayoutConstraint?
    var alert: CustomModal?
    var reportTypeModal: ReportTypeModal?
    var partnerId: String?
    
    let backgroundBlur: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    let actionSheetBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(FileReportActionsheetCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = UIColor(hex: "131317")
        cv.layer.cornerRadius = 8
        cv.isScrollEnabled = false
        cv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return cv
    }()
    
    func setupViews() {
        setupBackgroundBlur()
        setupActionsheetBackground()
        setupCollectionView()
    }
    
    private func setupBackgroundBlur() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(backgroundBlur)
        backgroundBlur.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundBlur.addGestureRecognizer(dismissTap)
    }
    
    private func setupActionsheetBackground() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(actionSheetBackground)
        actionSheetBackground.frame = CGRect(x: 0, y: window.frame.height - bottomLayoutMargin, width: window.frame.width, height: 150)
    }
    
    private func setupCollectionView() {
        actionSheetBackground.addSubview(collectionView)
        collectionView.anchor(top: actionSheetBackground.topAnchor, left: actionSheetBackground.leftAnchor, bottom: actionSheetBackground.bottomAnchor, right: actionSheetBackground.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    

    func show() {
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.layoutIfNeeded()
            self.actionSheetBackground.transform = CGAffineTransform(translationX: 0, y: -150)
            self.backgroundBlur.alpha = 1
        }.startAnimation()
    }
    
    @objc func dismiss() {
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.layoutIfNeeded()
            self.actionSheetBackground.transform = CGAffineTransform(translationX: 0, y: 150)
            self.backgroundBlur.alpha = 0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "actionSheetDismissed"), object: nil)
        }
        animator.addCompletion { (position) in
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
        alert = DisconnectModal(title: "Disconnect", message: "Are you sure?", note: "You will be disconnected from Alex.", cancelText: "Nevermind", confirmText: "Yes, disconnect")
        guard let disconnectModal = alert as? DisconnectModal, let id = partnerId else { return }
        disconnectModal.partnerId = id
        disconnectModal.show()
    }
    
    func handleCancelButton() {
        dismiss()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    init(bottomLayoutMargin: CGFloat) {
        super.init(frame: .zero)
        self.bottomLayoutMargin = bottomLayoutMargin
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FileReportActionsheet: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            handleReportButton()
        case 1:
            handleDisconnectButton()
        case 2:
            handleCancelButton()
        default:
            break
        }
    }
}

extension FileReportActionsheet: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! FileReportActionsheetCell
        cell.titleLabel.text = titles[indexPath.item]
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
