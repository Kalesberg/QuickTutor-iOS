//
//  EditProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI
import Foundation
import SDWebImage
import UIKit

protocol TutorPreferenceChange {
    func inPersonPressed()
    func inVideoPressed()
}

class TutorEditProfileView: MainLayoutTitleTwoButton, Keyboardable {
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

    let tableView: UITableView = {
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

        tableView.snp.makeConstraints { make in
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

class TutorEditProfile: BaseViewController, TutorPreferenceChange {
    let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    override var contentView: TutorEditProfileView {
        return view as! TutorEditProfileView
    }

    var tutor: AWTutor! {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var price: Int!
    var distance: Int!
    var preference: Int!

    var firstName: String!
    var lastName: String!

    var inPerson: Bool!
    var inVideo: Bool!

    var automaticScroll = false

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        configureDelegates()
    }

    override func loadView() {
        view = TutorEditProfileView()
    }

    var delegate: UpdatedTutorCallBack?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let tutor = CurrentUser.shared.tutor else { return }
        self.tutor = tutor

        let name = tutor.name.split(separator: " ")
        firstName = String(name[0])
        lastName = String(name[1])

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func inPersonPressed() {
        inPerson = !inPerson
    }

    func inVideoPressed() {
        inVideo = !inVideo
    }

    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
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
        contentView.tableView.register(EditProfileArrowItemTableViewCell.self, forCellReuseIdentifier: "editProfileHourlyRateTableViewCell")
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

        let sharedUpdateValues: [String: Any] = [
            "/tutor-info/\(CurrentUser.shared.learner.uid!)/p": price,
            "/tutor-info/\(CurrentUser.shared.learner.uid!)/dst": distance,
            "/tutor-info/\(CurrentUser.shared.learner.uid!)/prf": preference,
            "/tutor-info/\(CurrentUser.shared.learner.uid!)/nm": firstName + " " + lastName,
            "/student-info/\(CurrentUser.shared.learner.uid!)/nm": firstName + " " + lastName,
        ]

        Tutor.shared.updateSharedValues(multiWriteNode: sharedUpdateValues) { error in
            if let error = error {
                print(error)
            } else {
                CurrentUser.shared.tutor.distance = self.distance
                CurrentUser.shared.tutor.name = self.firstName + " " + self.lastName
                CurrentUser.shared.tutor.price = self.price
                CurrentUser.shared.tutor.preference = self.preference

                self.delegate?.tutorWasUpdated(tutor: CurrentUser.shared.tutor)
                self.displaySavedAlertController()
            }
        }
    }

    @objc
    private func distanceSliderValueDidChange(_: UISlider!) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 9, section: 0)) as! EditProfileSliderTableViewCell)
        let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
        cell.valueLabel.text = String(value) + " mi"
        distance = Int(cell.slider.value.rounded(FloatingPointRoundingRule.up))
    }

    @objc private func firstNameValueChanged(_ textField: UITextField) {
        guard textField.text!.count > 0 else { return }
        firstName = textField.text
    }

    @objc private func lastNameValueChanged(_ textField: UITextField) {
        guard textField.text!.count > 0 else { return }
        lastName = textField.text
    }

    private func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your profile changes have been saved", preferredStyle: .alert)

        present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.delegate?.tutorWasUpdated(tutor: CurrentUser.shared.tutor)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func uploadImageUrl(imageUrl _: String, number _: String) {
        let newNodes = ["/student-info/\(CurrentUser.shared.learner.uid!)/img/": CurrentUser.shared.tutor.images, "/tutor-info/\(CurrentUser.shared.learner.uid!)/img/": CurrentUser.shared.tutor.images]
        Tutor.shared.updateSharedValues(multiWriteNode: newNodes, { error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                CurrentUser.shared.learner.images = CurrentUser.shared.tutor.images
            }
        })
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonSave {
            saveChanges()
        } else if touchStartView is NavbarButtonBack {
            delegate?.tutorWasUpdated(tutor: tutor)
        }
    }
}

