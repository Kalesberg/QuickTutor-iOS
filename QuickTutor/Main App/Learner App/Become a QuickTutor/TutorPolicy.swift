//
//  TutorPolicy.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth

class TutorPolicyView : BaseLayoutView {
	
    let qtTitle : UILabel = {
        var label = UILabel()
        
        label.font = Fonts.createBoldItalicSize(26)
        label.text = "QuickTutor Agreement"
        label.textColor = .white
        
        return label
    }()
    
    let scrollView : UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
    }()
    
    let scrollViewLabel : UILabel = {
        let formattedString = NSMutableAttributedString()
        formattedString
            .regular("Your relationship with QuickTutor\n\n", 15, .white)
            .regular("On QuickTutor, you're an independent tutor in full control of your business. You have the freedom to choose which opportunities to pursue, when you want to tutor, and how much you charge.\n\n", 13, Colors.grayText)
            .regular("Communicate through the app\n\n", 15, .white)
            .regular("The QuickTutor messaging system allows you to communicate and set up tutoring sessions, without having to give away any personal or private information like your phone number or email. Keep your conversations in the messaging system to protect yourself.\n\n", 13, Colors.grayText)
            .regular("The ultimate biz management tool\n\n", 15, .white)
            .regular("With QuickTutor, you'll be able to schedule and facilitate your in-person and online sessions through the app, and recieve instant payments for tutoring. Make sure to keep your sessions through the app to avoid not being paid on time, not being paid at all, or not revieving a rating.", 13, Colors.grayText)
        
        var label = UILabel()
        label.sizeToFit()
        label.numberOfLines = 0
        label.attributedText = formattedString
        
        return label
    }()
    
    let bottomView : UIView = {
        var view = UIView()
        
        view.backgroundColor = Colors.registrationDark
        
        return view
    }()
    
    let agreementView : UIView = {
        var view = UIView()
        view.backgroundColor = Colors.registrationDark
        
        var label = UILabel()
        view.addSubview(label)
        label.font = Fonts.createSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = Colors.grayText
        label.text = "By checking the box, you confirm that you have reviewed the document above and you agree to its terms."
        label.numberOfLines = 0
        label.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(80)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        })
        
        return view
    }()
    
    let checkBox : RegistrationCheckbox = {
        var check = RegistrationCheckbox()
        
        check.isSelected = false
        
        return check
    }()
    
    let tutorAgreementButton : ArrowItem = {
        var item = ArrowItem()
        
        item.label.text = "Independent Tutor Agreement"
        item.divider.isHidden = true
        item.backgroundColor = Colors.registrationDark
        
        return item
    }()
    
    let pleaseReviewLabel : UILabel = {
        var label = UILabel()
        
        label.textColor = .white
        label.text = "Please review and agree to the document below:"
        label.font = Fonts.createSize(13)
        
        return label
    }()
	
	override func configureView() {
        addSubview(qtTitle)
        addSubview(bottomView)
        addSubview(agreementView)
        addSubview(pleaseReviewLabel)
        agreementView.addSubview(checkBox)
        addSubview(scrollView)
        scrollView.addSubview(scrollViewLabel)
        addSubview(tutorAgreementButton)
		super.configureView()

		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
        qtTitle.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).inset(35)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
        }

        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        agreementView.snp.makeConstraints { (make) in
            make.height.equalTo(80)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        checkBox.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(agreementView.snp.right).inset(80)
            make.centerY.equalToSuperview()
        }
        
        tutorAgreementButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(agreementView.snp.top).inset(-1)
            make.height.equalTo(40)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        pleaseReviewLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(tutorAgreementButton.snp.top)
            make.width.equalToSuperview()
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(qtTitle.snp.bottom).inset(-10)
            make.bottom.equalTo(pleaseReviewLabel.snp.top)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        
        scrollViewLabel.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        })
	}
}

class TutorPolicy : BaseViewController {
	
	override var contentView: TutorPolicyView {
		return view as! TutorPolicyView
	}
	
	override func loadView() {
		view = TutorPolicyView()
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        contentView.layoutIfNeeded()
        contentView.scrollView.contentSize = CGSize(width: contentView.scrollView.frame.width, height: contentView.scrollViewLabel.frame.height)
        contentView.applyGradient(firstColor: UIColor(hex:"2c467c").cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 200, frame: contentView.bounds)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	private func accepted() {
		Tutor.shared.initTutor(completion: { (error) in
			if let error = error {
				print(error.localizedDescription)
			} else {
				self.navigationController?.pushViewController(TutorPageViewController(), animated: true)
				let endIndex = self.navigationController?.viewControllers.endIndex
				self.navigationController?.viewControllers.removeFirst(endIndex! - 1)
			}
		})
	}
	
	private func declined() {
		
	}
	
	override func handleNavigation() {
        if (touchStartView == contentView.tutorAgreementButton) {
            //to website
        } else if (touchStartView == contentView.checkBox) {
            accepted()
        }
	}
}

extension NSMutableAttributedString {
    @discardableResult func regular(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "Lato-Regular", size: size)!, .foregroundColor : color]
        let string = NSMutableAttributedString(string:text, attributes: attrs)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, string.length))
        
        append(string)
        
        return self
    }
    
    @discardableResult func bold(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "Lato-Bold", size: size)!, .foregroundColor : color]
        let string = NSMutableAttributedString(string:text, attributes: attrs)
        append(string)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, string.length))
        
        return self
    }
}
