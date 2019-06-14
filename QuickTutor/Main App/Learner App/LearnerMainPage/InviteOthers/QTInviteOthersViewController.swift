//
//  QTInviteOthersViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class QTInviteOthersViewController: UIViewController {

    // MARK - Properties
    @IBOutlet weak var tableView: UITableView!
    
    static var controller: QTInviteOthersViewController {
        return QTInviteOthersViewController(nibName: String(describing: QTInviteOthersViewController.self), bundle: nil)
    }
    
    var contactConnected = false
    
    var selectedContacts = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let contactStore = CNContactStore()
    var dataSource = [CNContact]()
    var checkedStates = [Bool]()
    let appStoreUrl = "http://bit.ly/DownloadQuickTutor"
    
    let headerHeight: CGFloat = 361
    let headerView = QTInviteOthersHeaderView.view
    
    var sectionHeaderView : QTInviteOthersSectionHeaderView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        navigationItem.title = "Share QuickTutor"
        let inviteButton = UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(sendInvite))
        inviteButton.setTitleTextAttributes([.font : Fonts.createSemiBoldSize(14)], for: .normal)
        inviteButton.setTitleTextAttributes([.font : Fonts.createSemiBoldSize(14)], for: .selected)
        navigationItem.rightBarButtonItem = inviteButton
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupTableView()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            contactConnected = true
            getContactList()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.tableHeaderView?.frame.size.height = headerHeight
        tableView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the tab bar.
        hideTabBar(hidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabBar(hidden: false)
    }
    
    // MARK: - Actions
    @objc func sendInvite() {
        if selectedContacts.count < 1 {
            return
        }
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.delegate = self
            controller.messageComposeDelegate = self
            controller.body = "Go check out QuickTutor! \n \(appStoreUrl)"
            controller.recipients = self.selectedContacts
            self.present(controller, animated: true, completion: nil)
            
        } else {
            AlertController.genericErrorAlert(self, title: "Unable to send text!", message: "Sorry, we can no send SMS messages at this time.")
        }
    }
    
    // MARK: - Functions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // Register resuable cells and set dimensions for table view.
        tableView.register(QTInviteOthersConnectTableViewCell.nib, forCellReuseIdentifier: QTInviteOthersConnectTableViewCell.reuseIdentifier)
        tableView.register(QTInviteOthersContactTableViewCell.nib, forCellReuseIdentifier: QTInviteOthersContactTableViewCell.reuseIdentifier)
        
    
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 47
        
        // Set the header view to table view.
        
        headerView.didClickCopyLinkButton = {
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.appStoreUrl
            AlertController.genericAlertWithoutCancel(self, title: "QuickTutor", message: "Copied!")
        }
        headerView.didClickShareButton = {
            let ac = UIActivityViewController(activityItems: [self.appStoreUrl], applicationActivities: nil)
            self.present(ac, animated: true, completion: nil)
        }
        headerView.frame.size.height = headerHeight
        tableView.tableHeaderView = headerView
    }
    
    func getContactList() {
        var contacts: [CNContact] = []
        do {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            
            try contactStore.enumerateContacts(with: request) { contact, _ in
                contacts.append(contact)
            }
        } catch {
            AlertController.genericErrorAlert(self, title: "Oops!", message: "We were unable to fetch your contacts.")
        }
        DispatchQueue.main.async {
            self.dataSource = contacts
            self.checkedStates.removeAll()
            contacts.forEach({ _ in
                self.checkedStates.append(false)
            })
            if self.dataSource.count == 0 {
                self.navigationItem.rightBarButtonItem = nil
            }
            self.tableView.reloadData()
        }
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            contactStore.requestAccess(for: .contacts) { granted, _ in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        }
    }
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to Contacts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            completionHandler(false)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
    
}

// MARK: - MFMessageComposeViewControllerDelegate
extension QTInviteOthersViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension QTInviteOthersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If the selected cell is not kind of QTInviteOthersContactTableViewCell, just return.
        guard let _ = tableView.cellForRow(at: indexPath) as? QTInviteOthersContactTableViewCell else { return }
        
        // Update checked status of a cell
        checkedStates[indexPath.row] = !checkedStates[indexPath.row]
        
        // Add or remove phone number from the selected contacts based on a check status.
        guard let phoneNumber = dataSource[indexPath.row].phoneNumbers.first?.value.stringValue else {
            return
        }
        if checkedStates[indexPath.row] {
            if !selectedContacts.contains(phoneNumber) {
                selectedContacts.append(phoneNumber)
            }
        } else {
            if let index = selectedContacts.firstIndex(of: phoneNumber), index >= 0 {
                selectedContacts.remove(at: index)
            }
        }
        
        // Reload table view to display checked status.
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension QTInviteOthersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactConnected ? dataSource.count : 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeaderView = QTInviteOthersSectionHeaderView.view
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        if contactConnected {
            if let cell = tableView.dequeueReusableCell(withIdentifier: QTInviteOthersContactTableViewCell.reuseIdentifier, for: indexPath) as? QTInviteOthersContactTableViewCell {
                cell.didClickCheckButton = { checked in
                    self.checkedStates[indexPath.row] = checked
                    self.tableView.reloadData()
                }
                cell.setData(dataSource[indexPath.row], checked: checkedStates[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: QTInviteOthersConnectTableViewCell.reuseIdentifier, for: indexPath) as? QTInviteOthersConnectTableViewCell {
                cell.didClickConnectButton = {
                    self.requestAccess { success in
                        self.contactConnected = success
                        if success {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.getContactList()
                            }
                        } else {
                            AlertController.genericErrorAlert(self, title: "Unable to gain access to your contacts", message: "Try going to settings>privacy> and allowing Contacts.")
                        }
                    }
                }
                cell.selectionStyle = .none
                return cell
            }
        }
        
        return cell
    }
    
}

// MARK: -
extension QTInviteOthersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            // If the duration section view is at the top of screen, will show the drop shadow
            if scrollView.contentOffset.y >= headerView.frame.height {
                self.sectionHeaderView?.layer.applyShadow(color: UIColor.black.cgColor,
                                                     opacity: 0.2,
                                                     offset: CGSize(width: 0, height: 10),
                                                     radius: 10)
                return
            }
            
            // If the content offset of tableview is about zero, will hide the drop shadow
            if scrollView.contentOffset.y <= headerView.frame.height / 2 {
                self.sectionHeaderView?.layer.shadowOpacity = 0.0
            }
        }
    }
}
