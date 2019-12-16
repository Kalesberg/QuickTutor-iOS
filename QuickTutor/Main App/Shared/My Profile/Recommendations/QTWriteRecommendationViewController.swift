//
//  QTWriteRecommendationViewController.swift
//  QuickTutor
//
//  Created by JH Lee on 8/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper

class QTWriteRecommendationViewController: UIViewController {

    var objTutor: AWTutor!
    
    @IBOutlet weak var txtRecommendation: UITextView!
    @IBOutlet weak var btnSubmit: DimmableButton!
    @IBOutlet weak var constraintViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Recommend \(objTutor.firstName ?? "")"
        
        btnSubmit.isEnabled = false
        btnSubmit.backgroundColor = Colors.gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        txtRecommendation.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        txtRecommendation.resignFirstResponder()
    }
    
    @objc
    private func onKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        var keyboardHeight = keyboardFrame.cgRectValue.height
        if #available(iOS 11.0, *) {
            keyboardHeight -= view.safeAreaInsets.bottom
        } else {
            keyboardHeight -= bottomLayoutGuide.length
        }
        
        UIView.animate(withDuration: 0.3) {
            self.constraintViewBottom.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func onClickBtnSubmit(_ sender: Any) {
        let refRecommendation = Database.database().reference().child("recommendations").child(objTutor.uid)
        guard let recommendationId = refRecommendation.childByAutoId().key else { return }
        
        let recommendation: [String: Any] = [
            "uid": recommendationId,
            "learnerId": CurrentUser.shared.learner.uid,
            "learnerName": CurrentUser.shared.learner.formattedName,
            "learnerAvatarUrl": CurrentUser.shared.learner.profilePicUrl.absoluteString,
            "recommendationText": txtRecommendation.text,
            "createdAt": Date().timeIntervalSince1970
        ]
        guard let objRecommendation = Mapper<QTTutorRecommendationModel>().map(JSON: recommendation) else { return }
        
        txtRecommendation.resignFirstResponder()
        displayLoadingOverlay()
        refRecommendation.child(recommendationId).setValue(objRecommendation.toJSON()) { error, ref in
            self.dismissOverlay()
            if nil == self.objTutor.recommendations {
                self.objTutor.recommendations = []
            }
            self.objTutor.recommendations?.insert(objRecommendation, at: 0)
            self.navigationController?.popViewController(animated: true)
        }
    }    

}

extension QTWriteRecommendationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        btnSubmit.isEnabled = !textView.text.isEmpty
        btnSubmit.backgroundColor = btnSubmit.isEnabled ? Colors.purple : Colors.gray
    }
}
