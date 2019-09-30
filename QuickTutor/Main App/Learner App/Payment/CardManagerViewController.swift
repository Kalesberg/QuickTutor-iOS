//
//  CardManagerViewController.swift
//  QuickTutor
//
//  Created by Will Saults on 5/1/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Stripe
import Lottie
import SwipeCellKit
import Firebase

class CardManagerViewController: UIViewController {
    @IBOutlet weak var noPaymentLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addDebitOrCreditButton: RoundedButton!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var feeInfoIcon: UIButton!
    @IBOutlet weak var feeInfoView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPaymentView: UIScrollView!
    @IBOutlet weak var btnAddApplePay: RoundedButton!
    
    var addCardViewController: AddCardViewController?
    var shouldHideNavBarWhenDismissed = false
    var isShowingAddCardView = false
    var popBackTo: UIViewController?
    private var cards = [STPCard]()
    private var pastSessions = [Session]()
    private var defaultCard: STPCard?
    
    var customer: STPCustomer! {
        didSet {
            setCustomer()
        }
    }
    
    var loadingIndicator: LOTAnimationView = {
        let view = LOTAnimationView(name: "loadingNew")
        view.loopAnimation = true
        return view
    }()
    
    private var hasPaymentHistory: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        
        setupLoadingIndicator()
        
        loadStripe()
        fetchTransactions()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.register(UINib(nibName: "PaymentCardTableViewCell", bundle: nil), forCellReuseIdentifier: "cardCell")
        tableView.register(EarningsHistoryTaleViewCell.self, forCellReuseIdentifier: "earningsCell")
        
        let image = UIImage(named: "informationIcon")?.withRenderingMode(.alwaysTemplate)
        feeInfoIcon?.setImage(image, for: .normal)
        feeInfoIcon?.tintColor = Colors.purple
        
