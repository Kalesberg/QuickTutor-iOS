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

class CardManagerView: MainLayoutTitleBackButton {
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
        tableView.backgroundColor = Colors.backgroundDark

        return tableView
    }()

    override func configureView() {
        addSubview(subtitleLabel)
        addSubview(tableView)
        super.configureView()

        title.label.text = "Payment"

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).inset(-30)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
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

    var popToMain: Bool = true
    var popBackTo: UIViewController?

    private var cards = [STPCard]()
    private var defaultCard: STPCard?

    var addCardVC: STPAddCardViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLoadingOverlay()
        Stripe.retrieveCustomer(cusID: CurrentUser.shared.learner.customer) { customer, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error Retrieving Cards", message: error.localizedDescription)
            } else if let customer = customer {
                self.customer = customer
            }
            self.dismissOverlay()
        }

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CardManagerTableViewCell.self, forCellReuseIdentifier: "cardCell")
        contentView.tableView.register(AddCardTableViewCell.self, forCellReuseIdentifier: "addCardCell")
        
    }

    private func setCustomer() {
        guard let cards = customer.sources as? [STPCard] else { return }
        self.cards = cards
        guard let defaultCard = customer.defaultSource as? STPCard else { return }
        self.defaultCard = defaultCard

        contentView.tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.tableView.reloadData()
    }

    // TODO: Check if they have any pending sessions.
    private func defaultCardAlert(card: STPCard) {
        let alertController = UIAlertController(title: "Default Payment Method?", message: "Do you want this card to be your default Payment method?", preferredStyle: .actionSheet)
        let setDefault = UIAlertAction(title: "Set as Default", style: .default) { _ in
            self.displayLoadingOverlay()
            Stripe.updateDefaultSource(customer: self.customer, new: card, completion: { customer, error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error Updating Card", message: error.localizedDescription)
                } else if let customer = customer {
                    self.customer = customer
                }
                self.dismissOverlay()
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
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cards.count {
            if cards.count == 5 {
                print("too many cards")
                return
            }
            showStripeAddCard()
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
            displayLoadingOverlay()

            Stripe.dettachSource(customer: customer, deleting: cards[indexPath.row]) { customer, error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error Deleting Card", message: error.localizedDescription)
                } else if let customer = customer {
                    self.cards.remove(at: indexPath.row)
                    CurrentUser.shared.learner.hasPayment = self.cards.isEmpty
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.customer = customer
                    if self.cards.count == 0 {
                        CurrentUser.shared.learner.hasPayment = false
                    }
                }
                self.dismissOverlay()
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
        theme.accentColor = Colors.learnerPurple
        theme.errorColor = Colors.qtRed
        theme.primaryForegroundColor = .white
        theme.secondaryForegroundColor = Colors.grayText
        theme.secondaryBackgroundColor = Colors.darkBackground
        
        
        let theme2 = STPTheme()
        theme2.primaryBackgroundColor = Colors.learnerPurple
        theme2.emphasisFont = Fonts.createBoldSize(18)
        theme2.accentColor = .white
        theme2.primaryForegroundColor = .white
        theme2.secondaryForegroundColor = Colors.grayText
        theme2.secondaryBackgroundColor = Colors.learnerPurple
        
        let config = STPPaymentConfiguration()
        config.requiredBillingAddressFields = .none
        config.publishableKey = "pk_live_D8MI9AN23eK4XLw1mCSUHi9V"
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
		addCardViewController.displayLoadingOverlay()
		Stripe.attachSource(cusID: CurrentUser.shared.learner.customer, with: token) { (error) in
			if let error = error {
				addCardViewController.dismissOverlay()
				AlertController.genericErrorAlert(self, title: "Error Processing Card", message: error)
				return completion(StripeError.updateCardError)
			}
			addCardViewController.dismissOverlay()
			self.addCardVC?.dismiss(animated: true, completion: nil)
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
        cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        selectedBackgroundView = cellBackground
        footer.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        backgroundColor = Colors.backgroundDark
        applyConstraints()
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
        cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        selectedBackgroundView = cellBackground

        backgroundColor = Colors.backgroundDark

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
