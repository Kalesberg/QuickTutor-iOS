//
//  InviteOthers.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Contacts
import Foundation
import MessageUI
import UIKit

class InviteOthersButton: InteractableBackgroundView {
    let label: UILabel = {
        let label = UILabel()
        label.text = "Connect"
        label.textColor = Colors.registrationDark
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(18)
        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()

        backgroundColor = .white
        layer.cornerRadius = 5
        isUserInteractionEnabled = true

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}



class InviteOthersVC: BaseViewController {
    override var contentView: InviteOthersView {
        return view as! InviteOthersView
    }

    override func loadView() {
        view = InviteOthersView()
    }

    private let contactStore = CNContactStore()
    private var automaticScroll: Bool = false

    private var shouldFilterSearchResults: Bool = false {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    private var selectedContacts = [String]() {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    private var datasource = [CNContact]()

    private var filteredContacts = [CNContact]() {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            contentView.connectContacts.removeFromSuperview()
            getContactList()
        }

        contentView.searchTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(InviteContactsTableViewCell.self, forCellReuseIdentifier: "contactCell")
        navigationItem.title = "Share QuickTutor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(sendInvite))
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func sendInvite() {
        if selectedContacts.count < 1 {
            return
        }
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.delegate = self
            controller.messageComposeDelegate = self
            controller.body = "Go check out QuickTutor! \n itms-apps://itunes.apple.com/app/id1388092698"
            controller.recipients = self.selectedContacts
            self.present(controller, animated: true, completion: nil)
            
        } else {
            AlertController.genericErrorAlert(self, title: "Unable to send text!", message: "Sorry, we can no send SMS messages at this time.")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func getContactList() {
        var contacts: [CNContact] = []
        do {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

            try contactStore.enumerateContacts(with: request) { contact, _ in
                contacts.append(contact)
            }
        } catch {
            AlertController.genericErrorAlert(self, title: "Oops!", message: "We were unable to fetch your contacts.")
        }
        DispatchQueue.main.async {
            self.datasource = contacts
            if self.datasource.count == 0 {
                self.navigationItem.rightBarButtonItem = nil
            }
            self.contentView.tableView.reloadData()
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

    @objc private func textFieldDidChange(_ textField: UITextField) {
        automaticScroll = true
        guard let text = textField.text else {
            automaticScroll = false
            shouldFilterSearchResults = false
            return
        }
        if text == "" {
            automaticScroll = false
            shouldFilterSearchResults = false
            return
        }
        shouldFilterSearchResults = true

        filteredContacts = datasource.filter {
            let name = "\($0.givenName) \($0.familyName)"
            return name.localizedCaseInsensitiveContains(text)
        }
        if filteredContacts.count > 0 {
            scrollToTop()
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

    private func scrollToTop() {
        contentView.tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        automaticScroll = false
    }

    override func handleNavigation() {
      if touchStartView == contentView.connectContacts.button {
            requestAccess { success in
                if success {
                    DispatchQueue.main.async {
                        self.contentView.connectContacts.isHidden = true
                        self.getContactList()
                    }
                } else {
                    AlertController.genericErrorAlert(self, title: "Unable to gain access to your contacts", message: "Try going to settings>privacy> and allowing Contacts.")
                }
            }
        }
    }
}

extension InviteOthersVC: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }
}

extension InviteOthersVC: UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            controller.dismiss(animated: true, completion: nil)

        case .cancelled:
            controller.dismiss(animated: true, completion: nil)

        case .failed:
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

extension InviteOthersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return shouldFilterSearchResults ? filteredContacts.count : datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! InviteContactsTableViewCell

        let data = shouldFilterSearchResults ? filteredContacts[indexPath.row] : datasource[indexPath.row]

        cell.label.text = data.givenName + " " + data.familyName

        guard let phoneNumber = data.phoneNumbers.first?.value.stringValue else {
            cell.checkbox.isSelected = false
            return cell }
        cell.checkbox.isSelected = selectedContacts.contains(phoneNumber)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? InviteContactsTableViewCell else { return }
        cell.handleTouchDown()
        let data = shouldFilterSearchResults ? filteredContacts[indexPath.row] : datasource[indexPath.row]
        guard let phoneNumber = data.phoneNumbers.first?.value.stringValue else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if selectedContacts.contains(phoneNumber) {
            cell.checkbox.isSelected = false
            selectedContacts.remove(at: selectedContacts.index(of: phoneNumber)!)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        cell.checkbox.isSelected = true
        selectedContacts.append(phoneNumber)
    }
}

class InviteContactsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
        selectionStyle = .none
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                handleTouchDown()
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let label: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(16)
        label.textColor = .white
        return label
    }()

    let cellBackground = UIView()
    let checkbox = RegistrationCheckbox()
    
    func handleTouchDown() {
        backgroundColor = Colors.registrationDark.darker(by: 30)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.backgroundColor = Colors.registrationDark
        }
    }

    func configureTableViewCell() {
        addSubview(label)
        addSubview(checkbox)
        checkbox.isSelected = false
        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.grayText
        selectedBackgroundView = cellBackground
        backgroundColor = Colors.registrationDark
        applyConstraints()
    }

    func applyConstraints() {
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
        checkbox.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
    }
}
