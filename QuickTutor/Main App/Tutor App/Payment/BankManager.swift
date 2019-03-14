//
//  Payment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//

import Stripe
import UIKit.UITableView

class BankManagerView: UIView {
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Payout Methods"
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
        return label
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 50
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.darkBackground
        tableView.register(BankManagerTableViewCell.self, forCellReuseIdentifier: "bankCell")
        tableView.register(AddCardTableViewCell.self, forCellReuseIdentifier: "addCardCell")
        return tableView
    }()

    func setupViews() {
        setupMainView()
        setupSubtitleLabel()
        setupTableView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-30)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).inset(-10)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.centerX.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BankManager: UIViewController {
    
    let contentView: BankManagerView = {
        let view = BankManagerView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    var acctId: String! {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var bankList = [ExternalAccountsData]() {
        didSet {
            setBank()
        }
    }

    private var banks = [ExternalAccountsData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Payment"
        fetchBanks()
        setupDelegates()
    }
    
    func fetchBanks() {
        Stripe.retrieveBankList(acctId: CurrentUser.shared.tutor.acctId) { error, list in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let list = list {
                self.bankList = list.data
            }
        }
    }
    
    func setupDelegates() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setBank() {
        banks = bankList
        contentView.tableView.reloadData()
    }

    // TODO: Check if they have any pending sessions.

    private func defaultBankAlert(bankId: String) {
        let alertController = UIAlertController(title: "Default Payout Method?", message: "Do you want this card to be your default payout method?", preferredStyle: .actionSheet)
        let setDefault = UIAlertAction(title: "Set as Default", style: .default) { _ in
            Stripe.updateDefaultBank(account: CurrentUser.shared.tutor.acctId, bankId: bankId, completion: { error, account in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                } else if let account = account {
                    self.bankList = account.data
                }
            })
        }
//		let editBillingAddress = UIAlertAction(title: "Edit Billing Address", style: .default) { (action) in
//			self.navigationController?.pushViewController(EditBillingAddressVC(), animated: true)
//		}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(setDefault)
//		alertController.addAction(editBillingAddress)
        alertController.addAction(cancel)

        present(alertController, animated: true, completion: nil)
    }
}

extension BankManager: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return banks.count + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let endIndex = banks.count

        if indexPath.row != endIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell", for: indexPath) as! BankManagerTableViewCell
            insertBorder(cell: cell)
            cell.bankName.text = banks[indexPath.row].bank_name
            cell.accountLast4.text = "•••• \(banks[indexPath.row].last4)"
            cell.defaultBank.isHidden = !banks[indexPath.row].default_for_currency

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCardCell", for: indexPath) as! AddCardTableViewCell

            cell.addCard.text = "Add bank account"

            return cell
        }
    }

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row == banks.count) ? false : true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == banks.count {
            if banks.count == 5 {
                AlertController.genericErrorAlert(self, title: "Too Many Payout Methods", message: "We currently only allow users to have 5 payout methods.")
                return
            }
            navigationController?.pushViewController(TutorAddBank(), animated: true)
        } else {
            defaultBankAlert(bankId: banks[indexPath.row].id)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, titleForDeleteConfirmationButtonForRowAt _: IndexPath) -> String? {
        return "Remove Bank"
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = AddCardHeaderView()
        view.addCard.text = "Banks"
        return view
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Stripe.removeBank(account: CurrentUser.shared.tutor.acctId, bankId: banks[indexPath.row].id) { error, bankList in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                } else if let bankList = bankList {
                    self.banks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.bankList = bankList.data
                    guard self.bankList.count > 0 else { return CurrentUser.shared.tutor.hasPayoutMethod = false }
                }
            }
        }
    }

    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}

class BankManagerTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let bankName: UILabel = {
        let label = UILabel()

        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createSize(16)
        label.textColor = .white

        return label
    }()

    let accountLast4: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createSize(15)
        label.textColor = .white

        return label
    }()

    let defaultBank: UILabel = {
        let label = UILabel()
        label.text = "Default"
        label.font = Fonts.createSize(15)
        label.textColor = .white
        label.textColor.withAlphaComponent(1.0)
        label.textAlignment = .center
        label.backgroundColor = Colors.navBarColor
		
        label.isHidden = true

        return label
    }()

    func configureTableViewCell() {
        addSubview(bankName)
        addSubview(accountLast4)
        addSubview(defaultBank)

        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.darkBackground.darker(by: 15)
        selectedBackgroundView = cellBackground
        backgroundColor = Colors.darkBackground
        applyConstraints()
    }

    func applyConstraints() {
        bankName.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        accountLast4.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview()
            make.left.equalTo(bankName.snp.right)
            make.centerY.equalToSuperview()
        }
        defaultBank.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
    }
}
