//
//  CardManager.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//	Purpose: This class shows the user his current payment methods. The user can Delete or add cards here.
//	Maximum of 5 cards per user. The add payment button will be disabled when they have 5 cards.

import Stripe
import UIKit
import Lottie

class CardManagerView: UIView {
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment Methods"
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
        return label
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 44
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.newBackground
        return tableView
    }()

    func configureView() {
        backgroundColor = Colors.newBackground
        addSubview(subtitleLabel)
        addSubview(tableView)
        applyConstraints()
    }

    func applyConstraints() {
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-30)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).inset(-10)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.centerX.equalToSuperview()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CardManagerVC: BaseViewController {
    override var contentView: CardManagerView {
        return view as! CardManagerView
    }

    override func loadView() {
        view = CardManagerView()
    }

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
    
    var shouldHideNavBarWhenDismissed = false
    var popToMain: Bool = true
    var popBackTo: UIViewController?

    private var cards = [STPCard]()
    private var defaultCard: STPCard?

    var addCardVC: STPAddCardViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
        
        loadStripe()

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CardManagerTableViewCell.self, forCellReuseIdentifier: "cardCell")
        contentView.tableView.register(AddCardTableViewCell.self, forCellReuseIdentifier: "addCardCell")
        
        navigationItem.title = "Payment"
        edgesForExtendedLayout = []
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(shouldHideNavBarWhenDismissed, animated: false)
    }
    
    func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        view.addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        loadingIndicator.play()
        loadingIndicator.contentMode = .scaleAspectFit
    }
    
    func hideLoadingAnimation() {
        view.sendSubviewToBack(loadingIndicator)
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
            }
        }
    }

    private func setCustomer() {
        guard let cards = customer.sources as? [STPCard] else { return }
        self.cards = cards
        guard let defaultCard = customer.defaultSource as? STPCard else { return }
        self.defaultCard = defaultCard

        contentView.tableView.reloadData()
    }

    // TODO: Check if they have any pending sessions.
    private func defaultCardAlert(card: STPCard) {
        let alertController = UIAlertController(title: "Default Payment Method?", message: "Do you want this card to be your default Payment method?", preferredStyle: .actionSheet)
        let setDefault = UIAlertAction(title: "Set as Default", style: .default) { _ in
            Stripe.updateDefaultSource(customer: self.customer, new: card, completion: { customer, error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error Updating Card", message: error.localizedDescription)
                } else if let customer = customer {
                    self.customer = customer
                }
            })
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(setDefault)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
}

extension CardManagerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return cards.count + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let endIndex = cards.count

        if indexPath.row != endIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardManagerTableViewCell

            insertBorder(cell: cell)
            cell.last4.text = cards[indexPath.row].last4
            cell.brand.image = STPImageLibrary.brandImage(for: cards[indexPath.row].brand)
            cell.defaultcard.isHidden = !(cards[indexPath.row] == defaultCard)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCardCell", for: indexPath) as! AddCardTableViewCell
            cell.didTapAddCard = {
                self.showStripeAddCard()
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cards.count {
            if cards.count == 5 {
                print("too many cards")
                return
            }
        } else {
            if cards[indexPath.row] != defaultCard {
                defaultCardAlert(card: cards[indexPath.row])
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, titleForDeleteConfirmationButtonForRowAt _: IndexPath) -> String? {
        return "Remove Card"
    }

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row == cards.count) ? false : true
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = AddCardHeaderView()
        return view
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.isUserInteractionEnabled = false
            Stripe.dettachSource(customer: customer, deleting: cards[indexPath.row]) { customer, error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error Deleting Card", message: error.localizedDescription)
                } else if let customer = customer {
                    self.cards.remove(at: indexPath.row)
                    CurrentUser.shared.learner.hasPayment = self.cards.isEmpty
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.isUserInteractionEnabled = true
                    self.customer = customer
                    if self.cards.count == 0 {
                        CurrentUser.shared.learner.hasPayment = false
                    }
                }
            }
        }
    }

    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
    
    func showStripeAddCard() {
        let theme = STPTheme()
        theme.primaryBackgroundColor = Colors.registrationDark
        theme.font = Fonts.createSize(16)
        theme.emphasisFont = Fonts.createBoldSize(18)
        theme.accentColor = Colors.purple
        theme.errorColor = Colors.qtRed
        theme.primaryForegroundColor = .white
        theme.secondaryForegroundColor = Colors.grayText
        theme.secondaryBackgroundColor = Colors.darkBackground
        
        
        let theme2 = STPTheme()
        theme2.primaryBackgroundColor = Colors.purple
        theme2.emphasisFont = Fonts.createBoldSize(18)
        theme2.accentColor = .white
        theme2.primaryForegroundColor = .white
        theme2.secondaryForegroundColor = Colors.grayText
        theme2.secondaryBackgroundColor = Colors.purple
        
        let config = STPPaymentConfiguration()
        config.requiredBillingAddressFields = .none
        #if DEVELOPMENT
        config.publishableKey = "pk_test_TtFmn5n1KhfNPgXXoGfg3O97"
        #else
        config.publishableKey = "pk_live_D8MI9AN23eK4XLw1mCSUHi9V"
        #endif
        addCardVC = STPAddCardViewController(configuration: config, theme: theme)
        addCardVC?.delegate = self
        
        let navigationController = UINavigationController(rootViewController: addCardVC!)
        navigationController.navigationBar.stp_theme = theme2
		
        present(navigationController, animated: true, completion: nil)
    }
}

