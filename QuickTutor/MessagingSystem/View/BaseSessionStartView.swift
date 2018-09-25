////
////  BaseSessionStartswift
////  QuickTutor
////
////  Created by Zach Fuller on 8/9/18.
////  Copyright © 2018 QuickTutor. All rights reserved.
////
//
// import UIKit
//
// class BaseSessionStartView: UIView {
//
//    let titleLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = Fonts.createSize(22)
//        label.text = "Alex is Video Calling..."
//        return label
//    }()
//
//    let infoBox: UIView = {
//        let view = UIView()
//        backgroundColor = Colors.navBarColor
//        layer.cornerRadius = 4
//        return view
//    }()
//
//    let subjectLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = Fonts.createSize(18)
//        label.text = "Botany"
//        return label
//    }()
//
//    let infoLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = Fonts.createSize(12)
//        label.text = "Length: 120 mins, $17.00 / hr"
//        return label
//    }()
//
//    let senderBox: SessionProfileBox = {
//        let box = SessionProfileBox()
//        return box
//    }()
//
//    let receieverBox: SessionProfileBox = {
//        let box = SessionProfileBox()
//        return box
//    }()
//
//    let waveIcon: UIImageView = {
//        let iv = UIImageView(image: #imageLiteral(resourceName: "waveIcon"))
//        iv.contentMode = .scaleAspectFit
//        return iv
//    }()
//
//    let statusLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = Fonts.createSize(16)
//        label.text = "Waiting for your {partner} to accept the manual start..."
//        label.adjustsFontSizeToFitWidth = true
//        label.isHidden = true
//        return label
//    }()
//
//    let confirmButton: DimmableButton = {
//        let button = DimmableButton()
//        button.setTitle("Accept Manual Start", for: .normal)
//        button.setTitleColor(UIColor(red: 31.0/255.0, green: 177.0/255.0, blue: 74.0/255.0, alpha: 1.0), for: .normal)
//        button.layer.borderWidth = 1.5
//        button.layer.borderColor = UIColor(red: 31.0/255.0, green: 177.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
//        button.titleLabel?.font = Fonts.createSize(18)
//        button.layer.cornerRadius = 4
//        button.backgroundColor = Colors.navBarColor
//        button.isHidden = true
//        return button
//    }()
//
//    let cancelButton: DimmableButton = {
//        let button = DimmableButton()
//        button.setTitle("Cancel", for: .normal)
//        button.setTitleColor(UIColor(red: 178.0/255.0, green: 27.0/255.0, blue: 74.0/255.0, alpha: 1.0), for: .normal)
//        button.layer.borderWidth = 1.5
//        button.layer.borderColor = UIColor(red: 178.0/255.0, green: 27.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
//        button.titleLabel?.font = Fonts.createSize(18)
//        button.layer.cornerRadius = 4
//        button.backgroundColor = Colors.navBarColor
//        return button
//    }()
//
//    func setupViews() {
//        setupMainView()
//        setupTitleLabel()
//        setupInfoBox()
//        setupSubjectLabel()
//        setupInfoLabel()
//        setupSenderBox()
//        setupReceiverBox()
//        setupWaveIcon()
//        setupCancelButton()
//        setupConfirmButton()
//        setupStatusLabel()
//        setupNavBar()
//    }
//
//    func setupMainView() {
//        backgroundColor = Colors.darkBackground
//        navigationItem.hidesBackButton = true
//        let backImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(pop))
//    }
//
//    @objc func pop() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    func setupTitleLabel() {
//        addSubview(titleLabel)
//        titleLabel.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, raight: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
//    }
//
//    func setupInfoBox() {
//        addSubview(infoBox)
//        infoBox.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 17.5, paddingBottom: 0, paddingRight: 17.5, width: 0, height: 55)
//    }
//
//    func setupSubjectLabel() {
//        infoBox.addSubview(subjectLabel)
//        subjectLabel.anchor(top: infoBox.topAnchor, left: infoBox.leftAnchor, bottom: nil, right: infoBox.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
//    }
//
//    func setupInfoLabel() {
//        infoBox.addSubview(infoLabel)
//        infoLabel.anchor(top: subjectLabel.bottomAnchor, left: infoBox.leftAnchor, bottom: infoBox.bottomAnchor, right: infoBox.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
//    }
//
//    func setupSenderBox() {
//        addSubview(senderBox)
//        senderBox.anchor(top: infoBox.bottomAnchor, left: infoBox.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 158)
//    }
//
//    func setupReceiverBox() {
//        addSubview(receieverBox)
//        receieverBox.anchor(top: infoBox.bottomAnchor, left: nil, bottom: nil, right: infoBox.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 158)
//    }
//
//    func setupWaveIcon() {
//        addSubview(waveIcon)
//        waveIcon.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
//        addConstraint(NSLayoutConstraint(item: waveIcon, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
//        addConstraint(NSLayoutConstraint(item: waveIcon, attribute: .centerY, relatedBy: .equal, toItem: senderBox, attribute: .centerY, multiplier: 1, constant: 0))
//    }
//
//    func setupCancelButton() {
//        addSubview(cancelButton)
//        cancelButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 52.5, paddingRight: 0, width: 270, height: 50)
//        addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
//        cancelButton.addTarget(self, action: #selector(BaseSessionStartVC.cancelSession), for: .touchUpInside)
//    }
//
//    func setupConfirmButton() {
//        addSubview(confirmButton)
//        confirmButton.anchor(top: nil, left: nil, bottom: cancelButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 270, height: 50)
//        addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
//        confirmButton.addTarget(self, action: #selector(confirmManualStart), for: .touchUpInside)
//    }
//
//    func setupStatusLabel() {
//        addSubview(statusLabel)
//        statusLabel.anchor(top: nil, left: leftAnchor, bottom: confirmButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 50, paddingRight: 20, width: 0, height: 20)
//    }
//
//    func setupNavBar() {
//        navigationController?.navigationBar.barTintColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
//        navigationItem.title = "Attempting to Start Session"
//        if #available(iOS 11.0, *) {
//            navigationController?.navigationBar.prefersLargeTitles = false
//        }
//    }
// }
