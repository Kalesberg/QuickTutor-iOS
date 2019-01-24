//
//  EditProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import SDWebImage
import SnapKit
import SwiftKeychainWrapper


class EditPreferencesVC: TutorPreferencesVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Manage Preferences"
        contentView.accessoryView.removeFromSuperview()
        progressView.removeFromSuperview()
        contentView.hourSliderView.slider.value = Float(CurrentUser.shared.tutor.price!)
        contentView.distanceSliderView.slider.value = Float(CurrentUser.shared.tutor.distance!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(savePreferences))
    }
    
}

class TutorEditProfileVC: LearnerEditProfileVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionTitles.insert("Tutoring", at: 2)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 3
        case 3:
            return 3
        case 4:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 105
        case 1:
            return indexPath.row == 2 ? 110 : 75
        default:
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileImagesCell", for: indexPath) as! EditProfileImagesCell
            cell.delegate = self
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                
                cell.textField.textField.addTarget(self, action: #selector(firstNameValueChanged(_:)), for: .editingChanged)
                
                cell.textField.placeholder.text = "First Name"
                guard let firstName = firstName else { return cell }
                cell.textField.textField.attributedText = NSAttributedString(string: "\(firstName)", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                
                cell.textField.textField.addTarget(self, action: #selector(lastNameValueChanged(_:)), for: .editingChanged)
                
                cell.textField.placeholder.text = "Last Name"
                guard let lastName = lastName else { return cell }
                cell.textField.textField.attributedText = NSAttributedString(string: "\(lastName)", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileBioCell", for: indexPath) as! EditProfileBioCell
                cell.placeholder.text = "Biography"
                if CurrentUser.shared.learner.bio != "" {
                    cell.textView.text = CurrentUser.shared.learner.bio
                    cell.textView.placeholderLabel.text = nil
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
            cell.textField.isUserInteractionEnabled = false
            switch indexPath.row {
            case 0:
                cell.textField.placeholder.text = "Subjects"
                cell.textField.textField.attributedText = NSAttributedString(string: "Manage Subjects", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
            case 1:
                cell.textField.placeholder.text = "Policies"
                cell.textField.textField.attributedText = NSAttributedString(string: "Manage Policies", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
            case 2:
                cell.textField.placeholder.text = "Preferences"
                cell.textField.textField.attributedText = NSAttributedString(string: "Manage Preferences", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
            default:
                break
            }
            return cell
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "Mobile Number"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: learner.phone.formatPhoneNumber(), attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "Birthdate"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: learner.birthday.toBirthdatePrettyFormat(), attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                
                cell.textField.placeholder.text = "Email"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: learner.email, attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            default:
                return UITableViewCell()
            }
        case 4:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "Languages I Speak"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: "Edit", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "School"
                cell.textField.isUserInteractionEnabled = false
                if learner.school != "" && learner.school != nil {
                    cell.textField.textField.attributedText = NSAttributedString(string: learner.school!, attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                } else {
                    cell.textField.textField.attributedText = NSAttributedString(string: "Enter a School", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                }
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            switch indexPath.item {
            case 0:
                navigationController?.pushViewController(TutorAddSubjectsVC(), animated: true)
            case 1:
                navigationController?.pushViewController(TutorManagePolicies(), animated: true)
            case 2:
                navigationController?.pushViewController(EditPreferencesVC(), animated: true)
            default:
                break
            }
        case 3:
            switch indexPath.item {
            case 0:
                navigationController?.pushViewController(EditPhoneVC(), animated: true)
            case 1:
                navigationController?.pushViewController(EditBirthdateVC(), animated: true)
            case 2:
                navigationController?.pushViewController(ChangeEmailVC(), animated: true)
            default:
                break
            }
        case 4:
            switch indexPath.item {
            case 0:
                navigationController?.pushViewController(EditLanguageVC(), animated: true)
            case 1:
                navigationController?.pushViewController(EditSchoolVC(), animated: true)
            default:
                break
            }
        default:
            break
        }
    }
}


class LearnerEditProfileVC: UIViewController {
    
    var sectionTitles = ["About me", "Private information", "Optional information"]
    var delegate: LearnerWasUpdatedCallBack?
    var firstName: String!
    var lastName: String!
    var automaticScroll = false
    let imagePicker = UIImagePickerController()
    var imageToChange: Int = 0

    let contentView: LearnerEditProfileVCView = {
        let view = LearnerEditProfileVCView()
        return view
    }()

    var learner: AWLearner! {
        didSet {
            contentView.tableView.reloadData()
        }
    }
    
    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureDelegates()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        definesPresentationContext = true
        navigationItem.title = "Edit"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(saveChanges))
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"newBackButton"), style: .plain, target: self, action: #selector(onBack))
    }
    
    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLearner()
        setupName()
    }
    
    func updateLearner() {
        guard let learner = CurrentUser.shared.learner else { return }
        self.learner = learner
    }
    
    func setupName() {
        let name = learner.name.split(separator: " ")
        firstName = String(name[0])
        lastName = String(name[1])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.learnerWasUpdated(learner: CurrentUser.shared.learner)
    }

     func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your profile changes have been saved", preferredStyle: .alert)
        
        present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            alertController.dismiss(animated: true) {
                self.delegate?.learnerWasUpdated(learner: CurrentUser.shared.learner)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func configureDelegates() {
        imagePicker.delegate = self
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }

    @objc func firstNameValueChanged(_ textField: UITextField) {
        guard textField.text!.count > 0 else { return }
        firstName = textField.text
    }

    @objc func lastNameValueChanged(_ textField: UITextField) {
        guard textField.text!.count > 0 else { return }
        lastName = textField.text
    }

     func uploadImageUrl(imageUrl _: String, number _: String) {
        if !learner.isTutor {
            FirebaseData.manager.updateValue(node: "student-info", value: ["img": CurrentUser.shared.learner.images]) { error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                }
            }
            learner.images = CurrentUser.shared.learner.images
        } else {
            let newNodes = ["/student-info/\(CurrentUser.shared.learner.uid!)/img/": CurrentUser.shared.learner.images, "/tutor-info/\(CurrentUser.shared.learner.uid!)/img/": CurrentUser.shared.learner.images]

            Tutor.shared.updateSharedValues(multiWriteNode: newNodes, { error in
                if let error = error {
                    print(error)
                } else {
                    self.learner.images = CurrentUser.shared.learner.images
                }
            })
        }
    }

    @objc  func saveChanges() {
        if firstName.count < 1 || lastName.count < 1 {
            AlertController.genericErrorAlert(self, title: "Invalid Name", message: "Your first and last name must contain at least 1 character.")
            return
        }

        let newNodes: [String: Any]
        if CurrentUser.shared.learner.isTutor {
            newNodes = [
                "/tutor-info/\(CurrentUser.shared.learner.uid!)/nm": firstName + " " + lastName,
                "/student-info/\(CurrentUser.shared.learner.uid!)/nm": firstName + " " + lastName,
            ]
        } else {
            newNodes = ["/student-info/\(CurrentUser.shared.learner.uid!)/nm": firstName + " " + lastName]
        }
        Tutor.shared.updateSharedValues(multiWriteNode: newNodes) { error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                CurrentUser.shared.learner.name = self.firstName + " " + self.lastName
                self.displaySavedAlertController()
            }
        }
        saveBio()
    }
    
    func saveBio() {
        let cell = contentView.tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as! EditProfileBioCell
        guard let newBio = cell.textView.text else { return }
        switch AccountService.shared.currentUserType {
        case .learner:
            FirebaseData.manager.updateValue(node: "student-info", value: ["bio": newBio]) { error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                }
            }
            CurrentUser.shared.learner.bio = newBio
            displaySavedAlertController()
        case .tutor:
            Tutor.shared.updateValue(value: ["tbio": newBio])
            CurrentUser.shared.tutor.tBio = newBio
            displaySavedAlertController()
        default:
            break
        }
    }
}

