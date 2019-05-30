//
//  Payment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//

import Stripe
import UIKit
import Lottie
import SwipeCellKit

class BankManagerVC: UIViewController {
    
    let contentView: BankManagerVCView = {
        let view = BankManagerVCView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    var loadingIndicator: LOTAnimationView = {
        let view = LOTAnimationView(name: "loadingNew")
        view.loopAnimation = true
        return view
    }()
    
    var acctId: String! {
        didSet {
            contentView.collectionView.reloadData()
        }
    }

    var bankList = [ExternalAccountsData]() {
        didSet {
            setBank()
        }
    }
    
    private var transactions = [BalanceTransaction.Data]()
    
    private var banks = [ExternalAccountsData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLoadingIndicator()
        setupDelegates()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Payment"
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
    
    func fetchBanks() {
        guard let tutor = CurrentUser.shared.tutor, let accountId = tutor.acctId else {
            return
        }
        
        StripeService.retrieveBankList(acctId: accountId) { error, list in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let list = list {
                self.bankList = list.data
            }
            self.hideLoadingAnimation()
            self.contentView.collectionView.reloadData()
        }
    }
    
    func fetchTransactions() {
        guard let tutor = CurrentUser.shared.tutor, let accountId = tutor.acctId else {
            return
        }
        StripeService.retrieveBalanceTransactionList(acctId: accountId) { (_, transactions) in
            guard let transactions = transactions else { return }
            self.transactions = transactions.data.filter({ (transactions) -> Bool in
                if transactions.amount != nil && transactions.amount! > 0 {
                    return true
                }
                return false
            })
            self.contentView.collectionView.reloadData()
        }
    }
    
    func setupDelegates() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBanks()
        fetchTransactions()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setBank() {
        banks = bankList
        contentView.collectionView.reloadData()
    }

    // TODO: Check if they have any pending sessions.

    private func defaultBankAlert(bankId: String) {
        let alertController = UIAlertController(title: "Default Payout Method?", message: "Do you want this card to be your default payout method?", preferredStyle: .actionSheet)
        let setDefault = UIAlertAction(title: "Set as Default", style: .default) { _ in
            StripeService.updateDefaultBank(account: CurrentUser.shared.tutor.acctId, bankId: bankId, completion: { error, account in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                } else if let account = account {
                    self.bankList = account.data
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

extension BankManagerVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? banks.count : transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 50
        if indexPath.section == 1 {
            height = 40
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bankCell", for: indexPath) as! BankManagerCollectionViewCell
            cell.updateUI(banks[indexPath.item])
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "earningsCell", for: indexPath) as! EarningsHistoryCell
            cell.updateUI(transactions[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == banks.count {
            if banks.count == 5 {
                AlertController.genericErrorAlert(self, title: "Too Many Payout Methods", message: "We currently only allow users to have 5 payout methods.")
                return
            }
        } else {
            defaultBankAlert(bankId: banks[indexPath.row].id)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! BankManagerHeaderView
        view.delegate = self
        
        if indexPath.section == 0 {
            return view
        } else {
            view.titleLabel.text = "Earning history"
            view.addBankButton.isHidden = true
            return view
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }

}

extension BankManagerVC: BankManagerHeaderViewDelegate {
    func bankManagerHeaderViewDidTapAddBankButton(_ bankManagerHeaderView: BankManagerHeaderView) {
        let vc = TutorAddBank()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension BankManagerVC: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.removeBankAt(indexPath)
        }
        
        deleteAction.image = UIImage(named: "deleteCellIcon")
        deleteAction.highlightedImage = UIImage(named: "deleteCellIcon")?.alpha(0.2)
        deleteAction.font = Fonts.createSize(16)
        deleteAction.backgroundColor = Colors.darkBackground
        deleteAction.highlightedBackgroundColor = Colors.darkBackground
        
        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        return options
    }
    
    func removeBankAt(_ indexPath: IndexPath) {
        StripeService.removeBank(account: CurrentUser.shared.tutor.acctId, bankId: banks[indexPath.row].id) { error, bankList in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let bankList = bankList {
                self.banks.remove(at: indexPath.row)
                self.contentView.collectionView.deleteItems(at: [indexPath])
                self.bankList = bankList.data
                guard self.bankList.count > 0 else { return CurrentUser.shared.tutor.hasPayoutMethod = false }
            }
        }
    }
    
}
