//
//  NoPasteTextField.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class NoPasteTextField: UITextField {

	public required init() {
        super.init(frame: .zero)
        configureTextField()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTextField()
    }
    
    internal func configureTextField() {
        autocorrectionType = .no
		keyboardAppearance = .dark
	}
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        } else if action == #selector(select(_:)) {
            return false
        } else if action == #selector(selectAll(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class CreditCardNumberTextField : NoPasteTextField {	
	override func configureTextField() {
		super.configureTextField()
		
		attributedPlaceholder = NSAttributedString(string: "XXXX", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
		textColor = .white
		tintColor = UIColor.white
		adjustsFontSizeToFitWidth = true
		adjustsFontForContentSizeCategory = true
		keyboardType = .numberPad
		keyboardAppearance = .dark
		font = Fonts.createSize(20)
        textAlignment = .left
	}
}

class FullNameTextField : NoPasteTextField {	
	override func configureTextField() {
		super.configureTextField()
		attributedPlaceholder = NSAttributedString(string: "Your Full Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
		textColor = .white
		textAlignment = .left
		keyboardType = .default
		returnKeyType = .done
		autocapitalizationType = .words
		tintColor = .white
		font = Fonts.createSize(14)
		adjustsFontSizeToFitWidth = true
		adjustsFontForContentSizeCategory = true
	}
}
class CVCTextField : NoPasteTextField {
	override func configureTextField() {
		super.configureTextField()
		layer.borderColor =  UIColor(red: 0.3019312322, green: 0.3019797206, blue: 0.3019206524, alpha: 1).cgColor
		layer.borderWidth = 2
        layer.cornerRadius = 2
		attributedPlaceholder = NSAttributedString(string: "XXX", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
		textColor = .white
		tintColor = UIColor.clear
		keyboardType = .numberPad
		font = Fonts.createSize(20)
		textAlignment = .center
	}
}

class ExpDateTextField : NoPasteTextField {
	override func configureTextField() {
		super.configureTextField()
		attributedPlaceholder = NSAttributedString(string: "MM/YY", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
		textColor = .white
		textAlignment = .right
		tintColor = .white
		keyboardType = .numberPad
		returnKeyType = .next
		font = Fonts.createSize(14)
	}
}