        setParagraphStyles()
        addDropShadow()
        addDimming()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = Colors.newNavigationBarBackground
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(!isShowingAddCardView && shouldHideNavBarWhenDismissed, animated: false)
    }
    
    func setHasPaymentHistory (_ hasPaymentHistory: Bool) {
        self.hasPaymentHistory = hasPaymentHistory
    }
    
    func configureNavigation() {
        navigationItem.title = "Payment"
        edgesForExtendedLayout = []
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func toggleAddPaymentView(hasPayment hide: Bool) {
        addPaymentView.isHidden = hide
        feeInfoView.isHidden = hide
        tableView.isHidden = !hide
        
        let view = AddCardHeaderView.view
        if hide {
            view.addNewButton?.isHidden = false
        } else {
            view.addNewButton?.isHidden = true
            btnAddApplePay.isHidden = Stripe.deviceSupportsApplePay()
        }
    }
    
    @objc
    private func onClickItemAddNewPayment() {
        let choosePaymentMethodVC = ChoosePaymentMethodViewController(nibName: String(describing: ChoosePaymentMethodViewController.self), bundle: nil)
        choosePaymentMethodVC.didClickBtnAddDebitOrCreditCard = { sender in
            choosePaymentMethodVC.dismiss(animated: true) {
                self.tappedAddCard(sender)
            }
        }
        choosePaymentMethodVC.didClickBtnLinkApplePay = { sender in
            choosePaymentMethodVC.dismiss(animated: true) {
                self.onClickBtnLinkApplePay(sender)
            }
        }
        present(choosePaymentMethodVC, animated: true, completion: nil)
    }
    
    func setParagraphStyles() {
        setParagraphStyle(label: infoLabel)
        setParagraphStyle(label: feeLabel)
    }
    
    func addDropShadow() {
        feeInfoView?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: -5), radius: 10)
    }
    
    func addDimming() {
        addDebitOrCreditButton.setupTargets()
    }
    
    func setParagraphStyle(label: UILabel?) {
        let attributedString = NSMutableAttributedString(string: label?.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label?.attributedText = attributedString
    }
    
    func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        view.addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        loadingIndicator.play()
        loadingIndicator.contentMode = .scaleAspectFit
    }
    
    func showLoadingAnimation() {
        loadingIndicator.play()
        loadingIndicator.isHidden = false
    }
    
    func hideLoadingAnimation() {
        loadingIndicator.stop()
        loadingIndicator.isHidden = true
    }
    
    func loadStripe() {
        if let learner = CurrentUser.shared.learner, !learner.customer.isEmpty {
            StripeService.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { customer, error in
                if let error = error {
                    if let message = error.message {
                        AlertController.genericAlertWithoutCancel(self, title: "Error Retrieving Cards", message: message)
                    } else {
                        AlertController.genericAlertWithoutCancel(self, title: "Error Retrieving Cards", message: error.error?.localizedDescription)
                    }
                } else if let customer = customer {
                    self.customer = customer
                }
                self.hideLoadingAnimation()
                if let cards = customer?.sources as? [STPCard] {
                    self.toggleAddPaymentView(hasPayment: !cards.isEmpty || Stripe.deviceSupportsApplePay())
                    if cards.isEmpty, Stripe.deviceSupportsApplePay() {
                        self.updateApplePayDefaultStatus(true)
                    }
                }
            }
        }
    }
    
    func fetchTransactions() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let currentUserType = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("userSessions").child(uid).child(currentUserType).observe(.value) { (snapshot) in
            let group = DispatchGroup()
            guard let sessionsDict = snapshot.value as? [String: Any] else { return }
            sessionsDict.forEach({ (key, value) in
                group.enter()
                DataService.shared.getSessionById(key) { (session) in
                    guard session.status == "completed" else {
                        group.leave()
                        return
                    }
                    self.pastSessions.append(session)
                    group.leave()
                }
            })
            
            group.notify(queue: .main) {
                self.pastSessions = self.pastSessions.sorted(by: { $0.startTime > $1.startTime })
                self.tableView.reloadData()
            }
        }
        
    }
    
    private func setCustomer() {
        guard let cards = customer.sources as? [STPCard] else { return }
        self.cards = cards
        guard let defaultCard = customer.defaultSource as? STPCard else { return }
        self.defaultCard = defaultCard
        tableView.reloadData()
    }
    
    private func defaultCardAlert(card: STPCard) {
        let alertController = UIAlertController(title: "Default Payment Method?", message: "Do you want this card to be your default Payment method?", preferredStyle: .actionSheet)
        let setDefault = UIAlertAction(title: "Set as Default", style: .default) { _ in
            if card == self.defaultCard {
                self.tableView.reloadData()
                if !self.hasPaymentHistory {
                    NotificationCenter.default.post(name: Notifications.didUpatePaymentCustomer.name, object: nil, userInfo: ["customer" : self.customer])
                }
            } else {
                self.showLoadingAnimation()
                StripeService.updateDefaultSource(customer: self.customer, new: card, completion: { customer, error in
                    if let error = error {
                        if let message = error.message {
                            AlertController.genericAlertWithoutCancel(self, title: "Error Updating Card", message: message)
                        } else {
                            AlertController.genericAlertWithoutCancel(self, title: "Error Updating Card", message: error.error?.localizedDescription)
                        }
                    } else if let customer = customer {
                        self.customer = customer
                        
                        if !self.hasPaymentHistory {
                            NotificationCenter.default.post(name: Notifications.didUpatePaymentCustomer.name, object: nil, userInfo: ["customer" : customer])
                        }
                    }
                    self.hideLoadingAnimation()
                })
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(setDefault)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tappedAddCard(_ sender: Any) {
        showAddCardViewController()
    }
    
    @IBAction func onClickBtnLinkApplePay(_ sender: Any) {
        PKPassLibrary().openPaymentSetup()
    }
    
    @IBAction func tappedInfoButton(_ sender: Any) {
        let _ = ProcessingFeeModal.view
    }
    
    func deleteCardAt(indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        guard let card = cards[safe: indexPath.row] else {
            return
        }
        showLoadingAnimation()
        StripeService.detachSource(customer: customer, deleting: card) { customer, error in
            if let error = error {
                if let message = error.message {
                    AlertController.genericAlertWithoutCancel(self, title: "Error Deleting Card", message: message)
                } else {
                    AlertController.genericAlertWithoutCancel(self, title: "Error Deleting Card", message: error.error?.localizedDescription)
                }
            } else if let customer = customer {
                self.cards.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.customer = customer
                CurrentUser.shared.learner.hasPayment = !self.cards.isEmpty || Stripe.deviceSupportsApplePay()
                
                if self.cards.isEmpty,
                    Stripe.deviceSupportsApplePay() {
                    self.updateApplePayDefaultStatus(true)
                }
            }
            self.tableView.isUserInteractionEnabled = true
            self.toggleAddPaymentView(hasPayment: !self.cards.isEmpty || Stripe.deviceSupportsApplePay())
            self.hideLoadingAnimation()
        }
    }
    
    private func updateApplePayDefaultStatus(_ isDefault: Bool) {
        FirebaseData.manager.updateValue(node: "student-info", value: ["isApplePayDefault": isDefault]) { error in
            CurrentUser.shared.learner.isApplePayDefault = isDefault
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            }
        }
    }
}

extension CardManagerViewController: AddCardViewControllerDelegate {
      func addCardViewControllerDidCancel() {
        isShowingAddCardView = false
        dismiss(animated: true, completion: nil)
    }
    
    func addCardViewControllerDidCreateToken(token: STPToken) {
        self.isShowingAddCardView = false
        self.dismiss(animated: true, completion: nil)
        showLoadingAnimation()
        StripeService.attachSource(cusID: CurrentUser.shared.learner.customer, with: token) { (error) in
            self.hideLoadingAnimation()
            if let error = error {
                AlertController.genericAlertWithoutCancel(self, title: "Error Processing Card", message: error)
                return
            }
            CurrentUser.shared.learner.hasPayment = true
            self.loadStripe()
        }
    }
}

extension CardManagerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasPaymentHistory ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return cards.count
        } else if 1 == section {
            return Stripe.deviceSupportsApplePay() ? 1 : 0
        } else {
            return pastSessions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 2 == indexPath.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "earningsCell", for: indexPath) as! EarningsHistoryTaleViewCell
            cell.updateUI(pastSessions[indexPath.item])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! PaymentCardTableViewCell
            if 0 == indexPath.section {
                if let card = cards[safe: indexPath.row] {
                    cell.setLastFour(text: card.last4)
                    cell.brandImage?.image = STPImageLibrary.brandImage(for: card.brand)
                    let cardChoice: CardChoice = (!CurrentUser.shared.learner.isApplePayDefault && card == defaultCard) ? .defaultCard : .optionalCard
                    cell.setCardButtonType(type: cardChoice)
                    cell.row = indexPath.row
                    cell.delegate = self
                    cell.cellDelegate = self
                }
            } else {
                cell.lastFourLabel.text = "Apple Pay"
                cell.brandImage.image = STPApplePayPaymentOption().image
                let cardChoice: CardChoice = CurrentUser.shared.learner.isApplePayDefault ? .defaultCard : .optionalCard
                cell.setCardButtonType(type: cardChoice)
                cell.row = indexPath.row
                cell.delegate = self
                cell.cellDelegate = self
            }
            return cell
        }
    }
}

