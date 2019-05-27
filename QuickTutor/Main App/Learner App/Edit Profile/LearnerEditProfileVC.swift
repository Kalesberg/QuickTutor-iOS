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
import CropViewController


protocol QTProfileDelegate {
    func didUpdateTutorProfile(tutor: AWTutor)
    func didUpdateLearnerProfile(learner: AWLearner)
}

class EditPreferencesVC: TutorPreferencesVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Hourly Rate & Preferences"
        accessoryView.isHidden = true//contentView..removeFromSuperview()
        progressView.removeFromSuperview()
        contentView.hourSliderView.slider.value = Float(CurrentUser.shared.tutor.price!)
        contentView.distanceSliderView.slider.value = Float(CurrentUser.shared.tutor.distance!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(savePreferences))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back_arrow"), style: .plain, target: self, action: #selector(backAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

class TutorEditProfileVC: LearnerEditProfileVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionTitles.insert("Tutoring", at: 1)
        if automaticScroll {
            let indexPath = IndexPath(row: 2, section: 1)
            contentView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didUpdateTutorProfile(tutor: CurrentUser.shared.tutor)
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
            return 4
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
            return 115
        case 1:
            return indexPath.row == 2 ? 140 : 75
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
                cell.delegate = self
                if CurrentUser.shared.learner.bio != "" {
                    cell.textView.text = CurrentUser.shared.learner.bio
                    cell.textView.placeholderLabel.text = nil
                }
                if AccountService.shared.currentUserType == .tutor {
                    cell.textView.text = CurrentUser.shared.tutor.tBio
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
                cell.textField.placeholder.text = "Featured Subject"
                cell.textField.textField.attributedText = NSAttributedString(string: "Set Featured Subject", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
            case 2:
                cell.textField.placeholder.text = "Policies"
                cell.textField.textField.attributedText = NSAttributedString(string: "Manage Policies", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
            case 3:
                cell.textField.placeholder.text = "Preferences"
                cell.textField.textField.attributedText = NSAttributedString(string: "Hourly Rate & Preferences", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
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
                let vc = TutorAddSubjectsVC()
                vc.isViewing = true
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                navigationController?.pushViewController(FeaturedSubjectVC(), animated: true)
            case 2:
                navigationController?.pushViewController(TutorManagePolicies(), animated: true)
            case 3:
                let vc = EditPreferencesVC()
                vc.inRegistrationMode = false
                navigationController?.pushViewController(vc, animated: true)
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

protocol LearnerWasUpdatedCallBack {
    func learnerWasUpdated(learner: AWLearner!)
}

class LearnerEditProfileVC: UIViewController {
    
    var sectionTitles = ["About me", "Private information", "Optional information"]
    var delegate: QTProfileDelegate?
    var firstName: String!
    var lastName: String!
    var automaticScroll = false
    let imagePicker = UIImagePickerController()
    var imageToChange: Int = 0
    var tempBio: String?
    var bioNeedsSaving = false
    var updatedBio: String?

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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back_arrow"), style: .plain, target: self, action: #selector(backAction))
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Hide the bottom tab bar and relayout views
        tabBarController?.tabBar.isHidden = true
        edgesForExtendedLayout = .bottom
        extendedLayoutIncludesOpaqueBars = true
        
        updateLearner()
        setupName()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveTempBio()
        delegate?.didUpdateLearnerProfile(learner: CurrentUser.shared.learner)
    }
    
    func saveTempBio() {
        if let cell = contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? EditProfileBioCell {
            guard let newBio = cell.textView.text else { return }
            if AccountService.shared.currentUserType == .learner {
                if newBio != CurrentUser.shared.learner.bio {
                    tempBio = newBio
                }
            } else {
                if newBio != CurrentUser.shared.tutor.tBio {
                    tempBio = newBio
                }
            }
        }
    }
    
    func isBioCorrectLength(didTapSave: Bool = false) -> Bool {
        guard let cell = contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? EditProfileBioCell, let bio = cell.textView.text else {
            return false
        }
        
        if didTapSave && bio.count > 0 && bio.count < 20 {
            cell.errorLabel.text = "Bio must be at least 20 characters"
            cell.errorLabel.isHidden = false
            return false
        }
        
        if bio.count > 500 {
            cell.errorLabel.text = "Bio can not exceed 500 characters"
            cell.errorLabel.isHidden = false
            return false
        }
        
        cell.errorLabel.isHidden = true
        return true
    }
    
    func updateLearner() {
        guard let learner = CurrentUser.shared.learner else { return }
        self.learner = learner
    }
    
    func setupName() {
        let name = learner.name.split(separator: " ")
        if !name.isEmpty {
            firstName = String(name[0])
            lastName = String(name[1])
        }
    }
    
    func displayUnSavedChangesAlertController() {
        let alertController = UIAlertController(title: "Unsaved changes", message: "Would you like to save your changes?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            self.saveChanges()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
     func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your profile changes have been saved", preferredStyle: .alert)
        
        present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            alertController.dismiss(animated: true) {
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
    
    func isContextDirty() -> Bool {
        var sharedUser = CurrentUser.shared.learner
        if AccountService.shared.currentUserType == .tutor {
            sharedUser = CurrentUser.shared.tutor
        }
        
        if let user = sharedUser  {
            let name = user.name.split(separator: " ")
            if !name.isEmpty {
                let fName = String(name[0])
                let lName = String(name[1])
                
                if fName != firstName || lName != lastName {
                    return true
                }
            }
            
            if let cell = contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? EditProfileBioCell {
                if let newBio = cell.textView.text {
                    switch AccountService.shared.currentUserType {
                    case .learner:
                        if CurrentUser.shared.learner.bio != newBio {
                            return true
                        }
                    case .tutor:
                        if CurrentUser.shared.tutor.tBio != newBio {
                            return true
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        return false
    }
    
    @objc func backAction() {
        if isContextDirty() {
            displayUnSavedChangesAlertController()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func saveChanges() {
        if (firstName ?? "").isEmpty || (lastName ?? "").isEmpty {
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
        

        guard saveBioIfNeeded() else {
            return
        }
        
        Tutor.shared.updateSharedValues(multiWriteNode: newNodes) { error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                CurrentUser.shared.learner.name = self.firstName + " " + self.lastName
                self.displaySavedAlertController()
            }
        }
    }
    
    func saveBioIfNeeded() -> Bool {
        guard bioNeedsSaving else {
            return true
        }
        
        if !isBioCorrectLength(didTapSave: true) {
            return false
        }
        
        guard let newBio = updatedBio else { return false }
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
        return true

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
            return 115
        case 1:
            return indexPath.row == 2 ? 140 : 75
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
                cell.textView.delegate = self
                if CurrentUser.shared.learner.bio != "" {
                    cell.textView.text = CurrentUser.shared.learner.bio
                    cell.textView.placeholderLabel.text = nil
                    if let tempBio = tempBio {
                        cell.textView.text = tempBio
                    }
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
        cell.growShrink()
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

    func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        automaticScroll = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }
}

extension LearnerEditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func getKeyForCachedImage(number: String) -> String {
        return Storage.storage().reference().child("student-info").child(CurrentUser.shared.learner.uid!).child("student-profile-pic" + number).fullPath
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        picker.dismiss(animated: false) {
            let cropViewController = CropViewController(croppingStyle: .circular, image: image)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetSquare
            self.present(cropViewController, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension LearnerEditProfileVC: CropViewControllerDelegate {
    func getImageViewCells() -> [EditProfileImageCell] {
        var imageViewCells = [EditProfileImageCell]()
        let imagesContainerCell = contentView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileImagesCell
        let imageCell1 = imagesContainerCell.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! EditProfileImageCell
        imageViewCells.append(imageCell1)
        let imageCell2 = imagesContainerCell.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! EditProfileImageCell
        imageViewCells.append(imageCell2)
        let imageCell3 = imagesContainerCell.collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as! EditProfileImageCell
        imageViewCells.append(imageCell3)
        return imageViewCells
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        var imageViews = getImageViewCells()
        
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
                print("Changin image at index", index)
                imageViews[index - 1].backgrounImageView.image = image
                let forgroundImage = index != 1 ? UIImage(named: "deletePhotoIcon") : UIImage(named: "uploadImageIcon")
                imageViews[index - 1].foregroundImageView.image = forgroundImage
            }
        }
        
        cropViewController.dismiss(animated: true, completion: nil)
    }

}

extension LearnerEditProfileVC: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        _ = isBioCorrectLength()
    }
}

extension LearnerEditProfileVC: EditProfileBioCellDelegate {
    func editProfileBioCell(_ editProfileBioCell: EditProfileBioCell, didUpdate bio: String) {
        updatedBio = bio
        bioNeedsSaving = true
    }
}
