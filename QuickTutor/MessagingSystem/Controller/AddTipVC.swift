//
//  AddTipVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import Stripe

class AddTipVC: UIViewController, CustomTipPresenter {
    func didPressCancel() {}
    
    var partnerId: String!
    let tipTitles = ["No tip", "$2", "$4", "$6", "Custom"]
    var tipAmounts: [Double] = [0, 2, 4, 6, 8]
    var costOfSession = 0.0
    var amountToTip = 0.0 {
        didSet {
            let priceString = String(format: "%.2f", amountToTip + costOfSession)
            totalLabel.text = "Total: $\(priceString)"
            amountToPay = Int(amountToTip + costOfSession)
        }
    }
    
    var amountToPay = 0
    var sessionId: String?
    var customer: STPCustomer!
    var cards = [STPCard]()
    var defaultCard: STPCard?
    var selectedCard: STPCard?
    var showingAllCards = false
    var tipAdded = false
    
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
        label.text = "How much would you like to tip {username}"
        label.isHidden = true
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
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 44
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.backgroundDark
        tableView.register(CardPaymentCell.self, forCellReuseIdentifier: "cardCell")
        return tableView
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
        fakeNavBar.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
    }
    
    func setupPartnerBox() {
        view.addSubview(partnerBox)
        partnerBox.anchor(top: fakeNavBar.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 137, height: 178)
        view.addConstraint(NSLayoutConstraint(item: partnerBox, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        partnerBox.updateUI(uid: partnerId)
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
    
    func setupPaymentMethodCV() {
        view.addSubview(tableView)
        tableView.anchor(top: tipAmountCV.bottomAnchor, left: tipAmountCV.leftAnchor, bottom: nil, right: tipAmountCV.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        paymentMethodHeightAnchor = tableView.heightAnchor.constraint(equalToConstant: 50)
        paymentMethodHeightAnchor?.isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupTotalLabel() {
        view.insertSubview(totalLabel, belowSubview: tableView)
        totalLabel.anchor(top: tableView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 170, height: 50)
        view.addConstraint(NSLayoutConstraint(item: totalLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupSubmitButton() {
        view.addSubview(submitButton)
        submitButton.anchor(top: nil, left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
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
        paymentMethodHeightAnchor?.constant = CGFloat(cards.count * 50)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hidePaymentMethods() {
        paymentMethodHeightAnchor?.constant = 50
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        tableView.reloadData()
    }
    
    func togglePaymentMethods() {
        showingAllCards ? hidePaymentMethods() : showPaymentMethods()
        showingAllCards = !showingAllCards
    }
    
    @objc func handleSubmitButton() {
        chargeStripe { result in
            guard result else {
                print("Failed to charge Stripe")
                return
            }
            self.tipAdded = true
            let vc = SessionCompleteVC()
            vc.partnerId = self.partnerId
            vc.sessionId = self.sessionId
            PostSessionManager.shared.setUnfinishedFlag(sessionId: self.sessionId!, status: SessionStatus.tipAdded)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchCustomer() {
        Stripe.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { customer, error in
            guard let customer = customer, error == nil else {
                AlertController.genericErrorAlert(self, title: "Error Charging Card", message: error?.localizedDescription)
                return
            }
            self.customer = customer
            self.fetchCustomerCards()
        }
    }
    
    func fetchCustomerCards() {
        guard let cards = customer.sources as? [STPCard] else { return }
        self.cards = cards
        guard let defaultCard = customer.defaultSource as? STPCard else { return }
        self.defaultCard = defaultCard
        selectedCard = defaultCard
        tableView.reloadData()
    }
    
    func chargeStripe(completion: @escaping (Bool) -> ()) {
        DataService.shared.getTutorWithId(partnerId) { tutor in
            guard let tutor = tutor, let id = tutor.stripeAccountId else {
                print("Erorr getting tutor stripe id")
                return
            }
            guard let sourceId = self.selectedCard?.stripeID else {
                print("Erorr getting source ID")
                return
            }
            print("Amount to pay:", self.amountToPay)
            print("Fee amount:", self.amountToPay * 100)
            self.displayLoadingOverlay()
            Stripe.destinationCharge(acctId: id, customerId: self.customer.stripeID, sourceId: sourceId, amount: self.amountToPay * 100, fee: self.amountToPay, description: "Session with Tutor", { error in
                guard error == nil else {
                    print(error.debugDescription)
                    completion(false)
                    self.dismissOverlay()
                    return
                }
                self.dismissOverlay()
                completion(true)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        amountToTip = 0.0
        DataService.shared.getUserOfOppositeTypeWithId(partnerId) { user in
            guard let username = user?.formattedName else { return }
            self.descriptionLabel.text = self.descriptionLabel.text?.replacingOccurrences(of: "{username}", with: username)
            self.descriptionLabel.isHidden = false
        }
        fetchCustomer()
        setupNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !tipAdded, let id = sessionId {
            PostSessionManager.shared.setUnfinishedFlag(sessionId: id, status: SessionStatus.started)
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(markAsUnfinished), name: Notifications.didEnterBackground.name, object: nil)
    }
    
    @objc func markAsUnfinished() {
        if !tipAdded, let id = sessionId {
            PostSessionManager.shared.setUnfinishedFlag(sessionId: id, status: SessionStatus.started)
        }
    }
    
}

extension AddTipVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardPaymentCell
        insertBorder(cell: cell)
        cell.last4.text = cards[indexPath.row].last4
        cell.brand.image = STPImageLibrary.brandImage(for: cards[indexPath.row].brand)
        cell.defaultcard.isHidden = !(cards[indexPath.row] == defaultCard)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCard = cards[indexPath.item]
        cards.remove(at: indexPath.item)
        cards.insert(selectedCard!, at: 0)
        togglePaymentMethods()
    }
    
    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}

extension AddTipVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tipCell", for: indexPath) as! TipAmountCell
        if indexPath.item == 0 {
            cell.button.titleLabel?.font = Fonts.createSize(12)
        }
        if indexPath.item == 4 {
            cell.button.titleLabel?.font = Fonts.createSize(10)
        }
        cell.button.setTitle(tipTitles[indexPath.item], for: .normal)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tipSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        return tipSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        return 10
    }
    
}

protocol CustomTipPresenter {
    var amountToTip: Double { get set }
    func didPressCancel()
}
