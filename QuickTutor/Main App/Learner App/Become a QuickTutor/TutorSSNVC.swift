//
//  TutorSSN.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import SnapKit
import UIKit

class TutorSSNView: TutorRegistrationLayout {

	let ssnTextField: NoPasteTextField = {
		let textField = NoPasteTextField()
		
		textField.font = Fonts.createBoldSize(24)
		textField.textColor = .white
		textField.tintColor = .white
		textField.textAlignment = .center
		textField.keyboardType = .numberPad
		textField.keyboardAppearance = .dark
		textField.isSecureTextEntry = true

		return textField
	}()

    var titleLabel: UILabel = {
        let label = UILabel()
		
        label.text = "For authentication and safety purposes, we'll need your social security number."
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
		
        return label
    }()

	let lockImageView : UIImageView = {
		let imageView = UIImageView()
		
		imageView.image = UIImage(named: "registration-ssn-lock")
		
		return imageView
	}()
	let ssnInfo : LeftTextLabel = {
		let leftTextLabel = LeftTextLabel()
		
		leftTextLabel.label.text = "· Your SSN remains private.\n· No credit check - credit won't be affected.\n· Your information is safe and secure."
		leftTextLabel.label.font = Fonts.createSize(15)
		
		return leftTextLabel
	}()

	var textFieldContainer = UIView()
	
    override func configureView() {
        addSubview(titleLabel)
        addSubview(ssnInfo)
		addSubview(textFieldContainer)
		textFieldContainer.addSubview(ssnTextField)
        super.configureView()
		setupView()
        ssnTextField.defaultTextAttributes.updateValue(10.0, forKey: NSAttributedString.Key(rawValue: NSAttributedString.Key.kern.rawValue))
    }

    override func applyConstraints() {
        super.applyConstraints()
        titleLabel.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom).inset(-35)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
        }
		textFieldContainer.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(100)
		}
		ssnTextField.snp.makeConstraints { (make) in
			make.center.width.equalToSuperview()
			make.height.equalTo(75)
		}
        ssnInfo.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainer.snp.bottom)
            make.width.equalTo(titleLabel)
            make.centerX.equalToSuperview()
        }
    }
	
	private func setupView() {
		progressBar.progress = 0.5
		progressBar.applyConstraints()
		
		title.label.text = "SSN"
		
		navbar.backgroundColor = Colors.tutorBlue
		statusbarView.backgroundColor = Colors.tutorBlue
	}
}

class TutorSSNVC: BaseViewController {
    override var contentView: TutorSSNView {
        return view as! TutorSSNView
    }

    override func loadView() {
        view = TutorSSNView()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
		contentView.ssnTextField.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		contentView.ssnTextField.becomeFirstResponder()
	}

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	private func checkForValidSSN() -> String? {
		guard let ssn = contentView.ssnTextField.text,
			  ssn.count == 9,
			  CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: ssn))
		else {
			return nil
		}
		return ssn
	}
	
    override func handleNavigation() {
        if touchStartView is NavbarButtonNext {
			if let tutorSSN = checkForValidSSN() {
				TutorRegistration.ssn = tutorSSN
				navigationController?.pushViewController(TutorRegPaymentVC(), animated: true)
			}
        }
    }
}

extension TutorSSNVC: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		guard let text = textField.text else { return true }
		let newLength = text.utf16.count + string.utf16.count - range.length
		
		return string == filtered &&  newLength <= 9
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return false
	}
}