extension CardManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if 2 == indexPath.section { return }
        
        if 0 == indexPath.section {
            guard let card = cards[safe: indexPath.row] else { return }
            
            if CurrentUser.shared.learner.isApplePayDefault {
                CurrentUser.shared.learner.isApplePayDefault = false
                updateApplePayDefaultStatus(false)
                
                defaultCardAlert(card: card)
            } else if card != defaultCard {
                defaultCardAlert(card: card)
            }
        } else {
            let alertController = UIAlertController(title: "Default Payment Method?", message: "Are you sure you would like to set  Pay as default?", preferredStyle: .actionSheet)
            let setDefault = UIAlertAction(title: "Set as Default", style: .default) { _ in
                CurrentUser.shared.learner.isApplePayDefault = true
                self.updateApplePayDefaultStatus(true)
                self.tableView.reloadData()
                
                if !self.hasPaymentHistory {
                    NotificationCenter.default.post(name: Notifications.didUpatePaymentCustomer.name, object: nil, userInfo: ["isApplyPay" : true])
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(setDefault)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if 0 == section {
//            if cards.isEmpty { return nil }
            
            let view = AddCardHeaderView.view
            view.headerLabel?.text = "Cards"
            view.addNewButton?.addTarget(self, action: #selector(onClickItemAddNewPayment), for: .touchUpInside)
            return view
        } else if 1 == section {
            if !Stripe.deviceSupportsApplePay() { return nil }
            
            let view = AddCardHeaderView.view
            view.headerLabel?.text = "Other options"
            view.addNewButton?.isHidden = true
            return view
        } else {
            if pastSessions.isEmpty { return nil }
            
            let view = AddCardHeaderView.view
            view.headerLabel?.text = "Payment history"
            view.addNewButton?.isHidden = true
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if 0 == section {
            return 60
        } else if 1 == section {
            return !Stripe.deviceSupportsApplePay() ? 0 : 60
        } else {
            return pastSessions.isEmpty ? 0 : 60
        }
    }
    
    func showAddCardViewController() {
        let addCardViewController = AddCardViewController()
        addCardViewController.delegate = self
        let customNav = CustomNavVC(rootViewController: addCardViewController)
        navigationController?.present(customNav, animated: true)
    }
}

extension CardManagerViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left || 0 != indexPath.section { return nil }

        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            let alert = UIAlertController(title: "Remove a card",
                                          message: "Are you sure you want to remove this card?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                self.deleteCardAt(indexPath: indexPath)
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        deleteAction.image = UIImage(named: "ic_payment_del")
        deleteAction.highlightedImage = UIImage(named: "ic_payment_del")?.alpha(0.2)
        deleteAction.font = Fonts.createSize(16)
        deleteAction.backgroundColor = Colors.newScreenBackground
        deleteAction.highlightedBackgroundColor = Colors.newScreenBackground
        deleteAction.hidesWhenSelected = true
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        return options
    }
}

extension CardManagerViewController: PaymentCardTableViewCellDelegate {
    func didTapDefaultButton(_ cell: PaymentCardTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView(tableView, didSelectRowAt: indexPath)
    }
}
