//
//  UserPolicy.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//TODO Backend:
//  - Hyperlink the learn more button

import UIKit
import FirebaseAuth

class UserPolicyView : RegistrationGradientView {
    
    var titleLabel      = RegistrationTitleLabel()
    var textLabel       = LeftTextLabel()
    var buttonView      = UIView()
    var learnMoreButton = LearnMoreButton()
    var acceptButton    = RegistrationBigButton()
    var declineButton   = RegistrationBigButton()
    
    override func configureView() {
        super.configureView()
        
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(buttonView)
        addSubview(learnMoreButton)
        
        buttonView.addSubview(acceptButton)
        buttonView.addSubview(declineButton)
        
        titleLabel.label.text = "Before you join"
        
        textLabel.label.font = Fonts.createLightSize(17)
        textLabel.label.numberOfLines = 0
        textLabel.label.textColor = .white
        textLabel.label.text = "Whether it's your first time on QuickTutor or you've been with us from the very beginning, please commit to respecting and loving everyone in the QuickTutor community.\n\nI agree to treat everyone on QuickTutor regardless of their race, physical features, national origin, ethnicity, religion, sex, disability, gender identity, sexual orientation or age with respect and love, without judgement or bias."
        
        acceptButton.label.label.text = "Accept"
        
        declineButton.label.label.text = "Decline"
        
        textLabel.sizeToFit()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(textLabel.snp.top)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.label.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(learnMoreButton.snp.top)
            make.height.equalTo(320)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }
        
        learnMoreButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(buttonView.snp.top)
            make.top.equalTo(textLabel.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        
        buttonView.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.3)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        acceptButton.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        declineButton.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }
    }
}


class LearnMoreButton : InteractableView, Interactable {
    
    var label = UILabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
    
        label.font = Fonts.createSize(20)
        label.text = "Learn More »"
        label.textColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func touchStart() {
        label.alpha = 0.7
    }
    
    func didDragOff() {
        label.alpha = 1.0
    }
}


class UserPolicy : BaseViewController {
    
    override var contentView: UserPolicyView {
        return view as! UserPolicyView
    }
    
    override func loadView() {
        view = UserPolicyView()
    }
    
    private let userId : String = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.acceptButton.isUserInteractionEnabled = true
	}
    
    override func handleNavigation() {
        if(touchStartView == contentView.acceptButton) {
			accepted()
			contentView.acceptButton.isUserInteractionEnabled = false
        } else if (touchStartView == contentView.declineButton) {
			declined()
            print("decline")
        } else if (touchStartView == contentView.learnMoreButton) {
            print("learn more")
        }
    }
	private func accepted() {
		uploadUser()
		
		SignInHandler.manager.getUserData { (error) in
			if error != nil {
				self.navigationController?.pushViewController(SignIn(), animated: true)
			} else {
				Stripe.stripeManager.retrieveCustomer({ (error) in
					if let error = error {
						print(error)
					} else {
						self.navigationController?.pushViewController(MainPage(), animated: true)
					}
				})
			}
		}
		//Do next steps.
	}

	private func uploadUser() {
		FirebaseData.manager.initUser(completion: { (finished) in
			if finished {
				self.createCustomer()
			} else {
				print("Error uploading ")
				self.contentView.acceptButton.isUserInteractionEnabled = true
			}
		})
	}
	private func createCustomer() {
		Stripe.stripeManager.createCustomer ({ (error) in
			if let error = error {
				print(error.localizedDescription)
				self.contentView.acceptButton.isUserInteractionEnabled = true
			} else {
				Registration.registrationManager.setRegistrationDefaults()
				self.navigationController!.pushViewController(TheChoice(), animated: true)
			}
		})
	}
	
	private func declined() {
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

