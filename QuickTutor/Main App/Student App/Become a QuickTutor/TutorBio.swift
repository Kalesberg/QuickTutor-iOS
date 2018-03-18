import UIKit
import SnapKit

class TutorBioView : EditBioView {
    
    var nextButton = RegistrationNextButton()
    
    override func configureView() {
        contentView.addSubview(nextButton)
        super.configureView()
        
        rightButton.isHidden = true
        contentView.isUserInteractionEnabled = true
        
        
        title.label.text = "Biography"
        textView.textView.text = ""
        
        let attributedString = NSMutableAttributedString(string: "·  What Experience and Expertise do you have?\n·  Any certifications or awards earned?\n·  What are you looking for in learners?")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        infoLabel.label.attributedText = attributedString;
        infoLabel.label.font = Fonts.createSize(14)
        infoLabel.isUserInteractionEnabled = true
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
        }
        
    }
    
    override func keyboardWillAppear() {
        infoLabel.fadeOut(withDuration: 0.3)
    }
    
    override func keyboardDidDisappear() {
        infoLabel.fadeIn(withDuration: 0.3, alpha: 1.0)
    }
}

class TutorBio: BaseViewController {
    
    override var contentView: TutorBioView {
        return view as! TutorBioView
    }
    
    override func loadView() {
        view = TutorBioView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        contentView.textView.textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: Notification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.textView.textView.becomeFirstResponder()
	}
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		contentView.textView.textView.resignFirstResponder()
	}
    override func handleNavigation() {
        if (touchStartView is RegistrationNextButton) {
		
			guard let bio = contentView.textView.textView.text, bio.count > 20 else {
				print("Add a bio my dude.")
				return
			}
			
			TutorRegistration.tutorBio = bio
			navigationController?.pushViewController(TutorPayment(), animated: true)
		}
    }
    
    @objc func keyboardWillAppear() {
        if (UIScreen.main.bounds.height == 568) {
            (self.view as! EditBioView).keyboardWillAppear()
        }
    }
    
    @objc func keyboardDidDisappear() {
        if (UIScreen.main.bounds.height == 568) {
            (self.view as! EditBioView).keyboardDidDisappear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TutorBio : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let maxCharacters = 300
        
        let characters = contentView.textView.textView.text.count
        let charactersFromMax = maxCharacters - characters
        
        if characters <= maxCharacters {
            contentView.characterCount.label.textColor = .white
            contentView.characterCount.label.text = String(charactersFromMax)
        }else{
            contentView.characterCount.label.textColor = UIColor.red
            contentView.characterCount.label.text = String(charactersFromMax)
        }
    }
}