extension CardManagerVC: STPAddCardViewControllerDelegate {
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true, completion: nil)
    }

    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
		Stripe.attachSource(cusID: CurrentUser.shared.learner.customer, with: token) { (error) in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error Processing Card", message: error)
				return completion(StripeError.updateCardError)
			}
			self.addCardVC?.dismiss(animated: true, completion: nil)
            CurrentUser.shared.learner.hasPayment = true
            self.loadStripe()
			self.navigationController?.popBackToMain()
		}
    }
}

class AddCardHeaderView: BaseView {
    var addCard: UILabel = {
        let label = UILabel()

        label.text = "Cards"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let footer = UIView()

    override func configureView() {
        addSubview(addCard)
        addSubview(footer)
        super.configureView()

        footer.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        applyConstraints()
    }

    override func applyConstraints() {
        addCard.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        footer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

class AddCardTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var didTapAddCard: (() -> ())?
    
    let addCard: UILabel = {
        let label = UILabel()
        label.text = "Add debit or credit card"
        label.textColor = .white
        label.font = Fonts.createSize(18)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let footer = UIView()

    func configureTableViewCell() {
        addSubview(addCard)
        addSubview(footer)

        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.darkBackground
        selectedBackgroundView = cellBackground
        footer.backgroundColor = Colors.darkBackground
        backgroundColor = Colors.darkBackground
        applyConstraints()
        
        addCard.setupTargets(gestureState: { gestureState in
            if gestureState == .ended {
                if let didTapAddCard = self.didTapAddCard {
                    didTapAddCard()
                }
            }
        })
    }

    func applyConstraints() {
        addCard.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        footer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

class CardManagerTableViewCell: UITableViewCell {
    var hiddenCardNumbers: UILabel = {
        let label = UILabel()
        label.text = "••••"
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createSize(22)
        label.textColor = .white
        return label
    }()

    var last4: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createBoldSize(22)
        label.textColor = .white
        return label
    }()

    var brand = UIImageView()

    var defaultcard: UILabel = {
        let label = UILabel()
        label.text = "Default"
        label.font = Fonts.createSize(15)
        label.textColor = .white
        label.textColor.withAlphaComponent(1.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        label.isHidden = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTableViewCell() {
        addSubview(hiddenCardNumbers)
        addSubview(last4)
        addSubview(brand)
        addSubview(defaultcard)

        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.darkBackground
        selectedBackgroundView = cellBackground

        backgroundColor = Colors.darkBackground

        applyConstraints()
    }

    func applyConstraints() {
        brand.snp.makeConstraints { make in
            make.left.equalToSuperview().multipliedBy(1.2)
            make.width.equalToSuperview().multipliedBy(0.12)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        }
        hiddenCardNumbers.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.1)
            make.left.equalTo(brand.snp.right).multipliedBy(1.2)
            make.centerY.equalToSuperview().multipliedBy(0.85)
        }
        last4.snp.makeConstraints { make in
            make.left.equalTo(hiddenCardNumbers.snp.right).multipliedBy(1.1)
            make.width.equalToSuperview().multipliedBy(0.1)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.85)
        }
        defaultcard.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(brand.snp.height)
        }
    }
}
