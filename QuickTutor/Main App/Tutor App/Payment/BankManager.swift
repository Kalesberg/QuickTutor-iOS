//
//  Payment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UITableView
import Stripe

class BankManagerView : MainLayoutTitleBackTwoButton {
    
    fileprivate var subtitleLabel     = LeftTextLabel()
    fileprivate var addPaymentMethod = NavbarButtonText()
    fileprivate var addBankAlert = UILabel()
    
    var tableView                   = UITableView()
    var header                     = UIView()
    
    override var rightButton: NavbarButton {
        get { return addPaymentMethod }
        set { addPaymentMethod = newValue as! NavbarButtonText }
    }
    
    override func configureView() {
        addSubview(subtitleLabel)
        addSubview(tableView)
        addSubview(header)
        addSubview(addPaymentMethod)
        addSubview(addBankAlert)
        super.configureView()
        
        title.label.text = "Payment"
        
        subtitleLabel.label.text = "Payment Methods"
        subtitleLabel.label.textAlignment = .left
        subtitleLabel.label.font = Fonts.createBoldSize(20)
        
        addPaymentMethod.allignRight()
        addPaymentMethod.label.label.text = "+"
        addPaymentMethod.label.label.font = Fonts.createSize(40)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
        
        header.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        
        addBankAlert.text = "Press the '+' to add a new payment method"
        addBankAlert.textColor = .white
        addBankAlert.font = Fonts.createSize(40)
        addBankAlert.adjustsFontSizeToFitWidth = true
        addBankAlert.adjustsFontForContentSizeCategory = true
        addBankAlert.numberOfLines = 3
        addBankAlert.isHidden = true
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalToSuperview().multipliedBy(0.1)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.label.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.25)
            make.width.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).inset(-20)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo((tableView.contentSize.height + 44) * CGFloat(Customer.sources.count))
            make.centerX.equalToSuperview()
        }
        addBankAlert.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        header.snp.makeConstraints { (make) in
            make.width.equalTo(tableView.snp.width)
            make.top.equalTo(tableView.snp.top)
            make.left.equalTo(tableView.snp.left)
            make.height.equalTo(1)
        }
    }
    
}

class BankManager : BaseViewController {
    
    override var contentView: BankManagerView {
        return view as! BankManagerView
    }

    override func loadView() {
        view = BankManagerView()
    }
    private var cards : [STPCard]!
    private var defaultCard : STPCard!
    private var observer : NSObjectProtocol!
    private var cardsToBeDeleted = [STPCard]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaultData.localDataManager.hasPaymentMethod { setCustomer() }
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CardManagerTableViewCell.self, forCellReuseIdentifier: "cardCell")
        
        observer = NotificationCenter.default.addObserver(forName: .CustomerUpdated, object: nil, queue: .main, using: { (notication) in
            
            if UserDefaultData.localDataManager.hasPaymentMethod { self.setCustomer() }
            else {
                self.contentView.addBankAlert.isHidden = false
                self.contentView.tableView.isHidden = true
                self.contentView.header.isHidden = true
            }
        })
        
        if UserDefaultData.localDataManager.numberOfCards >= 5 {
            contentView.addPaymentMethod.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if cardsToBeDeleted.count > 0 {
            for card in cardsToBeDeleted {
                Stripe.stripeManager.dettachSource(customer: Customer, deleting: card, completion: { (error) in
                    if let error = error { print(error.localizedDescription) }
                    else { print("Card Deleted: ", card.stripeID) }
                })
            }
        }
    }
    private func setCustomer() {
        cards = Customer?.sources as! [STPCard]
        defaultCard  = Customer?.defaultSource as! STPCard
        contentView.tableView.reloadData()
    }
    
    deinit {
        //additional deinit ish
        NotificationCenter.default.removeObserver(observer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.addPaymentMethod.isUserInteractionEnabled = true
        contentView.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        if (touchStartView == nil) {
            return
        } else if (touchStartView == contentView.addPaymentMethod){
            navigationController!.pushViewController(TutorPayment(), animated: true)
            contentView.addPaymentMethod.isUserInteractionEnabled = false
        }
    }
    
    private func defaultCardAlert(card: STPCard) {
        let alertController = UIAlertController(title: "Default Payment Method?", message: "Do you want this card to be your default Payment method?", preferredStyle: .actionSheet)
        let setDefault = UIAlertAction(title: "Set as Default", style: .default) { (alert) in
            Stripe.stripeManager.updateDefaultSource(customer: Customer, new: card, completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Default Updated")
                    self.contentView.tableView.reloadData()
                }
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(setDefault)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
}


extension BankManager: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CardManagerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardManagerTableViewCell
        
        insertBorder(cell: cell)
        cell.last4.text = cards[indexPath.row].last4
        cell.brand.image = STPImageLibrary.brandImage(for: cards[indexPath.row].brand)
        
        if cards[indexPath.row] == defaultCard { cell.defaultcard.isHidden = false }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //would probably want to show a message here saying that this will set the new card as Default.
        if cards[indexPath.row] != defaultCard {
            defaultCardAlert(card: cards[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove Card"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = UserDefaultData.localDataManager
            
            cardsToBeDeleted.append(cards[indexPath.row])
            cards.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            user.deleteCard()
            
            if user.numberOfCards == 0 {
                contentView.addBankAlert.isHidden = false
                contentView.tableView.isHidden = true
                contentView.header.isHidden = true
            } else {
                contentView.addBankAlert.isHidden = true
                contentView.tableView.isHidden = false
                contentView.header.isHidden = false
            }
            
            tableView.reloadData()
        }
    }
    
    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame:CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}
