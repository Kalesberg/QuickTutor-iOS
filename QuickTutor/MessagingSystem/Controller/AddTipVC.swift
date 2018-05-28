//
//  AddTipVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class AddTipVC: UIViewController, CustomTipPresenter {
    
    var partnerId: String! = "iIuS1w4jGcPVJwFSehBEznnkHc53"
    
    let tipTitles = ["No tip", "$2", "$4", "$6", "Custom"]
    var paymentMethodCount = 1
    var tipAmounts: [Double] = [0,2,4,6,8]
    var amountToTip = 0.0 {
        didSet {
            let priceString = String(format: "%.2f", amountToTip)
            totalLabel.text = "Total: $\(priceString)"
        }
    }
    
    lazy var fakeNavBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = Colors.learnerPurple
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.textAlignment = .center
            label.text = "Session Complete!"
            label.font = Fonts.createBoldSize(18)
            return label
        }()
        
        bar.addSubview(titleLabel)
        titleLabel.anchor(top: bar.topAnchor, left: bar.leftAnchor, bottom: bar.bottomAnchor, right: bar.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        return bar
    }()
    
    let partnerBox: SessionProfileBox = {
        let box = SessionProfileBox()
        box.nameLabel.font = Fonts.createSize(18)
        return box
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(14)
        label.text = "How much would you like to tip Alex?"
        return label
    }()
    
    let tipAmountCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(TipAmountCell.self, forCellWithReuseIdentifier: "tipCell")
        cv.backgroundColor = .clear
        return cv
    }()
    
    let paymentMethodCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PaymentMethodCell.self, forCellWithReuseIdentifier: "paymentCell")
        cv.backgroundColor = Colors.darkBackground
        return cv
    }()
    
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total: $0.00"
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = Colors.green
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    let submitButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.learnerPurple
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = Fonts.createLightSize(22)
        button.setTitleColor(.white, for: .normal)
        button.adjustsImageWhenDisabled = true
        return button
    }()
    
    let submitButtonCover: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    var customTipModal: CustomTipModal?
    var paymentMethodHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupMainView()
        setupNavBar()
        setupPartnerBox()
        setupDescriptionLabel()
        setupTipAmountCV()
        setupPaymentMethodCV()
        setupTotalLabel()
        setupSubmitButton()
        setupSubmitButtonCover()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    func setupNavBar() {
        view.addSubview(fakeNavBar)
        fakeNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
    }
    
    func setupPartnerBox() {
        view.addSubview(partnerBox)
        partnerBox.anchor(top: fakeNavBar.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 137, height: 178)
        view.addConstraint(NSLayoutConstraint(item: partnerBox, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        partnerBox.updateUI(uid: partnerId)
        partnerBox.imageView.layer.cornerRadius = 55
    }
    
    func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: partnerBox.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    }
    
    func setupTipAmountCV() {
        view.addSubview(tipAmountCV)
        tipAmountCV.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 50, paddingBottom: 0, paddingRight: 50, width: 0, height: 42)
        tipAmountCV.delegate = self
        tipAmountCV.dataSource = self
    }
    
    func setupPaymentMethodCV () {
        view.addSubview(paymentMethodCV)
        paymentMethodCV.anchor(top: tipAmountCV.bottomAnchor, left: tipAmountCV.leftAnchor, bottom: nil, right: tipAmountCV.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        paymentMethodHeightAnchor = paymentMethodCV.heightAnchor.constraint(equalToConstant: 50)
        paymentMethodHeightAnchor?.isActive = true
        paymentMethodCV.delegate = self
        paymentMethodCV.dataSource = self
    }
    
    func setupTotalLabel() {
        view.insertSubview(totalLabel, belowSubview: paymentMethodCV)
        totalLabel.anchor(top: paymentMethodCV.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 170, height: 50)
        view.addConstraint(NSLayoutConstraint(item: totalLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupSubmitButton() {
        view.addSubview(submitButton)
        submitButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        submitButton.addTarget(self, action: #selector(AddTipVC.handleSubmitButton), for: .touchUpInside)
    }
    
    func setupSubmitButtonCover() {
        view.addSubview(submitButtonCover)
        submitButtonCover.anchor(top: submitButton.topAnchor, left: submitButton.leftAnchor, bottom: submitButton.bottomAnchor, right: submitButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func handleCustomTip() {
        customTipModal = CustomTipModal()
        customTipModal?.parent = self
        customTipModal?.show()
    }
    
    func showPaymentMethods() {
        paymentMethodCount = 4
        paymentMethodCV.reloadSections(IndexSet(integer: 0))
//        paymentMethodHeightAnchor?.constant = 200
//        view.layoutIfNeeded()
    }
    
    @objc func handleSubmitButton() {
        let vc = SessionCompleteVC()
        vc.partnerId = partnerId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
}

extension AddTipVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == tipAmountCV ? 5 : paymentMethodCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tipAmountCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tipCell", for: indexPath) as! TipAmountCell
            cell.button.setTitle(tipTitles[indexPath.item], for: .normal)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentCell", for: indexPath) as! PaymentMethodCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tipSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        let paymentMethodSize = CGSize(width: collectionView.frame.width, height: 45)
        return collectionView == tipAmountCV ? tipSize : paymentMethodSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == tipAmountCV else { return }
        let cell = collectionView.cellForItem(at: indexPath) as! TipAmountCell
        cell.isSelected = true
        submitButtonCover.isHidden = true
        guard indexPath.item != 4 else {
            handleCustomTip()
            return
        }
        amountToTip = tipAmounts[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == paymentMethodCV {
            return 1
        } else {
            return 10
        }
    }
    
}

protocol CustomTipPresenter {
    var amountToTip: Double { get set }
}
