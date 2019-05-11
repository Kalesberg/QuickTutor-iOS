//
//  CustomTextFields.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class MessageTextView: UITextView {
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.border
        label.font = Fonts.createSize(14)
        label.text = "Enter a message..."
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupPlaceHolder()
        setupObservers()
    }
    
    private func setupMainView() {
        backgroundColor = Colors.darkBackground
        textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
    }
    
    private func setupPlaceHolder() {
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 6, paddingBottom: 8, paddingRight: 10, width: 0, height: 0)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

class PaddedTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += 12.5
        return textRect
    }
}

extension PaddedTextField {
    var clearButton: UIButton? {
        return value(forKey: "clearButton") as? UIButton
    }
    
    var clearButtonTintColor: UIColor? {
        get {
            return clearButton?.tintColor
        }
        set {
            let image = clearButton?.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton?.setImage(image, for: .normal)
            clearButton?.tintColor = newValue
        }
    }
}
