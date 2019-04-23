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
    
    func isBioCorrectLength(didTapNext: Bool = false) -> Bool {
        guard let bio = contentView.textView.text else {
            return false
        }
        
        if didTapNext && bio.count < 20 {
            contentView.errorLabel.text = "Bio must be at least 20 characters"
            contentView.errorLabel.isHidden = false
            return false
        }

        if bio.count > 500 {
            contentView.errorLabel.text = "Bio can not exceed 500 characters"
            contentView.errorLabel.isHidden = false
            return false
        }

        contentView.errorLabel.isHidden = true
        return true
    }
    
    @objc func handleNext(_ sender: UIButton) {
        if isBioCorrectLength(didTapNext: true) {
            TutorRegistration.tutorBio = contentView.textView.text
            navigationController?.pushViewController(TutorSSNVC(), animated: true)
        }
    }
}

extension TutorBioVC: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        _ = isBioCorrectLength()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
