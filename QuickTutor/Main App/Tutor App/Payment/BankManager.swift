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
import Firebase

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
    
    private var pastSessions = [Session]()
    
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
        guard let uid = Auth.auth().currentUser?.uid, self.pastSessions.isEmpty else { return }
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
            
            group.notify(queue: .main) {
                self.contentView.collectionView.reloadSections(IndexSet(integer: 1))
            }
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
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(setDefault)
        alertController.addAction(cancel)

        present(alertController, animated: true, completion: nil)
    }
}

extension BankManagerVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? banks.count : pastSessions.count
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
            cell.updateUI(pastSessions[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        if indexPath.row == banks.count {
            if banks.count == 5 {
                AlertController.genericErrorAlert(self, title: "Too Many Payout Methods", message: "We currently only allow users to have 5 payout methods.")
                return
            }
        } else {
            let bank = banks[indexPath.item]
            if !bank.default_for_currency {
                defaultBankAlert(bankId: bank.id)
            }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! BankManagerHeaderView
        view.delegate = self
        
        if indexPath.section == 0 {
            view.titleLabel.text = "Banks"
            view.addBankButton.isHidden = false
        } else {
            view.titleLabel.text = "Earning history"
            view.addBankButton.isHidden = true
        }
        
        return view
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if 0 == section {
            return banks.isEmpty ? .zero : CGSize(width: collectionView.frame.width, height: 50)
        } else {
            return pastSessions.isEmpty ? .zero : CGSize(width: collectionView.frame.width, height: 50)
        }
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
        if orientation == .left || 1 == banks.count { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            let alert = UIAlertController(title: "Remove a bank account",
                                          message: "Are you sure you want to remove this bank account?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                self.removeBankAt(indexPath)
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
