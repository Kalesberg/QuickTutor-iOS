//
//  TutorAddUsername.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TutorAddUsernameTextfield : InteractableView {
    
    let headerLabel : UILabel = {
        let label = UILabel()
        
        label.text = "QuickTutor Username"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        
        return label
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Having a unique username will help learners find you."
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(14)
        label.numberOfLines = 0
        
        return label
    }()
    
    let textField : NoPasteTextField = {
        let textField = NoPasteTextField()
        
        textField.font = Fonts.createSize(22)
        textField.textColor = .white
        textField.isEnabled = true
        textField.tintColor = .white
        textField.autocapitalizationType = .none
        
        return textField
    }()
    
    let characterLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Must not be longer than 15 characters."
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(18)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    let line = UIView()
    
    override func configureView() {
        addSubview(headerLabel)
        addSubview(infoLabel)
        addSubview(textField)
        addSubview(line)
        addSubview(characterLabel)
        super.configureView()
        
        line.backgroundColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        headerLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        textField.snp.makeConstraints { (make) in
            make.width.equalTo(headerLabel)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(infoLabel.snp.bottom).inset(-5)
        }
        
        line.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        characterLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).inset(-15)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}


class TutorAddUsernameView : TutorRegistrationLayout, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    let contentView = UIView()
    let textField = TutorAddUsernameTextfield()
    
    override func configureView() {
        addKeyboardView()
        addSubview(contentView)
        contentView.addSubview(textField)
        super.configureView()
        
        title.label.text = "Create a Username"
        
        addSubview(progressBar)
        progressBar.progress = 1
        progressBar.applyConstraints()
        progressBar.divider.isHidden = true
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        contentView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom).inset(8)
            make.bottom.equalTo(keyboardView.snp.top)
        }
        
        textField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-50)
            make.height.equalTo(120)
            make.width.equalToSuperview().multipliedBy(0.85)
        }
    }
}


class TutorAddUsername : BaseViewController {
    
    override var contentView: TutorAddUsernameView {
        return view as! TutorAddUsernameView
    }
    
    private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)

	var naughtyWords = [String]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		contentView.textField.textField.delegate = self
        contentView.textField.textField.becomeFirstResponder()
		naughtyWords = BadWords.loadBadWords()
    }
    override func loadView() {
        view = TutorAddUsernameView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func doesContainNaughtyWord(text: String, naughtyWords: [String]) -> Bool {
        return naughtyWords.reduce(false) {$0 || text.contains ($1.lowercased()) }
    }
    
    func isValidUsername(username: String) -> Bool {
        let regex = "\\A\\w{3,15}\\z"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: username)
    }
    
    func endsWithSpecial(username: String) -> Bool {
        let lastChar = username.last!
        
        if lastChar == "_" {
            return false
        }
        return true
    }
    
    func checkIfUsernamAlreadyExists(text: String, completion: @escaping (Bool) -> Void) {
        ref.child("tutor-info").queryOrdered(byChild: "usr").queryLimited(toFirst: 1).queryEqual(toValue: text).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount == 0)
        })
    }
    
    override func handleNavigation() {
        if (touchStartView is NavbarButtonNext) {
            
            let username = contentView.textField.textField.text!
            
            if !doesContainNaughtyWord(text: username, naughtyWords: naughtyWords) && isValidUsername(username: username) && endsWithSpecial(username: username) {
				self.displayLoadingOverlay()
                checkIfUsernamAlreadyExists(text: username) { (success) in
                    if success {
                        TutorRegistration.username = username
                        self.navigationController?.pushViewController(TutorPolicy(), animated: true)
                    } else {
                        print("username already exists.")
                    }
					self.dismissOverlay()
                }
            } else {
                print("Something went wrong, please try again.")
            }
        }
    }
}
extension TutorAddUsername : UITextFieldDelegate {
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let inverseSet = NSCharacterSet(charactersIn:"0123456789qwertyuioplkjhgfdsazxcvbnm_").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        
        if let _ = string.rangeOfCharacter(from: .uppercaseLetters) {
            return false
        }
        if textField.text!.count == 0 {
            return (string.rangeOfCharacter(from: .letters) != nil)
        }
        
        if textField.text!.count <= 15 {
            if string == "" {
                return true
            }
            return string == filtered
        } else {
            if string == "" {
                return true
            }
            return false
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
