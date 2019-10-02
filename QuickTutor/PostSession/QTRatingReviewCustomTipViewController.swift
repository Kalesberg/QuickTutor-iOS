//
//  QTRatingReviewCustomTipViewController.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/9/21.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol QTRatingReviewCustomTipViewControllerDelegate {
    func viewController (_ viewController: QTRatingReviewCustomTipViewController, didSelectCustomTip tip: Double)
    func viewController (didDismiss: QTRatingReviewCustomTipViewController)
}

class QTRatingReviewCustomTipViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tipTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    
    static var controller: QTRatingReviewCustomTipViewController {
        return QTRatingReviewCustomTipViewController(nibName: String(describing: QTRatingReviewCustomTipViewController.self), bundle: nil)
    }
    
    var delegate: QTRatingReviewCustomTipViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewController ()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tipTextField.becomeFirstResponder()
    }
    
    
    // MARK: - Event Handlers
    @IBAction func onClickCancel(_ sender: Any) {
        view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
        dismiss(animated: true, completion: nil)
        delegate?.viewController(didDismiss: self)
    }
    
    @IBAction func onClickOk(_ sender: Any) {
        view.endEditing(true)
        guard let text = tipTextField.text else { return }
        let tip = Double(text) ?? 0
        delegate?.viewController(self, didSelectCustomTip: tip)
        
        NotificationCenter.default.removeObserver(self)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Initialize Handlers
    private func initViewController () {
        
        // text field
        tipTextField.text = "5.0"
        
        // add notification observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow (_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide (_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // MARK: - Notification Handlers
    @objc
    private func keyboardWillShow (_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: keyboardFrame.cgRectValue.height / 2), animated: true)
        }
    }
    
    @objc
    private func keyboardWillHide (_ notification: Notification) {
        scrollView.setContentOffset(.zero, animated: true)
    }
}

extension QTRatingReviewCustomTipViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else {
            return false
        }
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        let tip = Double(updatedText) ?? 0
        
        okButton.isEnabled = tip > 0
        return tip <= 250
    }
}
