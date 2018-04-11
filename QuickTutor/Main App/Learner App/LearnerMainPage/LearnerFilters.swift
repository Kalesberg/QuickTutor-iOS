//
//  LearnerFilters.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class LearnerFiltersView : MainLayoutTitleOneButton {
    
    var xButton = NavbarButtonX()
    
    override var leftButton: NavbarButton {
        get {
            return xButton
        } set {
            xButton = newValue as! NavbarButtonX
        }
    }
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    override func configureView() {
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "Filters"
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}

class LearnerFilters: BaseViewController {
    
    override var contentView: LearnerFiltersView {
        return view as! LearnerFiltersView
    }
    
    override func loadView() {
        view = LearnerFiltersView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
    }
    
    @objc
    private func rateSliderValueDidChange(_ sender: UISlider!) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)
        
        cell.valueLabel.text = "$" + String(Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
    }
    
    @objc
    private func distanceSliderValueDidChange(_ sender: UISlider!) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EditProfileSliderTableViewCell)
        let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
        
        if(value % 5 == 0) {
            cell.valueLabel.text = String(value) + " mi"
        }
    }
}

extension LearnerFilters : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 30
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
        case 0:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
            
            cell.slider.addTarget(self, action: #selector(rateSliderValueDidChange), for: .valueChanged)
            cell.slider.minimumTrackTintColor = Colors.learnerPurple
            
            //set users current value to slider.value and valueLabel.text
            //cell.slider.value = CGFloat(user.rate)
            //cell.valueLabel.text = "$" + user.rate
            
            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 100
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Maximum Hourly Rate  ", 15, .white)
                .regular("  [$5-$100]", 15, Colors.grayText)
            
            cell.header.attributedText = formattedString
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
            
            cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)
            cell.slider.minimumTrackTintColor = Colors.learnerPurple
            
//            cell.slider.value = CGFloat(user.distance)
//            cell.valueLabel.text = user.distance + " mi"
            
            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 150
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Maximum Travel Distance  ", 15, .white)
                .regular("  [0-150 mi]", 15, Colors.grayText)
            
            cell.header.attributedText = formattedString
            
            return cell
        case 3:
            let cell = UITableViewCell()
            
            cell.backgroundColor = .clear
            
            let label = UILabel()
            cell.contentView.addSubview(label)
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Distance Setting\n", 16, .white)
                .regular("You will only be able to view tutors who are within your set maximum distance setting.\n\n", 15, Colors.grayText)
                .bold("Video Calls - Search the World\n", 16, .white)
                .regular("This option enables you to also view tutors around the world, so you can connect for video call sessions.\n\n", 15, Colors.grayText)
                .bold("Hourly Rate\n", 16, .white)
                .regular("We'll provide you with tutors who are within your price range. However, each individual session is negotiable to any price.", 15, Colors.grayText)
            
            label.attributedText = formattedString
            label.numberOfLines = 0
            
            label.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
}
