import UIKit
import SnapKit

class TutorBioView : EditBioView {
    
    var nextButton = NavbarButtonNext()
    
    override var rightButton: NavbarButton {
        get {
            return nextButton
        } set {
            nextButton = newValue as! NavbarButtonNext
        }
    }
    
    var progressBar = ProgressBar()
    
    override func configureView() {
        addSubview(progressBar)
        super.configureView()
        
        progressBar.progress = 0.33333
        progressBar.applyConstraints()
        
        title.label.text = "Biography"
        textView.textView.text = ""
        
        let attributedString = NSMutableAttributedString(string: "·  What experience and expertise do you have?\n·  Any certifications or awards earned?\n·  What are you looking for in learners?")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        infoLabel.label.attributedText = attributedString;
        infoLabel.label.font = Fonts.createSize(14)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        progressBar.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.height.equalTo(8)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        navbar.backgroundColor = Colors.tutorBlue
        statusbarView.backgroundColor = Colors.tutorBlue
        textView.textView.tintColor = Colors.tutorBlue
    }
    
    override func keyboardWillAppear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
                self.infoLabel.alpha = 0.0
            })
            return
        }
    }
    
    override func keyboardWillDisappear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
                self.infoLabel.alpha = 1.0
            })
            return
        }
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
        contentView.textView.textView.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.textView.textView.resignFirstResponder()
    }
    override func handleNavigation() {
        if (touchStartView is NavbarButtonNext) {
            
            guard let bio = contentView.textView.textView.text, bio.count >= 20 else {
                if !contentView.errorLabel.isHidden {
                    contentView.errorLabel.shake()
                }
                contentView.errorLabel.isHidden = false
                return
            }
            
            TutorRegistration.tutorBio = bio
            navigationController?.pushViewController(TutorSSN(), animated: true)
        }
    }
    
    @objc func keyboardWillAppear() {
        (self.view as! EditBioView).keyboardWillAppear()
    }
    
    @objc func keyboardWillDisappear() {
        (self.view as! EditBioView).keyboardWillDisappear()
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
