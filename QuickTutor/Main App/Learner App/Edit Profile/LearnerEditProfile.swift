//
//  EditProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//


import UIKit
import SnapKit
import AAPhotoCircleCrop
import SwiftKeychainWrapper

let imagePicker = UIImagePickerController()
var imageToChange : Int = 0

class LearnerEditProfileView : MainLayoutTitleTwoButton, Keyboardable {
    
	var saveButton = NavbarButtonSave()
	var backButton = NavbarButtonBack()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonBack
		}
	}
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
        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}


class ProfilePicImageView : InteractableView, Interactable {
    
	var picView = UIImageView()
    var buttonImageView = UIImageView()
	
    override func configureView() {
        addSubview(picView)
        picView.addSubview(buttonImageView)
		picView.scaleImage()
	
        buttonImageView.scaleImage()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        picView.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalTo(self.snp.height)
            make.center.equalToSuperview()
        }
        
        buttonImageView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.width.equalToSuperview().multipliedBy(0.3)
        }
    }
}

//class EditProfileConnectInsta : InteractableView, Interactable {
//
//    var instaPic = UIImageView()
//    var infoLabel = LeftTextLabel()
//    var sideLabel = RightTextLabel()
//    var divider = UIView()
//
//    override func configureView() {
//        addSubview(instaPic)
//        addSubview(infoLabel)
//        addSubview(sideLabel)
//        addSubview(divider)
//        super.configureView()
//
//        instaPic.image = UIImage(named: "connect-insta")
//
//        infoLabel.label.font = Fonts.createSize(16)
//        infoLabel.label.text = "Connect Instagram"
//
//        sideLabel.label.font = Fonts.createBoldSize(25)
//        sideLabel.label.text = "›"
//
//        divider.backgroundColor = Colors.divider
//
//        applyConstraints()
//    }
//
//    override func applyConstraints() {
//        instaPic.snp.makeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
//
//        infoLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().inset(30)
//            make.height.equalToSuperview()
//            make.right.equalTo(sideLabel.snp.left)
//            make.centerY.equalToSuperview()
//        }
//
//        sideLabel.snp.makeConstraints { (make) in
//            make.right.equalToSuperview()
//            make.height.equalTo(20)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(15)
//        }
//
//        divider.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//        }
//    }
//
//    func touchStart() {
//        divider.backgroundColor = .white
//        divider.alpha = 1.0
//        divider.fadeIn(withDuration: 0.1, alpha: 1.0)
//    }
//
//    func didDragOff() {
//        divider.backgroundColor = Colors.divider
//    }
//}


class EditProfileMainLayout : MainLayoutTitleBackSaveButton {
    
    var titleLabel = LeftTextLabel()
    
    override func configureView() {
        addSubview(titleLabel)
        super.configureView()
        
        titleLabel.label.font = Fonts.createBoldSize(18)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(70)
        }
        
        titleLabel.label.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.25)
            make.width.equalToSuperview()
        }
    }
}


//fileprivate class EditProfileScrollView : BaseScrollView {
//
//    let current = UIApplication.getPresentedViewController()
//
//    override func handleNavigation() {
//        if (touchStartView is ProfileImage1) {
//            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
//            imageToChange = 1
//        } else if (touchStartView is ProfileImage2) {
//            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
//            imageToChange = 2
//        } else if (touchStartView is ProfileImage3) {
//            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
//            imageToChange = 3
//
//        } else if (touchStartView is ProfileImage4) {
//            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
//            imageToChange = 4
//
//        } else if (touchStartView is EditProfileConnectInsta) {
//
//        }
//    }
//}

class LearnerEditProfile : BaseViewController {
    
    override var contentView: LearnerEditProfileView {
        return view as! LearnerEditProfileView
    }
    
    override func loadView() {
        view = LearnerEditProfileView()
    }
	
	var learner : AWLearner! {
		didSet {
			contentView.tableView.reloadData()
		}
	}
	
	var delegate : LearnerWasUpdatedCallBack?
	
    var firstName : String!
    var lastName : String!
	
    var automaticScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
        configureDelegates()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		guard let learner = CurrentUser.shared.learner else { return }
		self.learner = learner
		
