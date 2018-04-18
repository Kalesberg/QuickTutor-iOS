//
//  EditProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//TODO Design:
//
//TODO Backend:
// - Connect instagram (FB makes us have to register our app)
// - Show updated bio in my profile, (after pressing back within editbio) (check)
// - (Bio) disable ability to add a new line in textview (
// - (Languages) sometimes have to tap twice to switch languages
// - (Languages) limit 10?


import UIKit
import SnapKit
import AAPhotoCircleCrop
import SwiftKeychainWrapper

let imagePicker = UIImagePickerController()
var imageToChange : Int = 0

class LearnerEditProfileView : MainLayoutTitleBackSaveButton, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    fileprivate var scrollView = EditProfileScrollView()
    
    fileprivate var imagesContainer = ProfileImagesContainer()
    
    fileprivate var aboutMeLabel = LeftTextLabel()
    fileprivate var firstNameItem = EditProfileDotItem()
    fileprivate var lastNameItem = EditProfileDotItem()
    fileprivate var bioItem = EditProfileBioItem()
    
    fileprivate var personalInfoHeader = EditProfileHeader()
    fileprivate var mobileNumberItem = EditProfilePhoneItem()
    fileprivate var emailItem = EditProfileEmailItem()
    
    fileprivate var optionalInfoHeader = EditProfileHeader()
    fileprivate var languagesItem = EditProfileLanguageItem()
    fileprivate var schoolItem = EditProfileSchoolItem()
    
    fileprivate var connectionsHeader = EditProfileHeader()
    var connectInsta = EditProfileConnectInsta()
    
    override func configureView() {
        addKeyboardView()
        addSubview(scrollView)
        scrollView.addSubview(imagesContainer)
        scrollView.addSubview(aboutMeLabel)
        scrollView.addSubview(firstNameItem)
        scrollView.addSubview(lastNameItem)
        scrollView.addSubview(bioItem)
        scrollView.addSubview(personalInfoHeader)
        scrollView.addSubview(mobileNumberItem)
        scrollView.addSubview(emailItem)
        scrollView.addSubview(optionalInfoHeader)
        scrollView.addSubview(languagesItem)
        scrollView.addSubview(schoolItem)
        scrollView.addSubview(connectionsHeader)
        scrollView.addSubview(connectInsta)
        super.configureView()
        
        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
        
        let user = LearnerData.userData
        let name = user.name.split(separator: " ")
        title.label.text = "Edit Profile"
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delaysContentTouches = false
        
        aboutMeLabel.label.text = "About Me"
        aboutMeLabel.label.font = Fonts.createSize(18)
        
        firstNameItem.infoLabel.label.text = "First Name"
        firstNameItem.textField.attributedText = NSAttributedString(string: "\(name[0])",
                                                                    attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        
        lastNameItem.infoLabel.label.text = "Last Name"
        lastNameItem.textField.attributedText = NSAttributedString(string: "\(name[1])",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        
        personalInfoHeader.label.text = "Personal Information"
        
        mobileNumberItem.textField.attributedPlaceholder = NSAttributedString(string: user.phone.formatPhoneNumber(),
                                                                              attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        
        emailItem.infoLabel.label.text = "Email"
        emailItem.textField.attributedPlaceholder = NSAttributedString(string: user.email,
                                                                       attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        
        optionalInfoHeader.label.text = "Optional Information"
        
        connectionsHeader.label.text = "Connections"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        imagesContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.13)
        }
        
        aboutMeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imagesContainer.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.1)
        }
        
        firstNameItem.snp.makeConstraints { (make) in
            make.top.equalTo(aboutMeLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        lastNameItem.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        bioItem.snp.makeConstraints { (make) in
            make.top.equalTo(lastNameItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        personalInfoHeader.snp.makeConstraints { (make) in
            make.top.equalTo(bioItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.1)
        }
        
        mobileNumberItem.snp.makeConstraints { (make) in
            make.top.equalTo(personalInfoHeader.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        emailItem.snp.makeConstraints { (make) in
            make.top.equalTo(mobileNumberItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        optionalInfoHeader.snp.makeConstraints { (make) in
            make.top.equalTo(emailItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.1)
        }
        
        languagesItem.snp.makeConstraints { (make) in
            make.top.equalTo(optionalInfoHeader.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        schoolItem.snp.makeConstraints { (make) in
            make.top.equalTo(languagesItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        connectionsHeader.snp.makeConstraints { (make) in
            make.top.equalTo(schoolItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.1)
        }
        
        connectInsta.snp.makeConstraints { (make) in
            make.top.equalTo(connectionsHeader.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
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
        
        buttonImageView.image = UIImage(named: "add-image-profile")
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

class ProfileImage1 : ProfilePicImageView {
    override func configureView() {
        super.configureView()
        picView.image = LocalImageCache.localImageManager.image1
    }
}

class ProfileImage2 : ProfilePicImageView {
    
    var number : String = "2"
    let current = UIApplication.getPresentedViewController()
    
    override func configureView() {
        super.configureView()
        picView.image = LocalImageCache.localImageManager.image2
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressRecognizer.minimumPressDuration = 0.7
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            AlertController.removeImageAlert(current!, number) { () in
                self.picView.image = LocalImageCache.localImageManager.image2
            }
        }
    }
}

class ProfileImage3 : ProfilePicImageView {
    
    var number : String = "3"
    let current = UIApplication.getPresentedViewController()
    
    override func configureView() {
        super.configureView()
        picView.image = LocalImageCache.localImageManager.image3
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressRecognizer.minimumPressDuration = 0.7
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            AlertController.removeImageAlert(current!, number) { () in
                self.picView.image = LocalImageCache.localImageManager.image3
            }
        }
    }
}

class ProfileImage4 : ProfilePicImageView {
    
    var number : String = "4"
    let current = UIApplication.getPresentedViewController()
    
    override func configureView() {
        super.configureView()
        
        picView.image = LocalImageCache.localImageManager.image4
    
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressRecognizer.minimumPressDuration = 0.7
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            AlertController.removeImageAlert(current!, number) { () in
                self.picView.image = LocalImageCache.localImageManager.image4
            }
        }
    }
}


fileprivate class ProfileImagesContainer : InteractableView {
    
    var image1 = ProfileImage1()
    var image2 = ProfileImage2()
    var image3 = ProfileImage3()
    var image4 = ProfileImage4()
    
    override func configureView() {
        addSubview(image1)
        addSubview(image2)
        addSubview(image3)
        addSubview(image4)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        image1.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.75)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        image2.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.75)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.left.equalTo(image1.snp.right)
            make.bottom.equalToSuperview()
        }
        
        image3.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.75)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.left.equalTo(image2.snp.right)
            make.bottom.equalToSuperview()
        }
        
        image4.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.75)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}


fileprivate class EditProfileItem : InteractableView {
    
    var infoLabel = LeftTextLabel()
    var textField = NoPasteTextField()
    var sideLabel = RightTextLabel()
    var divider   = BaseView()
    var spacer    = BaseView()
    
    override func configureView() {
        addSubview(infoLabel)
        addSubview(textField)
        textField.addSubview(sideLabel)
        addSubview(divider)
        addSubview(spacer)
        super.configureView()
        
        divider.backgroundColor = Colors.divider
        
        infoLabel.label.font = Fonts.createBoldSize(16)
        
        textField.font = Fonts.createSize(18)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        spacer.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        divider.snp.makeConstraints { (make) in
            make.top.equalTo(spacer.snp.top)
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        textField.snp.makeConstraints { (make) in
            make.bottom.equalTo(divider.snp.top)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        sideLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(15)
        }
    }
}

fileprivate class EditProfileHeader : BaseView {
    
    var label = UILabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        label.textColor = .white
        label.font = Fonts.createSize(18)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.1)
            make.width.equalToSuperview()
        }
    }
}

fileprivate class EditProfileArrowItem : EditProfileItem, Interactable {
    
    var slider = BaseView()
    
    override func configureView() {
        addSubview(slider)
        super.configureView()
        
        textField.isUserInteractionEnabled = false
        sideLabel.label.font = Fonts.createBoldSize(25)
        sideLabel.label.text = "›"
        
        slider.backgroundColor = .white
        slider.isHidden = true
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        slider.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.75)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(textField.snp.bottom)
        }
    }
    
    func touchStart() {
        divider.alpha = 0.2
        divider.backgroundColor = .white
        divider.fadeIn(withDuration: 0.1, alpha: 1.0)
    }
    
    func didDragOff() {
        divider.backgroundColor = Colors.divider
    }
    
    func touchEndOnStart() { }
}

fileprivate class EditProfileEmailItem : EditProfileArrowItem {
    
    override func configureView() {
        super.configureView()
        infoLabel.label.text = "Email"
    }
    
    override func touchEndOnStart() {
        didDragOff()
        navigationController.pushViewController(ChangeEmail(), animated: true)
    }
}

fileprivate class EditProfilePhoneItem : EditProfileArrowItem {
    
    override func configureView() {
        super.configureView()
        
        infoLabel.label.text = "Mobile Number"
    }
    
    override func touchEndOnStart() {
        didDragOff()
        navigationController.pushViewController(EditPhone(), animated: true)
    }
}

fileprivate class EditProfileBioItem : EditProfileArrowItem {
    
    override func configureView() {
        super.configureView()
        infoLabel.label.text = "Basic Info"
        textField.attributedPlaceholder = NSAttributedString(string: "Edit",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
    }
    
    override func touchEndOnStart() {
        didDragOff()
        navigationController.pushViewController(EditBio(), animated: true)
    }
}

fileprivate class EditProfileLanguageItem : EditProfileArrowItem {
    
    override func configureView() {
        super.configureView()
        infoLabel.label.text = "Languages I Speak"
        textField.attributedPlaceholder = NSAttributedString(string: "Add",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
    }
    
    override func touchEndOnStart() {
        didDragOff()
        navigationController.pushViewController(EditLanguage(), animated: true)
    }
}

fileprivate class EditProfileSchoolItem : EditProfileArrowItem {
    
    override func configureView() {
        super.configureView()
        infoLabel.label.text = "School"
        textField.attributedPlaceholder = NSAttributedString(string: "Add",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
    }
    override func touchEndOnStart() {
        didDragOff()
        navigationController.pushViewController(EditSchool(), animated: true)
    }
}

fileprivate class EditProfileCourseCodeItem : EditProfileArrowItem {
    
    override func configureView() {
        super.configureView()
        infoLabel.label.text = "Courses"
        textField.attributedPlaceholder = NSAttributedString(string: "Add Course Codes",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
    }
    override func touchEndOnStart() {
        didDragOff()
        navigationController.pushViewController(EditCourses(), animated: true)
    }
}

class EditProfileConnectInsta : InteractableView, Interactable {
    
    var instaPic = UIImageView()
    var infoLabel = LeftTextLabel()
    var sideLabel = RightTextLabel()
    var divider = UIView()
    
    override func configureView() {
        addSubview(instaPic)
        addSubview(infoLabel)
        addSubview(sideLabel)
        addSubview(divider)
        super.configureView()
        
        instaPic.image = UIImage(named: "connect-insta")
        
        infoLabel.label.font = Fonts.createSize(16)
        infoLabel.label.text = "Connect Instagram"
        
        sideLabel.label.font = Fonts.createBoldSize(25)
        sideLabel.label.text = "›"
        
        divider.backgroundColor = Colors.divider
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        instaPic.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(30)
            make.height.equalToSuperview()
            make.right.equalTo(sideLabel.snp.left)
            make.centerY.equalToSuperview()
        }
        
        sideLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(15)
        }
        
        divider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func touchStart() {
        divider.backgroundColor = .white
        divider.alpha = 1.0
        divider.fadeIn(withDuration: 0.1, alpha: 1.0)
    }
    
    func didDragOff() {
        divider.backgroundColor = Colors.divider
    }
}

fileprivate class EditProfileDotItem : EditProfileItem {
    
    override func configureView() {
        super.configureView()
        
        sideLabel.label.font = Fonts.createSize(16)
        textField.textColor = Colors.grayText
        sideLabel.label.text = "•"
    }
}


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


fileprivate class EditProfileScrollView : BaseScrollView {
    
    let current = UIApplication.getPresentedViewController()
    
    override func handleNavigation() {
        if (touchStartView is ProfileImage1) {
            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
            imageToChange = 1
        } else if (touchStartView is ProfileImage2) {
            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
            imageToChange = 2
        } else if (touchStartView is ProfileImage3) {
            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
            imageToChange = 3
            
        } else if (touchStartView is ProfileImage4) {
            AlertController.cropImageAlert(current!, imagePicker: imagePicker)
            imageToChange = 4
            
        } else if (touchStartView is EditProfileConnectInsta) {
            
        }
    }
}

class LearnerEditProfile : BaseViewController {
    
    override var contentView: LearnerEditProfileView {
        return view as! LearnerEditProfileView
    }
    
    override func loadView() {
        view = LearnerEditProfileView()
    }
    
    var automaticScroll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
        imagePicker.delegate = self
        contentView.firstNameItem.textField.delegate = self
        contentView.lastNameItem.textField.delegate = self
        contentView.emailItem.textField.delegate = self
        contentView.scrollView.delegate = self
        
        definesPresentationContext = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentView.schoolItem.textField.attributedPlaceholder = NSAttributedString(string: getSchool(), attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        
        contentView.emailItem.textField.attributedPlaceholder = NSAttributedString(string: LearnerData.userData.email!, attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        
        contentView.mobileNumberItem.textField.attributedPlaceholder = NSAttributedString(string: LearnerData.userData.phone.formatPhoneNumber(), attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func handleNavigation() {
        if (touchStartView is NavbarButtonSave) {
            saveButtonPressed()
        }
        if (touchStartView == contentView.emailItem.textField) {
            self.navigationController?.pushViewController(ChangeEmail(), animated: true)
        }
    }
    
    private func getSchool() -> String {
        let school = LearnerData.userData.school
        if school != "" {
            return school!
        }
        return "Add"
    }
    
    private func saveButtonPressed() {
        let user = LearnerData.userData
        guard
            let firstName = contentView.firstNameItem.textField.text, firstName.count > 1,
            let lastName = contentView.lastNameItem.textField.text, lastName.count > 1 else {
                print("name error")
                return
        }
        guard let email = contentView.emailItem.textField.text, email.emailRegex() else {
            print("email error")
            return
        }
        
        user.name = "\(firstName.filter{ !" \n\t\r".contains($0)}) \(lastName.filter{ !" \n\t\r".contains($0) })"
        
        FirebaseData.manager.updateValue(node: "student-info", value: ["nm" : user.name])
        
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
        
        let imageCache = LocalImageCache.localImageManager
        //fix the animation when the cropper dismisses
        switch imageToChange {
        case 1:
            imageCache.updateImageStored(image: image, number: "1")
            contentView.imagesContainer.image1.picView.image = image
        case 2:
            imageCache.updateImageStored(image: image, number: "2")
            contentView.imagesContainer.image2.picView.image = image
        case 3:
            imageCache.updateImageStored(image: image, number: "3")
            contentView.imagesContainer.image3.picView.image = image
        case 4:
            imageCache.updateImageStored(image: image, number: "4")
            contentView.imagesContainer.image4.picView.image = image
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
extension LearnerEditProfile : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case contentView.firstNameItem.textField, contentView.lastNameItem.textField:
            let char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            
            if isBackSpace == Constants.BCK_SPACE {
                textField.text!.removeLast()
            }
            if textField.text!.count <= 24 {
                if string.rangeOfCharacter(from: .letters) != nil { return true }
                return false
            } else {
                print("Your name is too long!")
                return false
            }
        case contentView.emailItem.textField:
            let maxlength = 40
            guard let text = textField.text else { return true }
            let length = text.count + string.count - range.length
            
            if length <= maxlength { return true }
            else {
                print("MAX LENGTH")
                return false
            }
        default:
            break
        }
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resignFirstResponder()
        textField.becomeFirstResponder()
        switch textField {
        case contentView.firstNameItem.textField:
            automaticScroll = true
            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case contentView.lastNameItem.textField:
            automaticScroll = true
            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case contentView.emailItem.textField:
            automaticScroll = true
            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 350), animated: true)
        default:
            break
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

