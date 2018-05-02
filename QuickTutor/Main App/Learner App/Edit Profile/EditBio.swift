//
//  EditBio.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


import Foundation
import UIKit

class EditBioTextView : BaseView {
    
    let textView : UITextView = {
        let textView = UITextView()
        
        textView.font = Fonts.createSize(20)
        textView.keyboardAppearance = .dark
        textView.textColor = .white
        textView.tintColor = .white
        textView.backgroundColor = .clear
        textView.returnKeyType = .default
        textView.font = Fonts.createSize(18)
        
        return textView
    }()
    
    override func configureView() {
        addSubview(textView)
		
		if AccountService.shared.currentUserType == .learner {
			textView.text = CurrentUser.shared.learner.bio
		} else if AccountService.shared.currentUserType == .tutor {
			if (CurrentUser.shared.tutor != nil) {
				print("exists")
				textView.text = CurrentUser.shared.tutor.tBio
			} else {
				print("does not exist")
			}
		}
        applyConstraints()
    }
    
    override func applyConstraints() {
        textView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(30)
        }
    }
}

class EditBioView : MainLayoutTitleBackSaveButton, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    var titleLabel = LeftTextLabel()
    var contentView = UIView()
    var textView = EditBioTextView()
    var characterCount = LeftTextLabel()
    var infoLabel = LeftTextLabel()
    
    let errorLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .red
        label.font = Fonts.createItalicSize(15)
        label.isHidden = true
        label.text = "Bio must be at least 20 characters"
        
        return label
    }()
	
	override func configureView() {
        addKeyboardView()
        addSubview(contentView)
        contentView.addSubview(textView)
        contentView.addSubview(titleLabel)
        textView.addSubview(characterCount)
        textView.addSubview(errorLabel)
        contentView.addSubview(infoLabel)
        super.configureView()
        
        title.label.text = "Edit Profile"
        
        titleLabel.label.text = "About me"
        titleLabel.label.font = Fonts.createBoldSize(16)
		
        
        textView.backgroundColor = Colors.registrationDark
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 10
        
        characterCount.label.adjustsFontForContentSizeCategory = true
        characterCount.label.adjustsFontSizeToFitWidth = true
        characterCount.label.textColor = .white
        characterCount.label.font = Fonts.createSize(14)
        characterCount.label.text = "300"
        
        let attributedString = NSMutableAttributedString(string: "· Tell us about yourself.\n· What would you like to learn?\n· What are you looking for in a tutor?")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        infoLabel.label.attributedText = attributedString;
        infoLabel.label.font = Fonts.createSize(14)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalTo(keyboardView.snp.top)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        titleLabel.label.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.25)
            make.width.equalToSuperview()
        }
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(180)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        characterCount.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(characterCount.snp.right).inset(-10)
            make.bottom.equalToSuperview().inset(10)
        }
    
        infoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(12)
            make.right.equalToSuperview()
            make.top.equalTo(textView.snp.bottom).inset(-15)
        }
    }
    
    func keyboardWillAppear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            infoLabel.alpha = 0.0
            return
        }
    }
    
    func keyboardWillDisappear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
                self.infoLabel.alpha = 1.0
            })
        }
    }
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if AccountService.shared.currentUserType == .tutor {
			navbar.backgroundColor = Colors.tutorBlue
			statusbarView.backgroundColor = Colors.tutorBlue
			textView.textView.tintColor = Colors.tutorBlue
		} else if AccountService.shared.currentUserType == .learner {
			navbar.backgroundColor = Colors.learnerPurple
			statusbarView.backgroundColor = Colors.learnerPurple
			textView.textView.tintColor = Colors.learnerPurple

		} else {
			
		}
	}
}


class EditBio : BaseViewController {
    
    override var contentView: EditBioView {
        return view as! EditBioView
    }
	
	override func loadView() {
		view = EditBioView()
	}
	
	var originalBio : String = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		contentView.textView.textView.delegate = self
		NavbarButtonBack.enabled = false
		
		originalBio = contentView.textView.textView.text
        
        contentView.characterCount.label.text = String(300 - originalBio.count)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.textView.textView.becomeFirstResponder()

	}
    
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NavbarButtonBack.enabled = true
	}
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if (touchStartView is NavbarButtonSave) {
            if contentView.textView.textView.text.count < 20 {
                if !contentView.errorLabel.isHidden {
                    contentView.errorLabel.shake()
                } else {
                    contentView.errorLabel.isHidden = false
                }
            } else {
                contentView.errorLabel.isHidden = true
                self.dismissKeyboard()
                saveChanges()
            }
		} else if (touchStartView is NavbarButtonBack) {
            if contentView.textView.textView.text.count < 20 && !(contentView.textView.textView.text.count == 0) {
                contentView.errorLabel.isHidden = false
            } else if originalBio != contentView.textView.textView.text {
				changedEditBioAlert()
                contentView.errorLabel.isHidden = true
			} else {
                contentView.errorLabel.isHidden = true
				navigationController?.popViewController(animated: true)
			}
		}
    }
    
    @objc func keyboardWillAppear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            (self.view as! EditBioView).keyboardWillAppear()
        }
    }
    
    @objc func keyboardWillDisappear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            (self.view as! EditBioView).keyboardWillDisappear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
	private func saveChanges() {
	
		switch AccountService.shared.currentUserType {
			
		case .learner:
			
				FirebaseData.manager.updateValue(node: "student-info", value: ["bio" : contentView.textView.textView.text!])
				CurrentUser.shared.learner.bio = contentView.textView.textView.text!
				displaySavedAlertController()

		case .tutor :
			
			Tutor.shared.updateValue(value: ["tbio" : contentView.textView.textView.text!])
			CurrentUser.shared.tutor.tBio = contentView.textView.textView.text!
			displaySavedAlertController()
		}
	}
	
	private func changedEditBioAlert() {
		let alertController = UIAlertController(title: "Would you like to save your changes?", message: "You have unsaved changes in your bio", preferredStyle: .actionSheet)
		let save = UIAlertAction(title: "Save", style: .default) { (alert) in
			self.saveChanges()
		}
		let noThanks = UIAlertAction(title: "No Thanks", style: .default) { (alert) in
			self.navigationController?.popViewController(animated: true)
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
			self.dismiss(animated: true, completion: nil)
		}
		
		alertController.addAction(save)
		alertController.addAction(noThanks)
		alertController.addAction(cancel)
		
		present(alertController, animated: true, completion: nil)
		
	}
}

extension EditBio : UITextViewDelegate {
	
	func textViewDidChange(_ textView: UITextView) {
		let maxCharacters = 300
		
		let characters = contentView.textView.textView.text.count
		let charactersFromMax = maxCharacters - characters
		
		if characters <= maxCharacters {
			contentView.characterCount.label.textColor = .white
			contentView.characterCount.label.text = String(charactersFromMax)

		} else {
			contentView.characterCount.label.textColor = UIColor.red
			contentView.characterCount.label.text = String(charactersFromMax)
		}
	}
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
}
