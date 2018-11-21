//
//  SettingsAccount.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import FirebaseAuth
import FacebookCore
import FacebookLogin

class SettingsAccount : UIView {
    
    var parentViewController: UIViewController?
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	let sectionTitle : UILabel = {
		let label = UILabel()
		label.text = "Account"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(18)
		return label
	}()

	let showMeOnQT = SettingsButtonToggle(title: "Show me on QuickTutor", subtitle: "You are currently visible in search results.")
	let signOut = SettingsButton(title: "Sign Out")
	let closeAccount = SettingsButton(title: "Close Account", subtitle: "Permanently close your QuickTutor account.")
    let linkFacebook = SettingsButton(title: "Link Facebook")

	let divider1 : UIView = {
		let view = UIView()
		view.backgroundColor = .black
		return view
	}()
	
	let divider2 : UIView = {
		let view = UIView()
		view.backgroundColor = .black
		return view
	}()
	
    let divider3 : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
	private func configureView() {
		addSubview(sectionTitle)
		sectionTitle.snp.makeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.height.equalTo(30)
		}

		if AccountService.shared.currentUserType == .learner {
			setupViewForLearner()
		} else {
			setupViewForTutor()
			setupToggle()
		}
		
		showMeOnQT.toggle.addTarget(self, action: #selector(showMeOnQTPressed(_:)), for: .touchUpInside)
		signOut.buttonMask.addTarget(self, action: #selector(signOutPressed(_:)), for: .touchUpInside)
		closeAccount.buttonMask.addTarget(self, action: #selector(closeAccountPressed(_:)), for: .touchUpInside)
        linkFacebook.buttonMask.addTarget(self, action: #selector(linkFacebook(_:)), for: .touchUpInside)
	}
	
	private func setupViewForTutor() {
		addSubview(showMeOnQT)
		addSubview(divider1)
		addSubview(signOut)
		addSubview(divider2)
		addSubview(closeAccount)
        addSubview(divider3)
        addSubview(linkFacebook)

		showMeOnQT.snp.makeConstraints { (make) in
			make.top.equalTo(sectionTitle.snp.bottom).offset(10)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(60)
		}
		
		divider1.snp.makeConstraints { (make) in
			make.top.equalTo(showMeOnQT.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(1)
		}
		signOut.snp.makeConstraints { (make) in
			make.top.equalTo(divider1.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(50)
		}
		divider2.snp.makeConstraints { (make) in
			make.top.equalTo(signOut.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(1)
		}
		closeAccount.snp.makeConstraints { (make) in
			make.top.equalTo(divider2.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(60)
		}
        divider3.snp.makeConstraints { (make) in
            make.top.equalTo(closeAccount.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(1)
        }
        linkFacebook.snp.makeConstraints { (make) in
            make.top.equalTo(divider3.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
	}
	
	private func setupViewForLearner() {
		addSubview(signOut)
		addSubview(divider1)
		addSubview(closeAccount)
        addSubview(divider2)
        addSubview(linkFacebook)
		
		signOut.snp.makeConstraints { (make) in
			make.top.equalTo(sectionTitle.snp.bottom).offset(10)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(50)
		}
		divider1.snp.makeConstraints { (make) in
			make.top.equalTo(signOut.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(1)
		}
		closeAccount.snp.makeConstraints { (make) in
			make.top.equalTo(divider1.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(60)
		}
        divider2.snp.makeConstraints { (make) in
            make.top.equalTo(closeAccount.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(1)
        }
        linkFacebook.snp.makeConstraints { (make) in
            make.top.equalTo(divider2.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if AccountService.shared.currentUserType == .learner {
			signOut.roundCorners([.topLeft, .topRight], radius: 10)
			linkFacebook.roundCorners([.bottomLeft, .bottomRight], radius: 10)
		} else {
			showMeOnQT.roundCorners([.topLeft, .topRight], radius: 10)
			linkFacebook.roundCorners([.bottomLeft, .bottomRight], radius: 10)
		}
	}
	
	private func setupToggle() {
		showMeOnQT.toggle.isOn = CurrentUser.shared.tutor.isVisible
	}
	
	@objc private func showMeOnQTPressed(_ sender: UISwitch) {
		//to make this more efficient, hold a reference to the variable, and only send it to Firebase when they leave the page.
		showMeOnQT.subtitleLabel.text = sender.isOn ? "You are currently visible in search results." : "You are not currently visible in search results."
		CurrentUser.shared.tutor.isVisible = sender.isOn ? true : false
		FirebaseData.manager.updateTutorVisibility(uid: CurrentUser.shared.learner.uid!, status: sender.isOn ? 0 : 1)
	}
	
	@objc private func signOutPressed(_ sender: UIButton) {
		let alertController = UIAlertController(title: "Are You Sure?", message: "You will be signed out.", preferredStyle: .alert)
		
		let okButton = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
			do {
				try Auth.auth().signOut()
				navigationController.pushViewController(SignInVC(), animated: false)
				navigationController.viewControllers.removeFirst(navigationController.viewControllers.endIndex - 1)
			} catch {
				print("Error signing out")
			}
		}
		
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
		
		alertController.addAction(okButton)
		alertController.addAction(cancelButton)
		
		guard let current = UIApplication.getPresentedViewController() else { return }
		current.present(alertController, animated: true, completion: nil)
	}
	
	@objc private func closeAccountPressed(_ sender: UIButton) {
		navigationController.pushViewController(CloseAccountVC(), animated: true)
	}
    
    @objc private func linkFacebook(_ sender: UIButton) {
        guard let parent = parentViewController else { return }
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: parent) { (result) in
            switch result {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success:
                let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
                Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (authResult, error) in
                    print("Facebook linked")
                })
            }
        }
        
    }

}
