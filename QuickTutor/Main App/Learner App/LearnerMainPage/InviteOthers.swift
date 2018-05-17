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
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.rowHeight = 40
        tableView.backgroundColor = Colors.registrationDark
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorColor = Colors.divider
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = true
		tableView.tableFooterView = UIView()
		
		return tableView
    }()
    
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
        addSubview(tableView)
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
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom).inset(-20)
            make.width.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}


class InviteOthersTableViewBackground : BaseView {
    
    let label : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .bold("Connect your Contacts\n", 24, .white)
            .regular("\nConnect your phone contacts to invite some peeps!", 17, .white)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalTo(250)
            make.center.equalToSuperview()
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
	
	let contactStore = CNContactStore()
	
	var datasource = [CNContact]() {
		didSet {
			if datasource.count == 0 {
				print("Here.")
				let view = InviteOthersTableViewBackground()
				
				contentView.tableView.backgroundView = view
			}
			print("Here1.")
			contentView.tableView.reloadData()
		}
	}
	let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		datasource = []
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
		contentView.tableView.register(InviteContactsTableViewCell.self, forCellReuseIdentifier: "contactCell")
		
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		requestAccess { (success) in
//			if success {
//				do {
//					try self.contactStore.enumerateContacts(with: self.request, usingBlock: { (contact, stop) in
//						self.datasource.append(contact)
//					})
//				}
//				catch {
//					print("unable to fetch contacts")
//				}
//			}
//		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
	
	private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
		let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
			completionHandler(false)
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
			completionHandler(false)
		})
		present(alert, animated: true)
	}
	
    override func handleNavigation() {
        if touchStartView is NavbarButtonInvite {
            
        }
    }
}

extension InviteOthers : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print(datasource.count)
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! InviteContactsTableViewCell
		
		cell.label.text = datasource[indexPath.row].givenName

        return cell
    }
}

class InviteContactsTableViewCell : BaseTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		label.font = Fonts.createBoldSize(14)
		label.textColor = .white
		
		return label
	}()
	
	override func configureView() {
		addSubview(label)
		super.configureView()
		
		backgroundColor = .clear
		selectionStyle = .none
		
		applyConstraints()
	}
	
	override func applyConstraints() {
			label.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview().inset(15)
			make.top.bottom.equalToSuperview()
		}
	}
}