		let name = learner.name.split(separator: " ")
		firstName = String(name[0])
		lastName = String(name[1])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	private func displaySavedAlertController() {
		let alertController = UIAlertController(title: "Saved!", message: "Your profile changes have been saved", preferredStyle: .alert)
		
		self.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when){
			alertController.dismiss(animated: true) {
				self.delegate?.learnerWasUpdated(learner: CurrentUser.shared.learner)
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	private func configureDelegates() {
        imagePicker.delegate = self
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(ProfileImagesTableViewCell.self, forCellReuseIdentifier: "profileImagesTableViewCell")
        contentView.tableView.register(EditProfileDotItemTableViewCell.self, forCellReuseIdentifier: "editProfileDotItemTableViewCell")
        contentView.tableView.register(EditProfileHeaderTableViewCell.self, forCellReuseIdentifier: "editProfileHeaderTableViewCell")
        contentView.tableView.register(EditProfileArrowItemTableViewCell.self, forCellReuseIdentifier: "editProfileArrowItemTableViewCell")
	}
    override func handleNavigation() {
        if (touchStartView is NavbarButtonSave) {
            saveChanges()
		} else if touchStartView is NavbarButtonBack {
			delegate?.learnerWasUpdated(learner: CurrentUser.shared.learner)
		}
    }
    
    @objc private func firstNameValueChanged(_ textField : UITextField) {
        guard textField.text!.count > 0 else { return }
        firstName = textField.text
    }
    
    @objc private func lastNameValueChanged(_ textField : UITextField) {
        guard textField.text!.count > 0 else { return }
		lastName = textField.text
    }
	
    private func uploadImageUrl(imageUrl: String, number: String) {
        if !self.learner.isTutor {
			FirebaseData.manager.updateValue(node: "student-info", value: ["img" : CurrentUser.shared.learner.images]) { (error) in
				if let error = error {
					AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
				}
			}
            self.learner.images = CurrentUser.shared.learner.images
        } else {

            let newNodes = ["/student-info/\(CurrentUser.shared.learner.uid)/img/" : CurrentUser.shared.learner.images, "/tutor-info/\(CurrentUser.shared.learner.uid)/img/" : CurrentUser.shared.learner.images]

            Tutor.shared.updateSharedValues(multiWriteNode: newNodes, { (error) in
                if let error = error {
                    print(error)
                } else {
                    self.learner.images = CurrentUser.shared.learner.images
                }
            })
        }
    }
	
    private func saveChanges() {
        
        if firstName.count < 1 || lastName.count < 1 {
           AlertController.genericErrorAlert(self, title: "Invalid Name", message: "Your first and last name must contain atleast 1 character.")
            return
        }
		
		let newNodes : [String : Any]
		if CurrentUser.shared.learner.isTutor {
			newNodes = [
				"/tutor-info/\(AccountService.shared.currentUser.uid!)/nm" : firstName + " " + lastName,
				"/student-info/\(AccountService.shared.currentUser.uid!)/nm" : firstName + " " + lastName
			]
		} else {
			newNodes = ["/student-info/\(AccountService.shared.currentUser.uid!)/nm" : firstName + " " + lastName]
		}
        Tutor.shared.updateSharedValues(multiWriteNode: newNodes) { (error) in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                CurrentUser.shared.learner.name = self.firstName + " " + self.lastName
                self.displaySavedAlertController()
            }
        }
    }
}

extension LearnerEditProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
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
            return 50
        case 9:
            return 75
        case 10:
            return 75
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
            guard let firstName = firstName else { return cell }
            cell.textField.attributedText = NSAttributedString(string: "\(firstName)",
                attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell
            
            cell.textField.addTarget(self, action: #selector(lastNameValueChanged(_:)), for: .editingChanged)
            
            cell.infoLabel.label.text = "Last Name"
            guard let lastName = lastName else { return cell }
            cell.textField.attributedText = NSAttributedString(string: "\(lastName)",
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
            
            cell.label.text = "Private Information"
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Mobile Number"
            cell.textField.attributedText = NSAttributedString(string: learner.phone.formatPhoneNumber(),
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Email"
            cell.textField.attributedText = NSAttributedString(string: learner.email,
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Optional Information"
            
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "Languages I Speak"
            cell.textField.attributedText = NSAttributedString(string: "Edit",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            
            cell.infoLabel.label.text = "School"
            
            if let school = learner.school {
                cell.textField.attributedText = NSAttributedString(string: school,
                                                                   attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            } else {
                cell.textField.attributedText = NSAttributedString(string: "Enter School",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 4:
            navigationController?.pushViewController(EditBio(), animated: true)
        case 6:
            navigationController?.pushViewController(EditPhone(), animated: true)
        case 7:
            navigationController?.pushViewController(ChangeEmail(), animated: true)
        case 9:
            navigationController?.pushViewController(EditLanguage(), animated: true)
        case 10:
            navigationController?.pushViewController(EditSchool(), animated: true)
        default:
            break
            
        }
    }
}
extension LearnerEditProfile : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !automaticScroll {
            self.view.endEditing(true)
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        automaticScroll = false
    }
}
extension LearnerEditProfile : UIImagePickerControllerDelegate, UINavigationControllerDelegate, AACircleCropViewControllerDelegate {

    func circleCropDidCropImage(_ image: UIImage) {
		let cell = contentView.tableView.cellForRow(at: IndexPath(row:0, section:0)) as! ProfileImagesTableViewCell
		let imageViews = [cell.image1, cell.image2, cell.image3, cell.image4]
		
		guard let data = FirebaseData.manager.getCompressedImageDataFor(image) else {
			AlertController.genericErrorAlert(self, title: "Unable to Upload Image", message: "Your image could not be uploaded. Please try again.")
			return
		}
		
		func checkForEmptyImagesBeforeCurrentIndex() -> Int {
			for (index, imageView) in imageViews.enumerated() {
				if imageView.picView.image == nil || imageView.picView.image == #imageLiteral(resourceName: "registration-image-placeholder") {
					return index
				}
			}
			return imageToChange - 1
		}
		
		func setAndSaveImage() {
			var index = imageToChange - 1
			if imageViews[index].picView.image == #imageLiteral(resourceName: "registration-image-placeholder") {
				index = checkForEmptyImagesBeforeCurrentIndex()
			}
			FirebaseData.manager.uploadImage(data: data, number: String(index + 1)) { (error, imageUrl) in
				if let error = error {
					AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
				} else if let imageUrl = imageUrl {
					self.learner.images["image\(index+1)"] = imageUrl
					self.uploadImageUrl(imageUrl: imageUrl, number: String(index+1))
				}
			}
			imageViews[index].picView.image = image.circleMasked
			imageViews[index].buttonImageView.image = UIImage(named: "remove-image")
		}
		setAndSaveImage()
	}

    func circleCropDidCancel() {
        print("cancelled")
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
//extension LearnerEditProfile : UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        switch textField {
//        case contentView.firstNameItem.textField, contentView.lastNameItem.textField:
//            let char = string.cString(using: String.Encoding.utf8)!
//            let isBackSpace = strcmp(char, "\\b")
//
//            if isBackSpace == Constants.BCK_SPACE {
//                textField.text!.removeLast()
//            }
//            if textField.text!.count <= 24 {
//                if string.rangeOfCharacter(from: .letters) != nil { return true }
//                return false
//            } else {
//                print("Your name is too long!")
//                return false
//            }
//        case contentView.emailItem.textField:
//            let maxlength = 40
//            guard let text = textField.text else { return true }
//            let length = text.count + string.count - range.length
//
//            if length <= maxlength { return true }
//            else {
//                print("MAX LENGTH")
//                return false
//            }
//        default:
//            break
//        }
//        return false
//    }
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        resignFirstResponder()
//        textField.becomeFirstResponder()
//        switch textField {
//        case contentView.firstNameItem.textField:
//            automaticScroll = true
//            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        case contentView.lastNameItem.textField:
//            automaticScroll = true
//            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        case contentView.emailItem.textField:
//            automaticScroll = true
//            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 350), animated: true)
//        default:
//            break
//        }
//    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}

