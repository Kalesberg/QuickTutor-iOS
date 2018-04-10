//
//  TaxInformation.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorTaxInfoView : MainLayoutTitleBackButton {
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    
    override func configureView() {
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "Tax Information"
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
    }
    
}

class TutorTaxInfo : BaseViewController {
    
    override var contentView: TutorTaxInfoView {
        return view as! TutorTaxInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(EditProfileDotItemTableViewCell.self, forCellReuseIdentifier: "editProfileDotItemTableViewCell")
        contentView.tableView.register(EditProfileHeaderTableViewCell.self, forCellReuseIdentifier: "editProfileHeaderTableViewCell")
    }
    override func loadView() {
        view = TutorTaxInfoView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        
    }
}


extension TutorTaxInfo : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 130
        case 1:
            return 30
        case 2:
            return 10
        case 3:
            return 75
        case 4:
            return 75
        case 5:
            return 75
        case 6:
            return 50
        case 7:
            return 75
        case 8:
            return 75
        case 9:
            return 75
        case 10:
            return 75
        case 11:
            return 35
        case 12:
            return 65
        case 13:
            return 90
        case 14:
            return 60
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
        case 0:
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            let view = UIView()
            view.backgroundColor = UIColor(hex: "AF1C49")
            view.layer.cornerRadius = 7
            
            let label = UILabel()
            label.text = "Please ensure your information below is accurate before saving it."
            label.font = Fonts.createSize(18)
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 0
            
            cell.addSubview(view)
            cell.addSubview(label)
            view.snp.makeConstraints { (make) in
                make.height.equalTo(75)
                make.width.equalToSuperview()
                make.center.equalToSuperview()
            }
            
            label.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "About Me"
            
            return cell
        case 2:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "First Name"
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter First Name",
                attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "Last Name"
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter Last Name",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "Date of Birth"
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter Date of Birth",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Address"
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "Street Address"
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter Street Address",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "City"
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter City",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "State"
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter State",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "Zipcode"
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter Zipcode",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Social Security Number"
            
            return cell
        case 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell

            cell.infoLabel.label.text = ""
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Enter Social Security Number",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 13:
            let cell = UITableViewCell()
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            let view = UIView()
            view.backgroundColor = UIColor(hex: "1EAD4A")
            view.layer.cornerRadius = 8
            
            let label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.textColor = .white
            label.font = Fonts.createSize(14)
            label.text = "Your information is encrypted and securely transferred using Secure Sockets Layer (SSL)."
            label.adjustsFontSizeToFitWidth = true
            
            cell.addSubview(view)
            cell.addSubview(label)
            
            view.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.height.equalTo(60)
                make.center.equalToSuperview()
            }
            
            label.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            return cell
        case 14:
            let cell = UITableViewCell()
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            let button = SubmitButton()
            button.backgroundColor = Colors.tutorBlue
            button.label.label.text = "Submit"
            
            cell.addSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.height.equalTo(40)
                make.center.equalToSuperview()
            }
            
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
}