extension LearnerEditProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 3
        case 3:
            return 2
        default:
            return 0
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 105
        case 1:
            return indexPath.row == 2 ? 110 : 75
        case 2:
            return 75
        case 3:
            return 75
        default:
            return 75
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileImagesCell", for: indexPath) as! EditProfileImagesCell
            cell.delegate = self
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                
                cell.textField.textField.addTarget(self, action: #selector(firstNameValueChanged(_:)), for: .editingChanged)
                
                cell.textField.placeholder.text = "First Name"
                guard let firstName = firstName else { return cell }
                cell.textField.textField.attributedText = NSAttributedString(string: "\(firstName)", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                
                cell.textField.textField.addTarget(self, action: #selector(lastNameValueChanged(_:)), for: .editingChanged)
                
                cell.textField.placeholder.text = "Last Name"
                guard let lastName = lastName else { return cell }
                cell.textField.textField.attributedText = NSAttributedString(string: "\(lastName)", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileBioCell", for: indexPath) as! EditProfileBioCell
                cell.placeholder.text = "Biography"
                if CurrentUser.shared.learner.bio != "" {
                    cell.textView.text = CurrentUser.shared.learner.bio
                    cell.textView.placeholderLabel.text = nil
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "Mobile Number"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: learner.phone.formatPhoneNumber(), attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "Birthdate"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: learner.birthday.toBirthdatePrettyFormat(), attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                
                cell.textField.placeholder.text = "Email"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: learner.email, attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "Languages I Speak"
                cell.textField.isUserInteractionEnabled = false
                cell.textField.textField.attributedText = NSAttributedString(string: "Edit", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileCell
                cell.textField.placeholder.text = "School"
                cell.textField.isUserInteractionEnabled = false
                if learner.school != "" && learner.school != nil {
                    cell.textField.textField.attributedText = NSAttributedString(string: learner.school!, attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                } else {
                    cell.textField.textField.attributedText = NSAttributedString(string: "Enter a School", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
                }
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            switch indexPath.item {
            case 0:
                navigationController?.pushViewController(EditPhoneVC(), animated: true)
            case 1:
                navigationController?.pushViewController(EditBirthdateVC(), animated: true)
            case 2:
                navigationController?.pushViewController(ChangeEmailVC(), animated: true)
            default:
                break
            }
        case 3:
            switch indexPath.item {
            case 0:
                navigationController?.pushViewController(EditLanguageVC(), animated: true)
            case 1:
                navigationController?.pushViewController(EditSchoolVC(), animated: true)
            default:
                break
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = EditProfileHeaderTableViewCell()
        view.label.text = sectionTitles[section - 1]
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
}

extension LearnerEditProfileVC: EditProfileImagesCellDelegate {
    func editProfileImageCell(_ imagesCell: EditProfileImagesCell, didSelect index: Int) {
        let cell = imagesCell.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! EditProfileImageCell
        imageToChange = index + 1
        if index > 0 && cell.backgrounImageView.image != UIImage(named: "addPhotoButtonBackground") {
            AlertController.cropImageWithRemoveAlert(self, imagePicker: imagePicker) { (removed) in
                if removed {
                    cell.backgrounImageView.image = UIImage(named: "addPhotoButtonBackground")
                    cell.foregroundImageView.image = nil
                    FirebaseData.manager.removeUserImage("\(index + 1)")
                }
            }
        } else {
            AlertController.cropImageAlert(self, imagePicker: imagePicker, allowsEditing: false)
        }
    }

}

extension LearnerEditProfileVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }

    func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        automaticScroll = false
    }
}

extension LearnerEditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AACircleCropViewControllerDelegate {
    func circleCropDidCropImage(_ image: UIImage) {
        let cell = contentView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileImagesCell
        let visibleCells = cell.collectionView.visibleCells as? [EditProfileImageCell]
        var imageViews = [EditProfileImageCell]()
        visibleCells?.forEach({imageViews.append($0)})

        guard let data = FirebaseData.manager.getCompressedImageDataFor(image) else {
            AlertController.genericErrorAlert(self, title: "Unable to Upload Image", message: "Your image could not be uploaded. Please try again.")
            return
        }
        
        func getFirstEmptyImageIndex() -> Int? {
            return imageViews.firstIndex(where: { (cell) -> Bool in
                return cell.backgrounImageView.image == nil || cell.backgrounImageView.image == UIImage(named: "addPhotoButtonBackground")
            })
        }

        let index = imageToChange

        FirebaseData.manager.uploadImage(data: data, number: String(index)) { error, imageUrl in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let imageUrl = imageUrl {
                self.learner.images["image\(index)"] = imageUrl
                self.uploadImageUrl(imageUrl: imageUrl, number: String(index))
            }
        }

        SDImageCache.shared().removeImage(forKey: getKeyForCachedImage(number: String(index)), fromDisk: false) {
            SDImageCache.shared().store(image, forKey: self.getKeyForCachedImage(number: String(index)), toDisk: false) {
                imageViews[index].backgrounImageView.image = image
                imageViews[index].foregroundImageView.image = UIImage(named: "deletePhotoIcon")
            }
        }
        
    }

    func circleCropDidCancel() {
        print("cancelled")
    }

    func getKeyForCachedImage(number: String) -> String {
        return Storage.storage().reference().child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic" + number).fullPath
    }

    @objc func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
