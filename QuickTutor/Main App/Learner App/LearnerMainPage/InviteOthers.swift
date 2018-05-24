//
//  InviteOthers.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import MessageUI

class InviteOthersView : MainLayoutTitleBackTwoButton {
    
    var inviteButton = NavbarButtonInvite()
    
    let container : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.green
        view.layer.cornerRadius = 5
        
        return view
    }()
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(16)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Share QuickTutor with your friends and family. Invite them to join the party! 🎉"
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
	
	let searchTextField : RegistrationTextField = {
		let textField = RegistrationTextField()
		textField.placeholder.text = "Search Contacts"
		textField.textField.font = Fonts.createSize(16)
		textField.textField.tintColor = (AccountService.shared.currentUserType == .learner) ? Colors.learnerPurple : Colors.tutorBlue
		return textField
	}()
	
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.rowHeight = 50
        tableView.backgroundColor = Colors.registrationDark
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorColor = Colors.divider
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = true
		tableView.isUserInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
		
        return tableView
    }()
	
	let connectContacts = InviteOthersBackgroundView()
	
    override var rightButton: NavbarButton {
        get {
            return inviteButton
        } set {
            inviteButton = newValue as! NavbarButtonInvite
        }
    }
    
    override func configureView() {
        addSubview(container)
        container.addSubview(label)
		addSubview(searchTextField)
        addSubview(tableView)
		addSubview(connectContacts)
        super.configureView()
        
        navbar.backgroundColor = Colors.green
        statusbarView.backgroundColor = Colors.green
        title.label.text = "Share QuickTutor"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        container.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom).inset(-20)
        }
        
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(5)
        }
		searchTextField.snp.makeConstraints { (make) in
			make.top.equalTo(container.snp.bottom).inset(-20)
			make.width.equalToSuperview().multipliedBy(0.95)
			make.centerX.equalToSuperview()
			make.height.equalTo(80)
		}
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchTextField.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
		connectContacts.snp.makeConstraints { (make) in
			make.top.equalTo(container.snp.bottom).inset(-20)
			make.width.centerX.equalToSuperview()
			make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
		}
    }
}

class InviteOthersButton : InteractableView, Interactable {
    
    let label : UILabel = {
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
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

class InviteOthersBackgroundView : InteractableView, Interactable {
    
    let label : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .bold("Connect your Contacts", 24, .white)
            .regular("\n\nConnect your phone contacts to invite some peeps!", 17, .white)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let button = InviteOthersButton()
    
    override func configureView() {
        addSubview(label)
        addSubview(button)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalTo(250)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-80)
        }
        
        button.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(50)
            make.top.equalTo(label.snp.bottom).inset(-25)
            make.centerX.equalToSuperview()
        }
    }
}


class InviteOthers : BaseViewController {
    
    override var contentView: InviteOthersView {
        return view as! InviteOthersView
    }
    
    override func loadView() {
        view = InviteOthersView()
    }
    
    private let contactStore = CNContactStore()
	private var automaticScroll : Bool = false
	
	private var shouldFilterSearchResults : Bool = false {
		didSet {
			contentView.tableView.reloadData()
		}
	}

	private var selectedContacts = [String]() {
		didSet {
			contentView.tableView.reloadData()
		}
	}

	private var datasource : [CNContact] = [] {
		didSet {
			//contentView.tableView.isHidden = (datasource.count == 0)
		}
	}
	
	private var filteredContacts : [CNContact] = [] {
		didSet {
			contentView.tableView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
			contentView.connectContacts.removeFromSuperview()
			getContactList()
		}
		
		contentView.searchTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(InviteContactsTableViewCell.self, forCellReuseIdentifier: "contactCell")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	private func getContactList() {
		var contacts : [CNContact] = []
		do {
			self.displayLoadingOverlay()
			let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
			let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
			
			try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact, stop) in
				contacts.append(contact)
				self.dismissOverlay()
			})
		}
		catch {
			print("unable to fetch contacts")
		}
		DispatchQueue.main.async {
			self.datasource = contacts
			self.contentView.inviteButton.isHidden = (self.datasource.count == 0)
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
            contactStore.requestAccess(for: .contacts) { granted, error in
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
		
		self.filteredContacts = self.datasource.filter {
			let name = "\($0.givenName) \($0.familyName)"
			return name.lowercased().contains(text.lowercased()) }
		if filteredContacts.count > 0 {
			scrollToTop()
		}
	}
	private func messageContacts() {
		if selectedContacts.count < 1 {
			return
		}
		if (MFMessageComposeViewController.canSendText()) {
			let controller = MFMessageComposeViewController()
			controller.delegate = self
			controller.messageComposeDelegate = self
			controller.body = "Go check out QuickTutor!"
			controller.recipients = selectedContacts
			present(controller, animated: true, completion: nil)
		} else {
			print("unable to send text")
		}
	}
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to Contacts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            completionHandler(false)
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
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
        if touchStartView is NavbarButtonInvite {
            messageContacts()
		} else if touchStartView == contentView.connectContacts.button {
			self.requestAccess { (success) in
				if success {
					DispatchQueue.main.async {
						self.contentView.connectContacts.isHidden = true
						self.getContactList()
					}
				} else {
					print("unable to get access")
				}
			}
		}
    }
}
extension InviteOthers : UIScrollViewDelegate {
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
}
extension InviteOthers : UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
	
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
extension InviteOthers : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

class InviteContactsTableViewCell : UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    let label : UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(16)
        label.textColor = .white
        
        return label
    }()
	
	let cellBackground = UIView()
	let checkbox = RegistrationCheckbox()

	func configureTableViewCell() {
        addSubview(label)
		addSubview(checkbox)
		
		checkbox.isSelected = false
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
		backgroundColor = .clear
		
        applyConstraints()
    }

	func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
		checkbox.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.centerY.equalToSuperview()
			make.width.equalTo(50)
		}
    }
}
