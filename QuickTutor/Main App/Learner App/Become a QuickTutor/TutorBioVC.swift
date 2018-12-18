import SnapKit
import UIKit


class TutorBioVC: BaseRegistrationController {

    let contentView: TutorBioVCView = {
        let view = TutorBioVCView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupTextView()
        hideKeyboardWhenTappedAround()
        progressView.setProgress(2/6)
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext(_:)), for: .touchUpInside)
    }

    func setupTextView() {
        contentView.textView.delegate = self
        contentView.textView.inputAccessoryView = accessoryView
        contentView.textView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.textView.resignFirstResponder()
    }
    
    @objc func handleNext(_ sender: UIButton) {
        guard let bio = contentView.textView.text, bio.count >= 20, bio.count <= 500 else {
            contentView.errorLabel.text = (contentView.textView.text.count > 500) ? "Bio can not exceed 500 characters" : "Bio must be at least 20 characters"
            contentView.errorLabel.isHidden = false
            return
        }
        TutorRegistration.tutorBio = bio
        navigationController?.pushViewController(TutorSSNVC(), animated: true)
    }
}

extension TutorBioVC: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        let maxCharacters = 500
        contentView.errorLabel.isHidden = true
        let characters = contentView.textView.text.count
        let charactersFromMax = maxCharacters - characters
//
//        if characters <= maxCharacters {
//            contentView.characterCount.label.textColor = .white
//            contentView.characterCount.label.text = String(charactersFromMax)
//        } else {
//            contentView.characterCount.label.textColor = UIColor.red
//            contentView.characterCount.label.text = String(charactersFromMax)
//        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
