//
//  EditProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import AAPhotoCircleCrop

class TutorEditProfileView : MainLayoutTitleBackSaveButton, Keyboardable {
    
    var editButton = NavbarButtonEdit()
    
    override var rightButton: NavbarButton {
        get {
            return saveButton
        } set {
            saveButton = newValue as! NavbarButtonSave
        }
    }
    
    var keyboardComponent = ViewComponent()
    
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
        addKeyboardView()
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "Edit Profile"
        
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

class TutorEditProfile : BaseViewController {
    
    override var contentView: TutorEditProfileView {
        return view as! TutorEditProfileView
    }
    
    let user = LearnerData.userData
    var name = [Substring]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        name = user.name.split(separator: " ")
        imagePicker.delegate = self
		
		contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
		
        contentView.tableView.register(ProfileImagesTableViewCell.self, forCellReuseIdentifier: "profileImagesTableViewCell")
        contentView.tableView.register(EditProfileDotItemTableViewCell.self, forCellReuseIdentifier: "editProfileDotItemTableViewCell")
        contentView.tableView.register(EditProfileHeaderTableViewCell.self, forCellReuseIdentifier: "editProfileHeaderTableViewCell")
        contentView.tableView.register(EditProfileArrowItemTableViewCell.self, forCellReuseIdentifier: "editProfileArrowItemTableViewCell")
        contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
        contentView.tableView.register(EditProfileCheckboxTableViewCell.self, forCellReuseIdentifier: "editProfileCheckboxTableViewCell")
    }
    override func loadView() {
        view = TutorEditProfileView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
    }
    override func handleNavigation() {
        
    }
    
    @objc
    private func rateSliderValueDidChange(_ sender: UISlider!) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 8, section: 0)) as! EditProfileSliderTableViewCell)
        
        cell.valueLabel.text = "$" + String(Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
    }
    
    @objc
    private func distanceSliderValueDidChange(_ sender: UISlider!) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 9, section: 0)) as! EditProfileSliderTableViewCell)
        let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
        
        if(value % 5 == 0) {
            cell.valueLabel.text = String(value) + " mi"
        }
    }
}

extension TutorEditProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 19
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 100
        case 1:
            return 50
        case 2:
            return 75
        case 3:
            return 75
        case 4:
            return 75
        case 5:
            return 50
        case 6:
            return 75
        case 7:
            return 75
        case 8:
            return UITableViewAutomaticDimension
        case 9:
            return UITableViewAutomaticDimension
        case 10:
            return 40
        case 11:
            return 40
        case 12:
            return 50
        case 13:
            return 75
        case 14:
            return 75
        case 15:
            return 50
        case 16:
            return 75
        case 17:
            return 75
        case 18:
            return 50
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileImagesTableViewCell", for: indexPath) as! ProfileImagesTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "About Me"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "First Name"
            cell.textField.attributedText = NSAttributedString(string: "\(name[0])",
                attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.infoLabel.label.text = "Last Name"
            cell.textField.attributedText = NSAttributedString(string: "\(name[1])",
                attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Basic Info"
            cell.textField.attributedText = NSAttributedString(string: "Edit",
                attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Tutoring"
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Subjects"
            cell.textField.attributedText = NSAttributedString(string: "Manage Subjects",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Policies"
            cell.textField.attributedText = NSAttributedString(string: "Manage Policies",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
            
            cell.slider.addTarget(self, action: #selector(rateSliderValueDidChange), for: .valueChanged)
			
            //set users current value to slider.value and valueLabel.text
            //cell.slider.value = CGFloat(user.rate)
            //cell.valueLabel.text = "$" + user.rate
            
            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 100
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Hourly Rate  ", 15, .white)
                .regular("  [$5-$100]", 15, Colors.grayText)
            
            cell.header.attributedText = formattedString
            
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
            
            cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)
            //cell.slider.value = CGFloat(user.distance)
            //cell.valueLabel.text = user.distance + " mi"
            
            cell.slider.minimumValue = 0
            cell.slider.maximumValue = 150
            
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Travel Distance  ", 15, .white)
                .regular("  [0-150 mi]", 15, Colors.grayText)
            
            cell.header.attributedText = formattedString
            
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell
            
            cell.label.text = "Tutoring In-Person Sessions?"
            
            //set if checked or not
            
            return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell
            
            cell.label.text = "Tutoring Online (Video Call) Sessions?"
            
            //set if checked or not
            
            return cell
        case 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Private Information"
            
            return cell
        case 13:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Mobile Number"
            cell.textField.attributedText = NSAttributedString(string: user.phone,
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 14:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Email"
            cell.textField.attributedText = NSAttributedString(string: user.email,
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 15:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Optional Information"
            
            return cell
        case 16:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Languages I Speak"
            cell.textField.attributedText = NSAttributedString(string: "Add",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 17:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "School"
            cell.textField.attributedText = NSAttributedString(string: "Enter School",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 18:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Connections"
            
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 4:
			navigationController?.pushViewController(EditBio(), animated: true)
		case 6:
			print("manage subjects")
		case 7:
			navigationController?.pushViewController(TutorManagePolicies(), animated: true)
		case 13:
			navigationController?.pushViewController(EditPhone(), animated: true)
		case 14:
			navigationController?.pushViewController(ChangeEmail(), animated: true)
		case 16:
			navigationController?.pushViewController(EditLanguage(), animated: true)
		case 17:
			navigationController?.pushViewController(EditSchool(), animated: true)
		default:
			break
		
		}
	}
}

extension TutorEditProfile : UIImagePickerControllerDelegate, UINavigationControllerDelegate, AACircleCropViewControllerDelegate {
	
	func circleCropDidCropImage(_ image: UIImage) {
		let cell = contentView.tableView.cellForRow(at: IndexPath(row:0, section:0)) as! ProfileImagesTableViewCell
		let imageCache = LocalImageCache.localImageManager
		//fix the animation when the cropper dismisses
		switch imageToChange {
		case 1:
			imageCache.updateImageStored(image: image, number: "1")
			cell.image1.picView.image = image
		case 2:
			imageCache.updateImageStored(image: image, number: "2")
			cell.image2.picView.image = image
		case 3:
			imageCache.updateImageStored(image: image, number: "3")
			cell.image3.picView.image = image
		case 4:
			imageCache.updateImageStored(image: image, number: "4")
			cell.image4.picView.image = image
		default:
			break
		}
	}
	
	func circleCropDidCancel() {
		print("cancelled")
	}
	
	internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			
			let circleCropController = AACircleCropViewController()
			circleCropController.image = image
			circleCropController.delegate = self
			
			self.navigationController?.pushViewController(circleCropController, animated: true)
			imagePicker.dismiss(animated: true, completion: nil)
		}
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
}