extension TutorEditProfile: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 16
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 100
        case 1:
            return 50
        case 5, 9, 13:
            return 65
        case 2, 3, 4, 6, 7, 10, 11, 12, 14, 15:
            return 75
        case 8:
            return UITableView.automaticDimension
        default:
            break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileImagesTableViewCell", for: indexPath) as! ProfileImagesTableViewCell

            let image1Ref = storageRef.child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic1")
            cell.image1.picView.sd_setImage(with: image1Ref, placeholderImage: #imageLiteral(resourceName: "placeholder-square")) { _, _, _, _ in
                cell.image1.buttonImageView.image = (cell.image1.picView.image != #imageLiteral(resourceName: "placeholder-square")) ? UIImage(named: "remove-image") : UIImage(named: "add-image-profile")
            }
            let image2Ref = storageRef.child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic2")
            cell.image2.picView.sd_setImage(with: image2Ref, placeholderImage: #imageLiteral(resourceName: "placeholder-square")) { _, _, _, _ in
                cell.image2.buttonImageView.image = (cell.image2.picView.image != #imageLiteral(resourceName: "placeholder-square")) ? UIImage(named: "remove-image") : UIImage(named: "add-image-profile")
            }
            let image3Ref = storageRef.child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic3")
            cell.image3.picView.sd_setImage(with: image3Ref, placeholderImage: #imageLiteral(resourceName: "placeholder-square")) { _, _, _, _ in
                cell.image3.buttonImageView.image = (cell.image3.picView.image != #imageLiteral(resourceName: "placeholder-square")) ? UIImage(named: "remove-image") : UIImage(named: "add-image-profile")
            }
            let image4Ref = storageRef.child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic4")
            cell.image4.picView.sd_setImage(with: image4Ref, placeholderImage: #imageLiteral(resourceName: "placeholder-square")) { _, _, _, _ in
                cell.image4.buttonImageView.image = (cell.image4.picView.image != #imageLiteral(resourceName: "placeholder-square")) ? UIImage(named: "remove-image") : UIImage(named: "add-image-profile")
            }
            cell.layoutSubviews()

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
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDotItemTableViewCell", for: indexPath) as! EditProfileDotItemTableViewCell

            cell.textField.addTarget(self, action: #selector(lastNameValueChanged(_:)), for: .editingChanged)

            cell.infoLabel.label.text = "Last Name"
            guard let lastName = lastName else { return cell }
            cell.textField.attributedText = NSAttributedString(string: "\(lastName)",
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell

            cell.infoLabel.label.text = "Biography"
            cell.textField.attributedText = NSAttributedString(string: "Edit",
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell

            cell.label.text = "Tutoring"

            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell

            cell.infoLabel.label.text = "Subjects"
            cell.textField.attributedText = NSAttributedString(string: "Manage Subjects",
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell

            cell.infoLabel.label.text = "Policies"
            cell.textField.attributedText = NSAttributedString(string: "Manage Policies",
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHourlyRateTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
            cell.infoLabel.label.text = "Preferences"
            cell.textField.attributedText = NSAttributedString(string: "Manage Preferences",
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell

            cell.label.text = "Private Information"

            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell

            cell.infoLabel.label.text = "Mobile Number"
            cell.textField.attributedText = NSAttributedString(string: tutor.phone.formatPhoneNumber(),
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
		case 11:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell
			
			cell.infoLabel.label.text = "Birthdate"
			cell.textField.attributedText = NSAttributedString(string: tutor.birthday, attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
			
			return cell
        case 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell

            cell.infoLabel.label.text = "Email"
            cell.textField.attributedText = NSAttributedString(string: tutor.email,
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 13:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell

            cell.label.text = "Optional Information"

            return cell
        case 14:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell

            cell.infoLabel.label.text = "Languages I Speak"
            cell.textField.attributedText = NSAttributedString(string: "Edit",
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])

            return cell
        case 15:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileArrowItemTableViewCell", for: indexPath) as! EditProfileArrowItemTableViewCell

            cell.infoLabel.label.text = "School"

            if tutor.school != "" && tutor.school != nil {
                cell.textField.attributedText = NSAttributedString(string: tutor.school!,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
            } else {
                cell.textField.attributedText = NSAttributedString(string: "Enter a School",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
            }

            return cell
        default:
            break
        }

        return UITableViewCell()
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 4:
            let next = EditBioVC()
            let attributedString = NSMutableAttributedString(string: "·  What experience and expertise do you have?\n·  Any certifications or awards earned?\n·  What are you looking for in learners?")

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

            next.contentView.infoLabel.label.attributedText = attributedString
            next.contentView.infoLabel.label.font = Fonts.createSize(14)
            navigationController?.pushViewController(next, animated: true)
        case 6:
            let next = EditTutorSubjects()
            next.selectedSubjects = tutor.subjects!
            next.selected = tutor.selected
            next.tutor = tutor
            navigationController?.pushViewController(next, animated: true)
        case 7:
            let next = TutorManagePolicies()
            next.tutor = tutor
            navigationController?.pushViewController(next, animated: true)
        case 8:
            let next = TutorManagePreferences()
            next.tutor = tutor
            navigationController?.pushViewController(next, animated: true)
        // case 9:
        case 10:
            navigationController?.pushViewController(EditPhoneVC(), animated: true)
		case 11:
			navigationController?.pushViewController(EditBirthdateVC(), animated: true)
        case 12:
            navigationController?.pushViewController(ChangeEmailVC(), animated: true)
        // case 12: optional information
        case 14:
            navigationController?.pushViewController(EditLanguageVC(), animated: true)
        case 15:
            navigationController?.pushViewController(EditSchoolVC(), animated: true)
        default:
            break
        }
    }
}

extension TutorEditProfile: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AACircleCropViewControllerDelegate {
    func circleCropDidCropImage(_ image: UIImage) {
        let cell = contentView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProfileImagesTableViewCell
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
            FirebaseData.manager.uploadImage(data: data, number: String(index + 1)) { error, imageUrl in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                } else if let imageUrl = imageUrl {
                    self.tutor.images["image\(index + 1)"] = imageUrl
                    self.uploadImageUrl(imageUrl: imageUrl, number: String(index + 1))
                }
            }
            SDImageCache.shared().removeImage(forKey: getKeyForCachedImage(number: String(index + 1)), fromDisk: false) {
                SDImageCache.shared().store(image, forKey: self.getKeyForCachedImage(number: String(index + 1)), toDisk: false) {
                    imageViews[index].picView.image = image
                    imageViews[index].buttonImageView.image = UIImage(named: "remove-image")
                }
            }
        }
        setAndSaveImage()
    }

    func circleCropDidCancel() {
        print("cancelled")
    }

    func getKeyForCachedImage(number: String) -> String {
        return storageRef.child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic" + number).fullPath
    }

    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            let circleCropController = AACircleCropViewController()
            circleCropController.image = image
            circleCropController.delegate = self

            navigationController?.pushViewController(circleCropController, animated: true)
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension TutorEditProfile: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
