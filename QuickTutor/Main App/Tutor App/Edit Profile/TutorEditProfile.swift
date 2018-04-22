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

protocol TutorPreferenceChange {
	func inPersonPressed()
	func inVideoPressed()
}

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
        navbar.backgroundColor = Colors.tutorBlue
        statusbarView.backgroundColor = Colors.tutorBlue
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

class TutorEditProfile : BaseViewController, TutorPreferenceChange {

    override var contentView: TutorEditProfileView {
        return view as! TutorEditProfileView
    }
    
    let tutor = TutorData.shared
	
    var name = [Substring]()
	
	var price : Int!
	var distance : Int!
	var preference : Int!
	
	var firstName : String!
	var lastName : String!
	
	var inPerson : Bool!
	var inVideo : Bool!
	
	var automaticScroll = false

	override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        configureDelegates()
		
        name = tutor.name.split(separator: " ")
		
		firstName = String(name[0])
		lastName =	String(name[1])
		
		price = tutor.price
		distance = tutor.distance
		preference = tutor.preference
		
		if preference == 3 {
			inPerson = true
			inVideo = true
		} else if preference == 2 {
			inPerson = true
			inVideo = false
		} else if preference == 1 {
			inPerson = false
			inVideo = true
		} else {
			inPerson = false
			inVideo = false
		}
    }
	
    override func loadView() {
        view = TutorEditProfileView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
    }
	func inPersonPressed() {
		print("wut.")
		self.inPerson = !self.inPerson
		print(inPerson)
	}
	
	func inVideoPressed() {
		self.inVideo = !self.inVideo
		print(inVideo)
	}

	private func configureDelegates() {
		imagePicker.delegate = self
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		contentView.tableView.register(ProfileImagesTableViewCell.self, forCellReuseIdentifier: "profileImagesTableViewCell")
		contentView.tableView.register(EditProfileDotItemTableViewCell.self, forCellReuseIdentifier: "editProfileDotItemTableViewCell")
		contentView.tableView.register(EditProfileHeaderTableViewCell.self, forCellReuseIdentifier: "editProfileHeaderTableViewCell")
		contentView.tableView.register(EditProfileArrowItemTableViewCell.self, forCellReuseIdentifier: "editProfileArrowItemTableViewCell")
		contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
		contentView.tableView.register(EditProfilePersonCheckboxTableViewCell.self, forCellReuseIdentifier: "editProfilePersonCheckboxTableViewCell")
		contentView.tableView.register(EditProfileVideoCheckboxTableViewCell.self, forCellReuseIdentifier: "editProfileVideoCheckboxTableViewCell")
		
	}
	private func saveChanges() {
		
		if firstName.count < 1 || lastName.count < 0 {
			print("invalid name!")
			return
		}
		
		if inPerson && inVideo {
			preference = 3
		} else if inPerson && !inVideo {
			preference = 2
		} else if !inPerson && inVideo {
			preference = 1
		} else {
			preference = 0
		}
		
		let sharedUpdateValues : [String : Any] = [
			
			"/tutor-info/\(AccountService.shared.currentUser.uid!)/p" : price,
			"/tutor-info/\(AccountService.shared.currentUser.uid!)/dst" : distance,
			"/tutor-info/\(AccountService.shared.currentUser.uid!)/prf" : preference,
			"/tutor-info/\(AccountService.shared.currentUser.uid!)/nm" : firstName + " " + lastName,
			"/student-info/\(AccountService.shared.currentUser.uid!)/nm" : firstName + " " + lastName

		]
		
		Tutor.shared.updateSharedValues(multiWriteNode: sharedUpdateValues) { (error) in
			if let error = error {
				print(error)
			} else {
				
				TutorData.shared.distance = self.distance
				TutorData.shared.name = self.firstName + " " + self.lastName
				TutorData.shared.price = self.price
				TutorData.shared.preference = self.preference
				
				self.displaySavedAlertController()
			}
		}
	}
	
    @objc
    private func rateSliderValueDidChange(_ sender: UISlider!) {
		
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 8, section: 0)) as! EditProfileSliderTableViewCell)
        
        cell.valueLabel.text = "$" + String(Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
		price = Int(cell.slider.value.rounded(FloatingPointRoundingRule.up))
	}
    
    @objc
    private func distanceSliderValueDidChange(_ sender: UISlider!) {
		
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 9, section: 0)) as! EditProfileSliderTableViewCell)
        let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
		
		cell.valueLabel.text = String(value) + " mi"
		distance = Int(cell.slider.value.rounded(FloatingPointRoundingRule.up))
    }
	
	@objc private func firstNameValueChanged(_ textField : UITextField) {
		
		guard textField.text!.count > 0 else { return }
		
		firstName = textField.text
	}
	
	@objc private func lastNameValueChanged(_ textField : UITextField) {
		
		guard textField.text!.count > 0 else { return }
		
		lastName = textField.text
	}
	
	private func displaySavedAlertController() {
		let alertController = UIAlertController(title: "Saved!", message: "Your profile changes have been saved", preferredStyle: .alert)
		
		self.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when){
			alertController.dismiss(animated: true){
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonSave {
			saveChanges()
		}
	}
}

extension TutorEditProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
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
//        case 18:
//            return 50
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
			
			cell.textField.addTarget(self, action: #selector(firstNameValueChanged(_:)), for: .editingChanged)
			
            cell.infoLabel.label.text = "First Name"
            cell.textField.attributedText = NSAttributedString(string: "\(name[0])",
                attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
			
			cell.textField.addTarget(self, action: #selector(lastNameValueChanged(_:)), for: .editingChanged)

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
			cell.slider.minimumValue = 5
			cell.slider.maximumValue = 100
			
			cell.slider.value = Float(tutor.price!)
			cell.valueLabel.text = "$\(tutor.price!)"

			let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Hourly Rate  ", 15, .white)
                .regular("  [$5-$100]", 15, Colors.grayText)
            
            cell.header.attributedText = formattedString
            
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
            
            cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)

            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 150
			
			cell.slider.value = Float(tutor.distance!)
			cell.valueLabel.text = "\(tutor.distance!) mi"
			
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Travel Distance  ", 15, .white)
                .regular("  [0-150 mi]", 15, Colors.grayText)
            
            cell.header.attributedText = formattedString
            
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfilePersonCheckboxTableViewCell", for: indexPath) as! EditProfilePersonCheckboxTableViewCell
            
            cell.label.text = "Tutoring In-Person Sessions?"
			cell.checkbox.isSelected = inPerson
			cell.delegate = self
			
			return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileVideoCheckboxTableViewCell", for: indexPath) as! EditProfileVideoCheckboxTableViewCell

			cell.label.text = "Tutoring Online (Video Call) Sessions?"
			cell.checkbox.isSelected = inVideo
			cell.delegate = self
			
            return cell
        case 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Private Information"
            
            return cell
        case 13:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Mobile Number"
            cell.textField.attributedText = NSAttributedString(string: tutor.phone,
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 14:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Email"
            cell.textField.attributedText = NSAttributedString(string: tutor.email,
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
            
            if let school = tutor.school {
                cell.textField.attributedText = NSAttributedString(string: school,
                                                                   attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            } else {
                cell.textField.attributedText = NSAttributedString(string: "Enter School",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            }
            
            return cell
//        case 18:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
//
//            cell.label.text = "Connections"
//
//            return cell
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
			let next = EditTutorSubjects()
			next.selectedSubjects = TutorData.shared.subjects
			next.selected = TutorData.shared.selected
			navigationController?.pushViewController(next, animated: true)
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

extension TutorEditProfile : UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
	
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		automaticScroll = false
	}
}
