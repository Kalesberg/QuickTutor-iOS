//
//  AddPaymentMethod.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

protocol AddPaymentButtonPress {
    func dismissPaymentModal()
}

class AddBankButton: InteractableView, Interactable {
    let label: UILabel = {
        let label = UILabel()
        label.text = "Add Payment"
        label.font = Fonts.createBoldSize(20)
        label.textColor = Colors.backgroundDark
        label.textAlignment = .center
        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()

        layer.cornerRadius = 8
        backgroundColor = .white

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func touchStart() {
        growShrink()
    }
}

class AddPaymentModal: InteractableView, Interactable {
    
    let modal: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = Colors.backgroundDark
        view.clipsToBounds = true
        return view
    }()

    let addBankLabel: UILabel = {
        let label = UILabel()
        label.text = "PAYMENT METHOD"
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "4C5E8D")
        label.textAlignment = .center
        return label
    }()

    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = .white
        label.text = "Hey! Before connecting with tutors we need to make sure you have a payment method on file! There are no subscriptions or upfront payments. When you have a session -- your payment method will be charged at an hourly rate of your preselected choice."
        label.numberOfLines = 0
        return label
    }()

    let addBankButton = AddBankButton()
    
    var isShown = false

    override func configureView() {
        addSubview(modal)
        modal.addSubview(addBankLabel)
        modal.addSubview(infoLabel)
        modal.addSubview(addBankButton)
        super.configureView()

        alpha = 0.0
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        applyConstraints()
        
        setupTapRecognizers()
    }

    override func applyConstraints() {
        modal.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-20)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(240)
        }

        addBankLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(45)
        }

        infoLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }

        addBankButton.snp.makeConstraints { make in
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
    }

    func touchStart() {
        dismiss()
    }
    
    func setupTapRecognizers() {
        setupPaymentTap()
        setupBackgroundTap()
    }
    
    func setupPaymentTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePaymentTap))
        tap.numberOfTapsRequired = 1
        addBankButton.addGestureRecognizer(tap)
    }
    
    @objc func handlePaymentTap() {
        dismiss()
        let next = CardManagerVC()
        navigationController.pushViewController(next, animated: true)
    }
    
    func setupBackgroundTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    @objc func show() {
        guard !isShown else { return }
        isShown = true
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(self)
        anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        growShrink()
    }
    
    @objc func dismiss() {
        isShown = false
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

extension UIViewController {
    func displayAddPaymentMethod() {
        if let _ = self.view.viewWithTag(3) {
            return
        }

        let addPaymentView = AddPaymentModal()
        addPaymentView.tag = 3
        addPaymentView.frame = view.bounds

        addPaymentView.growShrink()

        view.addSubview(addPaymentView)
    }

    func dismissAddPaymentMethod() {
        view.endEditing(true)
        if let addPaymentViewer = self.view.viewWithTag(3) {
            UIView.animate(withDuration: 0.2, animations: {
                addPaymentViewer.alpha = 0.0
                addPaymentViewer.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }) { _ in
                addPaymentViewer.removeFromSuperview()
            }
        }
    }
}
