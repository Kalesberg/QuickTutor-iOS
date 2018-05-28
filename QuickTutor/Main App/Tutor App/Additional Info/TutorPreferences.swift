//
//  TutorPreferences.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorPreferencesNextButton : InteractableView, Interactable {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(21)
        label.textColor = .white
        label.text = "Next"
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        backgroundColor = Colors.tutorBlue
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func touchStart() {
        backgroundColor = Colors.lightBlue
    }
    
    func didDragOff() {
        backgroundColor = Colors.tutorBlue
    }
}


class TutorRegistrationLayout : MainLayoutTitleBackTwoButton {
    
    var nextButton = NavbarButtonNext()
    
    override var rightButton: NavbarButton {
        get {
            return nextButton
        }
        set {
            nextButton = newValue as! NavbarButtonNext
        }
    }
    
    let progressBar = ProgressBar()
    
    override func configureView() {
        addSubview(progressBar)
        addSubview(nextButton)
        super.configureView()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        progressBar.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.height.equalTo(8)
        }
    }
}


class TutorPreferencesView : TutorRegistrationLayout {
    
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
        
        title.label.text = "Set Your Preferences"
        
        addSubview(progressBar)
        progressBar.progress = 0.16667
        progressBar.applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-8)
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

class TutorPreferences : BaseViewController {
    
    override var contentView: TutorPreferencesView {
        return view as! TutorPreferencesView
    }
    
    var price : Int = 5
    var distance : Int = 5
    var inPerson : Bool = true
    var inVideo : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
    }
    
    override func loadView() {
        view = TutorPreferencesView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

	private func configureDelegates() {
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
        contentView.tableView.register(EditProfileHourlyRateTableViewCell.self, forCellReuseIdentifier: "editProfileHourlyRateTableViewCell")
		contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
		contentView.tableView.register(EditProfileCheckboxTableViewCell.self, forCellReuseIdentifier: "editProfileCheckboxTableViewCell")
	}
    
    @objc
    private func distanceSliderValueDidChange(_ sender: UISlider) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)
        let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
        
        cell.valueLabel.text = "\(value) mi"
        distance = value
    }
    
    private func setUserPreferences() {
        
        TutorRegistration.price = price
        TutorRegistration.distance = distance
        
        if inPerson && inVideo {
            TutorRegistration.sessionPreference = 3
        } else if inPerson && !inVideo {
            TutorRegistration.sessionPreference = 2
        } else if !inPerson && inVideo {
            TutorRegistration.sessionPreference = 1
        } else {
            TutorRegistration.sessionPreference = 0
        }
    }
    
    override func handleNavigation() {
        if (touchStartView is NavbarButtonNext) {
            setUserPreferences()
			let next = TutorBio()
			navigationController?.pushViewController(next, animated: true)
        }
    }
}


extension TutorPreferences : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {

        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return 40
        case 3:
            return 40
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHourlyRateTableViewCell", for: indexPath) as! EditProfileHourlyRateTableViewCell
            
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .regular("\n", 5, .white)
                .bold("\nHourly Rate  ", 15, .white)
                .regular("  [$5-$1000]\n", 15, Colors.grayText)
                .regular("\n", 8, .white)
                .regular("Please set your general hourly rate.\n\nAlthough you have a set rate, individual sessions can be negotiable.", 14, Colors.grayText)
            
            cell.header.attributedText = formattedString
            cell.rateLabel.text = "$0.00"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
            
            cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)
            
            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 150
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .regular("\n", 5, .white)
                .bold("\nTravel Distance  ", 15, .white)
                .regular("  [0-150 mi]\n", 15, Colors.grayText)
                .regular("\n", 8, .white)
                .regular("Please set the maximum number of miles you are willing to travel for a tutoring session.", 14, Colors.grayText)
            
            cell.header.attributedText = formattedString
            
            cell.valueLabel.text = "5 mi"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell
            
            cell.label.text = "Tutoring In-Person Sessions?"
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell
            
            cell.label.text = "Tutoring Online (Video Call) Sessions?"
            
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
}
