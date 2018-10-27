//
//  TutorCardCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import FirebaseUI

class TutorCardCollectionViewCell: UICollectionViewCell {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureCollectionViewCell()
	}
	
	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	var parentViewController : UIViewController?
	
	var tutor: AWTutor! {
		didSet {
			setupTutorCardHeader()
			setupTutorCardAboutMe()
			setupTutorCardBody()
			setupTutorCardSubjects()
			setupTutorCardReviews()
			setupTutorCardPolicy()
			setupScrollViewContentSize()
		}
	}
	
	var delegate: AddTutorButtonDelegate?

	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.alwaysBounceVertical = true
		scrollView.canCancelContentTouches = true
		scrollView.isDirectionalLockEnabled = true
		scrollView.isExclusiveTouch = false
		scrollView.backgroundColor = Colors.navBarColor
		scrollView.layer.cornerRadius = 10
		
		return scrollView
	}()
	
    let tutorCardHeader = TutorCardHeader()
	let tutorCardAboutMe = MyProfileBioView()
	let tutorCardBody = MyProfileBody()
	let tutorCardSubjects = TutorMyProfileSubjects()
	let tutorCardReviews = TutorMyProfileReviewsView(isViewing: true)
	let tutorCardPolicy = TutorMyProfilePolicies()
	
	let connectButton : UIButton = {
		let button = UIButton()
		button.titleLabel?.font = Fonts.createBoldSize(18)
		button.titleLabel?.textColor = .white
		button.backgroundColor = Colors.learnerPurple
		button.layer.cornerRadius = 8
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 0, height: 2)
		button.layer.shadowRadius = 5
		button.layer.shadowOpacity = 0.6
		return button
	}()
	
	let dropShadowView = UIView()
	
    func configureCollectionViewCell() {
		backgroundColor = .clear
		
		addSubview(tutorCardHeader)
		addSubview(dropShadowView)
		addSubview(scrollView)
		scrollView.addSubview(tutorCardAboutMe)
		scrollView.addSubview(tutorCardBody)
		scrollView.addSubview(tutorCardSubjects)
		scrollView.addSubview(tutorCardReviews)
		scrollView.addSubview(tutorCardPolicy)
		addSubview(connectButton)
		
		connectButton.addTarget(self, action: #selector(connectButtonPressed(_:)), for: .touchUpInside)
		applyConstraints()
    }

    func applyConstraints() {
		tutorCardHeader.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
			make.height.equalTo(120)
		}
		dropShadowView.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardHeader.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(1)
		}
		scrollView.snp.makeConstraints { (make) in
			make.top.equalTo(dropShadowView.snp.bottom).inset(5)
			make.width.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
			} else {
				make.bottom.equalToSuperview().inset(40)
			}
		}
		tutorCardAboutMe.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
		}
		tutorCardBody.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardAboutMe.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(tutorCardBody.baseHeight)
		}
		tutorCardSubjects.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardBody.divider.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(80)
		}
		connectButton.snp.makeConstraints { (make) in
			make.centerY.equalTo(scrollView.snp.bottom).inset(5)
			make.centerX.equalToSuperview()
			make.width.equalTo(170)
			make.height.equalTo(35)
		}
    }

    override func layoutSubviews() {
        super.layoutSubviews()
		roundCorners(.allCorners, radius: 10)
		applyDefaultShadow()
        dropShadowView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 1.0, offset: CGSize(width: 0, height: 1), radius: 1)
        dropShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
	private func setupTutorCardHeader() {
		tutorCardHeader.parentViewController = parentViewController
		tutorCardHeader.userId = tutor.uid
		tutorCardHeader.imageCount = tutor.images.filter({$0.value != ""}).count
	}
	private func setupTutorCardAboutMe() {
		tutorCardAboutMe.aboutMeLabel.textColor = Colors.tutorBlue
		tutorCardAboutMe.bioLabel.text = (tutor.tBio != nil) ? tutor.tBio! : "Tutor has no bio!\n"
	}
	
	private func setupTutorCardBody() {
		tutorCardBody.additionalInformation.textColor = Colors.tutorBlue
		let extraInfomationViews = getViewsForExtraInformationSection()
		tutorCardBody.stackView.subviews.forEach({ $0.removeFromSuperview() })
		extraInfomationViews.forEach({ tutorCardBody.stackView.addArrangedSubview($0) })
		
		tutorCardBody.stackView.snp.remakeConstraints { (make) in
			make.top.equalTo(tutorCardBody.additionalInformation.snp.bottom).inset(-5)
			make.leading.equalToSuperview().inset(12)
			make.trailing.equalToSuperview().inset(5)
			make.height.equalTo(CGFloat(extraInfomationViews.count * 30))
		}
		tutorCardBody.snp.remakeConstraints { (make) in
			make.top.equalTo(tutorCardAboutMe.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30 + CGFloat(extraInfomationViews.count * 30))
		}
	}
	
	private func setupTutorCardSubjects() {
		tutorCardSubjects.sectionTitle.textColor = Colors.tutorBlue
		tutorCardSubjects.datasource = tutor.subjects ?? []
	}
	
	private func setupTutorCardReviews() {
		tutorCardReviews.parentViewController = parentViewController
		tutorCardReviews.dataSource = tutor.reviews ?? []
		
		tutorCardReviews.reviewLabel1.removeFromSuperview()
		tutorCardReviews.reviewLabel2.removeFromSuperview()
		tutorCardReviews.backgroundView.removeFromSuperview()
		tutorCardReviews.setupMostRecentReviews()
		
		tutorCardReviews.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardSubjects.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(tutorCardReviews.reviewSectionHeight)
		}
		tutorCardReviews.divider.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview().inset(-5)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().inset(20)
			make.height.equalTo(1)
		}
	}
	
	private func setupTutorCardPolicy() {
		guard let policy = tutor.policy else { return }
		let policies = policy.split(separator: "_")
		
		tutorCardPolicy.policiesLabel.attributedText = NSMutableAttributedString()
			.bold("•  ", 20, .white).regular(tutor.distance.distancePreference(tutor.preference), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(tutor.preference.preferenceNormalization(), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(String(policies[0]).lateNotice(), 16, Colors.grayText)
			.bold("•  ", 20, .white).regular(String(policies[2]).cancelNotice(), 16, Colors.grayText)
			.regular(String(policies[1]).lateFee(), 16, Colors.qtRed)
			.regular(String(policies[3]).cancelFee(), 16, Colors.qtRed)
		
		tutorCardPolicy.snp.makeConstraints { (make) in
			make.top.equalTo(tutorCardReviews.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
		}
	}
	
	private func getViewsForExtraInformationSection() -> [UIView] {
		var views = [UIView]()
		
		views.append(ProfileItem(icon: UIImage(named: "tutored-in")!, title: "Tutored in \(tutor.tNumSessions ?? 0) sessions", color: Colors.tutorBlue))
		//this will be optional in the future but the DB only supports this for now.
		views.append(ProfileItem(icon: UIImage(named: "location")!, title: tutor.region, color: Colors.tutorBlue))
		
		if let languages = tutor.languages {
			views.append(ProfileItem(icon: UIImage(named: "speaks")!, title: "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))", color: Colors.tutorBlue))
		}
		if tutor.school != "" && tutor.school != nil {
			views.append(ProfileItem(icon: UIImage(named: "studys-at")!, title: tutor.school!, color: Colors.tutorBlue))
		}
		return views
	}
	
	private func setupScrollViewContentSize() {
		layoutIfNeeded()
		let connectButtonOffset : CGFloat = 35.0
		scrollView.contentSize.height = scrollView.subviews.reduce(0) { $0 + $1.frame.height } + connectButtonOffset
	}
	
    let addPaymentModal = AddPaymentModal()
    
	@objc private func connectButtonPressed(_ sender: UIButton) {
		sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIView.AnimationOptions.allowUserInteraction, animations: {
			sender.transform = CGAffineTransform.identity
		}, completion: { Void in()  })
		
        guard CurrentUser.shared.learner.hasPayment else {
            addPaymentModal.show()
            return
        }
        
		DataService.shared.getTutorWithId(tutor.uid) { tutor in
			let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
			vc.receiverId = tutor?.uid
			vc.chatPartner = tutor
			navigationController.pushViewController(vc, animated: true)
		}
	}
}

extension TutorCardCollectionViewCell: AddTutorButtonDelegate {
    func addTutorWithUid(_ uid: String, completion: (() -> Void)?) {
        DataService.shared.getTutorWithId(uid) { tutor in
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            vc.receiverId = uid
            vc.chatPartner = tutor
            navigationController.pushViewController(vc, animated: true)
        }
        completion!()
    }
}

class TutorCardHeader: UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	var parentViewController : UIViewController?
	var imageCount : Int = 0
	var userId : String = ""
	
    let distance = TutorDistanceView()

	let profileImageView : UIImageView = {
		let imageView = UIImageView()
		imageView.scaleImage()
		imageView.clipsToBounds = true
		return imageView
	}()
	
    let name: UILabel = {
        var label = UILabel()

        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let reviewLabel: UILabel = {
        let label = UILabel()

        label.textColor = Colors.gold
        label.font = Fonts.createSize(15)
        label.textAlignment = .left

        return label
    }()

    let featuredSubject: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true

        return label
    }()

	let price : UILabel = {
		let label = UILabel()
		
		label.backgroundColor = Colors.green
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(14)
		label.layer.masksToBounds = true
		label.layer.cornerRadius = 10
		
		return label
	}()
	
	let buttonMask : UIButton = {
		let button = UIButton()
		button.backgroundColor = .clear
		return button
	}()
	
	
    let gradientView = UIView()

	func configureView() {
        addSubview(gradientView)
        addSubview(profileImageView)
        addSubview(name)
        addSubview(reviewLabel)
        addSubview(featuredSubject)
		addSubview(price)
		addSubview(buttonMask)

		buttonMask.addTarget(self, action: #selector(profileImageViewPressed), for: .touchUpInside)

		backgroundColor = Colors.navBarColor
		
        applyConstraints()
    }

	func applyConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.width.height.equalTo(90)
            make.bottom.equalToSuperview().inset(15)
        }
        name.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(125)
            make.top.equalTo(profileImageView).inset(5)
            make.right.equalToSuperview().inset(5)
        }
        reviewLabel.snp.makeConstraints { make in
            make.top.equalTo(name.snp.bottom).inset(-5)
            make.left.right.equalTo(name)
        }
        featuredSubject.snp.makeConstraints { make in
            make.top.equalTo(reviewLabel.snp.bottom).inset(-5)
            make.left.equalToSuperview().inset(125)
            make.right.equalToSuperview().inset(5)
        }
		price.snp.makeConstraints { (make) in
			make.top.right.equalToSuperview().inset(12)
			make.width.equalTo(70)
			make.height.equalTo(20)
		}
		buttonMask.snp.makeConstraints { (make) in
			make.edges.equalTo(profileImageView)
		}
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.applyGradient(firstColor: Colors.navBarColor.cgColor, secondColor: UIColor.clear.cgColor, angle: 0, frame: gradientView.bounds)
		profileImageView.roundCorners(.allCorners, radius: 8)

    }
	
	@objc func profileImageViewPressed(_ sender: UIButton) {
		parentViewController?.displayProfileImageViewer(imageCount: imageCount, userId: userId)
	}
}

class TutorDistanceView: BaseView {
    let distance: UILabel = {
        let label = UILabel()

        label.textColor = Colors.tutorBlue
        label.textAlignment = .center
        label.font = Fonts.createSize(12)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    override func configureView() {
        addSubview(distance)
        super.configureView()

        backgroundColor = .white
        layer.cornerRadius = 6
        applyConstraints()
    }

    override func applyConstraints() {
        distance.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

class PriceRating: BaseView {
    let price: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(18)
        label.textColor = .green
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let rating: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(18)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let footer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    override func configureView() {
        addSubview(price)
        addSubview(rating)
        addSubview(footer)
        super.configureView()

        applyConstraints()
    }

    override func applyConstraints() {
        price.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        rating.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        footer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
