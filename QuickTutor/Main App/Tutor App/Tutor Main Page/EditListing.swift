//
//  EditListing.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class EditListingView : MainLayoutTitleBackTwoButton {
    
    var saveButton = NavbarButtonSave()
    
    override var rightButton: NavbarButton {
        get {
            return saveButton
        } set {
            saveButton = newValue as! NavbarButtonSave
        }
    }
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    override func configureView() {
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "Edit Listing"
        
        navbar.backgroundColor = UIColor(hex: "5785D4")
        statusbarView.backgroundColor = UIColor(hex: "5785D4")
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

class EditListing : BaseViewController {
    
    override var contentView: EditListingView {
        return view as! EditListingView
    }
    
    override func loadView() {
        view = EditListingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(EditListingsSubjectsTableViewCell.self, forCellReuseIdentifier: "editListingsSubjectsTableViewCell")
        contentView.tableView.register(EditListingPhotoTableViewCell.self, forCellReuseIdentifier: "editListingPhotoTableViewCell")
        contentView.tableView.register(EditProfileHourlyRateTableViewCell.self, forCellReuseIdentifier: "editProfileHourlyRateTableViewCell")
    }
    
    @objc func handleAddButton() {
        print("add button pressed")
    }
}


extension EditListing : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 275
        case 1:
            return 90
        case 2:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editListingPhotoTableViewCell", for: indexPath) as! EditListingPhotoTableViewCell
            
            cell.addButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editListingsSubjectsTableViewCell", for: indexPath) as! EditListingsSubjectsTableViewCell
            
            cell.label.text = "Choose featured subject:"
            
            //cell.datasource = tutor.subjects
            cell.datasource = ["fortnite", "smash bros", "halo 15", "gta XXVI", "god of war"]
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHourlyRateTableViewCell", for: indexPath) as! EditProfileHourlyRateTableViewCell
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .regular("\n", 12, .white)
                .bold("Choose hourly rate:", 18, .white)
                .regular("\n", 5, .white)
                .bold("\nHourly Rate  ", 15, .white)
                .regular("  [$5-$1000]\n", 15, Colors.grayText)
                .regular("\n", 8, .white)
                .regular("Please set your listing rate.\n\nThis is the rate that learners will see on your listing.", 14, Colors.grayText)
            
            cell.header.attributedText = formattedString
            cell.textField.text = "$0"
            
            cell.header.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview().inset(10)
            }
            
            cell.container.snp.remakeConstraints { (make) in
                make.top.equalTo(cell.header.snp.bottom).inset(-20)
                make.centerX.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.95)
                make.height.equalTo(70)
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

class EditListingsSubjectsTableViewCell : SubjectsTableViewCell {}

extension EditListingsSubjectsTableViewCell {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SubjectSelectionCollectionViewCell else { return }
        
        cell.labelContainer.layer.borderWidth = 2
    }
}

class EditListingPhotoTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    let container = UIView()
    
    let listingImage : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "registration-image-placeholder")
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    let addButton : UIButton = {
        let button = UIButton()
        
        button.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        button.backgroundColor = Colors.green
        button.layer.cornerRadius = 17.5
        
        return button
    }()
    
    let listingLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(18)
        label.text = "Your listing picture"
        label.textColor = .white
        
        return label
    }()
    
    let labelContainer = UIView()
    
    func configureView() {
        addSubview(container)
        container.addSubview(listingImage)
        addSubview(addButton)
        addSubview(labelContainer)
        labelContainer.addSubview(listingLabel)
    
        selectionStyle = .none
        backgroundColor = .clear
        
        applyConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        container.applyGradient(firstColor: UIColor(hex: "456AA8").cgColor, secondColor: UIColor(hex: "5785D4").cgColor, angle: 0, frame: container.bounds)
        
        labelContainer.applyGradient(firstColor: UIColor(hex: "456AA8").cgColor, secondColor: UIColor(hex: "5785D4").cgColor, angle: 90, frame: labelContainer.bounds)
    }
    
    func applyConstraints() {
        container.snp.makeConstraints { (make) in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(225)
        }
        
        listingImage.snp.makeConstraints { (make) in
            make.height.width.equalTo(150)
            make.center.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(listingImage).inset(-15)
            make.height.width.equalTo(35)
        }
        
        labelContainer.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom).inset(-1)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(45)
        }
        
        listingLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}

