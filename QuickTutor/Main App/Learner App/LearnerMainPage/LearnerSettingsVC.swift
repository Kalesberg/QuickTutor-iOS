//
//  Settings.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import FirebaseAuth
import FirebaseUI
import SDWebImage
import SnapKit
import UIKit

class SettingsItem: BaseView {
    var label = UILabel()
    var divider = UIView()

    override func configureView() {
        addSubview(label)
        addSubview(divider)
        super.configureView()

        label.textColor = .white
        label.numberOfLines = 0

        divider.backgroundColor = Colors.divider
    }

    override func applyConstraints() {
        divider.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
}

class SettingsInteractableItem: SettingsItem, InteractableBackground {
    var backgroundComponent = ViewComponent()

    override func configureView() {
        super.configureView()
        isUserInteractionEnabled = true
        addBackgroundView()
    }
}

class ItemHeader: SettingsItem {
    override func configureView() {
        super.configureView()

        label.font = Fonts.createBoldSize(18)

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func selfConstraint(top: ConstraintItem) {
        snp.makeConstraints { make in
            make.top.equalTo(top)
            make.height.equalTo(60)
            make.width.equalToSuperview()
        }
    }
}

class ArrowItem: SettingsInteractableItem {
    var arrow = UILabel()

    override func configureView() {
        addSubview(arrow)
        super.configureView()

        arrow.font = Fonts.createBoldSize(30)
        arrow.textColor = .white
        arrow.text = "›"

        label.font = Fonts.createSize(15)

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.centerY.equalToSuperview()
        }

        arrow.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(30)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().inset(-4)
        }
    }
}

class CommunityGuidelines: ArrowItem {
    override func configureView() {
        super.configureView()

        label.text = "Community Guidelines"
    }
}

class UserSafety: ArrowItem {
    override func configureView() {
        super.configureView()

        label.text = "User Safety"
    }
}

class RateUs: ArrowItem {
    override func configureView() {
        super.configureView()

        label.text = "Rate Us"
    }
}

class ItemToggle: SettingsItem {
    var toggle = UISwitch()

    override func configureView() {
        addSubview(toggle)
        super.configureView()

        isUserInteractionEnabled = true

        label.font = Fonts.createSize(16)

        toggle.onTintColor = Colors.sidebarPurple

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.centerY.equalToSuperview()
        }

        toggle.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    func selfConstraint(top: ConstraintItem) {
        snp.makeConstraints { make in
            make.top.equalTo(top)
            make.height.equalTo(50)
            make.width.equalToSuperview()
        }
    }
}

class SettingsProfileView: ArrowItem {
    var imageContainer = BaseView()

    var profileImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true

        return imageView
    }()

    override func configureView() {
        addSubview(imageContainer)
        imageContainer.addSubview(profileImageView)
        super.configureView()

        isUserInteractionEnabled = true

        profileImageView.isUserInteractionEnabled = false
        profileImageView.scaleImage()

        label.font = Fonts.createSize(14)

        applyConstraints()
    }

    override func applyConstraints() {
        imageContainer.snp.makeConstraints { make in
            make.top.left.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.27)
        }

        profileImageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(profileImageView.snp.width)
            make.center.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.left.equalTo(imageContainer.snp.right)
            make.height.equalToSuperview().multipliedBy(0.7)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        }

        arrow.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(30)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        divider.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(1.0)
            make.width.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
}

class SocialMediaIcon: InteractableView, Interactable {
    var imageView = UIImageView()

    override func configureView() {
        addSubview(imageView)
        super.configureView()

        imageView.scaleImage()

        applyConstraints()
    }

    override func applyConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(7)
        }
    }

    func touchStart() {
        imageView.alpha = 0.8
        shrink()
    }

    func didDragOff() {
        imageView.alpha = 1.0
        transform = CGAffineTransform.identity
    }

    func touchEndOnStart() {
        growShrink()
    }
}

class TwitterIcon: SocialMediaIcon {
    override func configureView() {
        super.configureView()
        imageView.image = #imageLiteral(resourceName: "social-twitter")
    }
}

class FacebookIcon: SocialMediaIcon {
    override func configureView() {
        super.configureView()
        imageView.image = #imageLiteral(resourceName: "social-facebook")
    }
}

class InstagramIcon: SocialMediaIcon {
    override func configureView() {
        super.configureView()
        imageView.image = #imageLiteral(resourceName: "social-instagram")
    }
}

class FollowUs: SettingsItem {
    var twitterIcon = TwitterIcon()
    var facebookIcon = FacebookIcon()
    var instagramIcon = InstagramIcon()

    override func configureView() {
        addSubview(twitterIcon)
        addSubview(facebookIcon)
        addSubview(instagramIcon)
        super.configureView()
        isUserInteractionEnabled = true

        label.text = "Follow us"

        label.font = Fonts.createSize(16)

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.centerY.equalToSuperview()
        }

        instagramIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(50)
        }

        twitterIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(90)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(50)
        }

        facebookIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(150)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(50)
        }
    }
}

class SignOutButton: ArrowItem {
    override func configureView() {
        super.configureView()

        label.text = "Sign Out"

        applyConstraints()
    }
}

class CloseAccountButton: ArrowItem {
    override func configureView() {
        super.configureView()

        backgroundColor = Colors.qtRed
        label.text = "Close Account"

        applyConstraints()
    }
}

class SettingsScrollView: BaseScrollView {
    private func signOutAlert() {
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
        guard let current = UIApplication.getPresentedViewController() else {
            return
        }
        current.present(alertController, animated: true, completion: nil)
    }

    override func handleNavigation() {
        if touchStartView == nil {
            return
        } else if touchStartView is SettingsProfileView {
            if AccountService.shared.currentUserType == .learner {
                let next = LearnerMyProfileVC()
                next.learner = CurrentUser.shared.learner
                navigationController.pushViewController(next, animated: true)
            } else {
                let next = TutorMyProfileVC()
                next.tutor = CurrentUser.shared.tutor
                navigationController.pushViewController(next, animated: true)
            }
        } else if touchStartView is CommunityGuidelines {
            let next = WebViewVC()
            next.contentView.title.label.text = "Community Guidelines"
            next.url = "https://www.quicktutor.com/community/community-guidelines"
            next.loadAgreementPdf()
            navigationController.pushViewController(next, animated: true)
        } else if touchStartView is UserSafety {
            let next = WebViewVC()
            next.contentView.title.label.text = "User Safety"
            next.url = "https://www.quicktutor.com/community/user-safety"
            next.loadAgreementPdf()
            navigationController.pushViewController(next, animated: true)
        } else if touchStartView is RateUs {
            SocialMedia.rateApp(appUrl: "itms-apps://itunes.apple.com/app/id1388092698", webUrl: "", completion: { _ in
            })
        } else if touchStartView is TwitterIcon {
            SocialMedia.rateApp(appUrl: "twitter://user?screen_name=QuickTutor", webUrl: "https://twitter.com/QuickTutor", completion: { _ in
            })
        } else if touchStartView is InstagramIcon {
            SocialMedia.rateApp(appUrl: "instagram://user?username=QuickTutor", webUrl: "https://www.instagram.com/quicktutor/", completion: { _ in
            })
        } else if touchStartView is FacebookIcon {
            SocialMedia.rateApp(appUrl: "fb://profile/1346980958682540", webUrl: "https://www.facebook.com/QuickTutorApp/", completion: { _ in
            })
        } else if touchStartView is SignOutButton {
            signOutAlert()
        } else if touchStartView is CloseAccountButton {
            navigationController.pushViewController(CloseAccountVC(), animated: true)
        }
    }
}
