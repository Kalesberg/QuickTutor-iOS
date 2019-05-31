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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        
        setupLoadingIndicator()
        
        loadStripe()
        fetchTransactions()
        
        tableView.register(UINib(nibName: "PaymentCardTableViewCell", bundle: nil), forCellReuseIdentifier: "cardCell")
        tableView.register(EarningsHistoryTaleViewCell.self, forCellReuseIdentifier: "earningsCell")
        
        let image = UIImage(named: "informationIcon")?.withRenderingMode(.alwaysTemplate)
        feeInfoIcon?.setImage(image, for: .normal)
        feeInfoIcon?.tintColor = Colors.purple
        
        setParagraphStyles()
        addDropShadow()
        addDimming()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = Colors.newBackground
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(!isShowingAddCardView && shouldHideNavBarWhenDismissed, animated: false)
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
            Stripe.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { customer, error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error Retrieving Cards", message: error.localizedDescription)
                } else if let customer = customer {
                    self.customer = customer
                }
                self.hideLoadingAnimation()
                if let cards = customer?.sources as? [STPCard] {
                    self.toggleAddPaymentView(hasPayment: !cards.isEmpty)
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
                DataService.shared.getSessionById(key, completion: { (session) in
                    guard session.status == "completed" else {
                        group.leave()
                        return
                    }
                    self.pastSessions.append(session)
                    group.leave()
                })
            })
            
            group.notify(queue: .main, execute: {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
            })
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
            self.showLoadingAnimation()
            Stripe.updateDefaultSource(customer: self.customer, new: card, completion: { customer, error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error Updating Card", message: error.localizedDescription)
                } else if let customer = customer {
                    self.customer = customer
                }
                self.hideLoadingAnimation()
            })
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
    
    @IBAction func tappedInfoButton(_ sender: Any) {
        let _ = ProcessingFeeModal.view
    }
    
    func deleteCardAt(indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        guard let card = cards[safe: indexPath.row] else {
            return
        }
        showLoadingAnimation()
        Stripe.detachSource(customer: customer, deleting: card) { customer, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error Deleting Card", message: error.localizedDescription)
            } else if let customer = customer {
                self.cards.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.customer = customer
                CurrentUser.shared.learner.hasPayment = !self.cards.isEmpty
            }
            self.tableView.isUserInteractionEnabled = true
            self.toggleAddPaymentView(hasPayment: !self.cards.isEmpty)
            self.hideLoadingAnimation()
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
        Stripe.attachSource(cusID: CurrentUser.shared.learner.customer, with: token) { (error) in
            self.hideLoadingAnimation()
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error Processing Card", message: error)
                return
            }
            CurrentUser.shared.learner.hasPayment = true
            self.loadStripe()
        }
    }
}

extension CardManagerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? cards.count : pastSessions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? tableView.estimatedRowHeight : 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! PaymentCardTableViewCell
            
            if let card = cards[safe: indexPath.row] {
                cell.setLastFour(text: card.last4)
                cell.brandImage?.image = STPImageLibrary.brandImage(for: card.brand)
                let cardChoice: CardChoice = card == defaultCard ? .defaultCard : .optionalCard
                cell.setCardButtonType(type: cardChoice)
                cell.row = indexPath.row
                cell.defaultPaymentButtonDelegate = self
                cell.delegate = self
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "earningsCell", for: indexPath) as! EarningsHistoryTaleViewCell
            cell.updateUI(pastSessions[indexPath.item])
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        
        if let card = cards[safe: indexPath.row], card != defaultCard {
            defaultCardAlert(card: card)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = AddCardHeaderView.view
        view.delegate = self
        
        if section == 1 {
            view.addNewButton.isHidden = false
            view.headerLabel.text = "Payment history"
        }
        
        return view
    }
    
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 60
    }
    
    func showAddCardViewController() {
        let addCardViewController = AddCardViewController()
        addCardViewController.delegate = self
        let customNav = CustomNavVC(rootViewController: addCardViewController)
        navigationController?.present(customNav, animated: true)
    }
}

extension CardManagerViewController: AddCardHeaderDelegate {
    func didTapAddButton() {
        showAddCardViewController()
    }
}

extension CardManagerViewController: PaymentCardTableViewCellDelegate {
    func didTapDefaultButton(row: NSInteger?) {
        guard let row = row else {
            return
        }
        if let card = cards[safe: row], card != defaultCard {
            defaultCardAlert(card: card)
        }
    }
}

extension CardManagerViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.deleteCardAt(indexPath: indexPath)
        }

        deleteAction.image = UIImage(named: "deleteCellIcon")
        deleteAction.highlightedImage = UIImage(named: "deleteCellIcon")?.alpha(0.2)
        deleteAction.font = Fonts.createSize(16)
        deleteAction.backgroundColor = Colors.darkBackground
        deleteAction.highlightedBackgroundColor = Colors.darkBackground
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        return options
    }
}
