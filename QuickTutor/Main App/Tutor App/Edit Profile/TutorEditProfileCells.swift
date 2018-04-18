//
//  TutorEditProfileCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class ProfileImagesTableViewCell : BaseTableViewCell {
    
    var image1 = ProfileImage1()
    var image2 = ProfileImage2()
    var image3 = ProfileImage3()
    var image4 = ProfileImage4()
	
    override func configureView() {
        contentView.addSubview(image1)
        contentView.addSubview(image2)
        contentView.addSubview(image3)
        contentView.addSubview(image4)
        
        selectionStyle = .none
        backgroundColor = .clear		
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        var height : Int
        
        if (UIScreen.main.bounds.height == 568) {
            height = 67
        } else {
            height = 75
        }
        
        image1.snp.makeConstraints { (make) in
            make.height.equalTo(height)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        image2.snp.makeConstraints { (make) in
            make.height.equalTo(height)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.left.equalTo(image1.snp.right)
            make.centerY.equalToSuperview()
        }
        
        image3.snp.makeConstraints { (make) in
            make.height.equalTo(height)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.left.equalTo(image2.snp.right)
            make.centerY.equalToSuperview()
        }
        
        image4.snp.makeConstraints { (make) in
            make.height.equalTo(height)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
	override func handleNavigation() {
		guard let current = UIApplication.getPresentedViewController() else {
			return
		}
		if touchStartView == image1 {
			AlertController.cropImageAlert(current, imagePicker: imagePicker)
			imageToChange = 1
		} else if touchStartView == image2 {
			AlertController.cropImageAlert(current, imagePicker: imagePicker)
			imageToChange = 2
		} else if touchStartView == image3 {
			AlertController.cropImageAlert(current, imagePicker: imagePicker)
			imageToChange = 3
		} else if touchStartView == image4 {
			AlertController.cropImageAlert(current, imagePicker: imagePicker)
			imageToChange = 4
		}
	}
}

class EditProfileItemTableViewCell : BaseTableViewCell {
    
    var infoLabel = LeftTextLabel()
    var textField = NoPasteTextField()
    var sideLabel = RightTextLabel()
    var divider   = BaseView()
    var spacer    = BaseView()
    
    override func configureView() {
        contentView.addSubview(infoLabel)
        contentView.addSubview(textField)
        textField.addSubview(sideLabel)
        contentView.addSubview(divider)
        contentView.addSubview(spacer)
        
        backgroundColor = .clear
        selectionStyle = .none;
        
        divider.backgroundColor = Colors.divider
        
        infoLabel.label.font = Fonts.createBoldSize(15)
        
        textField.font = Fonts.createSize(18)
    
        applyConstraints()
    }
    
    override func applyConstraints() {
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        spacer.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }
        
        divider.snp.makeConstraints { (make) in
            make.top.equalTo(spacer.snp.top)
            make.height.equalTo(1)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }
        
        textField.snp.makeConstraints { (make) in
            make.bottom.equalTo(divider.snp.top)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }
        
        sideLabel.snp.makeConstraints { (make) in
            make.right.equalTo(infoLabel)
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(15)
        }
    }
}

class EditProfileDotItemTableViewCell : EditProfileItemTableViewCell {
    override func configureView() {
        super.configureView()
        
        sideLabel.label.font = Fonts.createSize(16)
        textField.textColor = Colors.grayText
        sideLabel.label.text = "•"
    }
}

class EditProfileArrowItemTableViewCell : EditProfileItemTableViewCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected) {
            //navigation
        }
    }
  
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            UIView.animate(withDuration: 0.2) {
                self.divider.backgroundColor = .white
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.divider.backgroundColor = Colors.divider
            }
        }
    }
    
    override func configureView() {
        super.configureView()
        
        textField.isUserInteractionEnabled = false
        sideLabel.label.font = Fonts.createBoldSize(25)
        sideLabel.label.text = "›"
    }
}

class EditProfilePolicyTableViewCell : EditProfileDotItemTableViewCell {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(13)
        label.textColor = Colors.grayText
        label.sizeToFit()
        label.numberOfLines = 0
        
        return label
    }()
    
    override func configureView() {
        contentView.addSubview(label)
        super.configureView()
  
    }
    
    override func applyConstraints() {
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(infoLabel.snp.bottom).inset(4)
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
        }
        
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).inset(-6)
            make.height.equalTo(30)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }
    
        sideLabel.snp.makeConstraints { (make) in
            make.right.equalTo(infoLabel)
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(15)
        }
        
        divider.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).inset(-5)
            make.height.equalTo(1)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}


class EditProfileHeaderTableViewCell : BaseTableViewCell {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(20)
        label.sizeToFit()
        
        return label
    }()
    
    override func configureView() {
        contentView.addSubview(label)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

class EditProfilePreferencesTableViewCell : BaseTableViewCell {
    
    let header : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(15)
        label.sizeToFit()
        label.text = "Preferences"
        
        return label
    }()
    
    let inSessionLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.sizeToFit()
        label.text = "Tutoring In-Person Sessions"
        
        return label
    }()
    
    override func configureView() {
        contentView.addSubview(header)
        contentView.addSubview(inSessionLabel)
        
        backgroundColor = .black
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        header.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.height.equalTo(20)
        }
        
        inSessionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom)
            make.left.equalTo(header)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
}

class BaseSlider : UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        var width : Int
        
        if (UIScreen.main.bounds.height == 568) {
            width = 230
        } else {
            width = 280
        }
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: width, height: 12)
		
        return rect
    }
}

class EditProfileSliderTableViewCell : BaseTableViewCell {
    
    let header : UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let slider : BaseSlider = {
        let slider = BaseSlider()
        
        slider.maximumTrackTintColor = Colors.registrationDark
        slider.minimumTrackTintColor = Colors.tutorBlue
        slider.isContinuous = true
        
        return slider
    }()
    
    let valueLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.textAlignment = .center
        
        return label
    }()
    
    override func configureView() {
        contentView.addSubview(header)
        contentView.addSubview(slider)
        contentView.addSubview(valueLabel)
        backgroundColor = .clear
        selectionStyle = .none
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        var width : Int
        
        if (UIScreen.main.bounds.height == 568) {
            width = 230
        } else {
            width = 290
        }
        
        header.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.height.equalTo(20)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(slider).inset(-14)
            make.left.equalTo(slider.snp.right)
            make.right.equalToSuperview()
        }
        
        slider.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(4)
            make.top.equalTo(header.snp.bottom).inset(-20)
            make.width.equalTo(width)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
    }
}

class EditProfileCheckboxTableViewCell : BaseTableViewCell {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(15)
        label.textColor = .white
        
        return label
    }()
    
	let checkbox = RegistrationCheckbox()
    
    override func configureView() {
        addSubview(label)
      	contentView.addSubview(checkbox)
        super.configureView()
        
        selectionStyle = .none
        backgroundColor = .clear
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        checkbox.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
    }

}

