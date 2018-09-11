//
//  ReceiptCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

//class PersonalProgressView : UIView {
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    override init(frame: CGRect) {
//        super.init(frame: .zero)
//        configureView()
//    }
//
//    let title : UILabel = {
//        let label = UILabel()
//
//        label.text = "Personal Progress"
//        label.textColor = Colors.learnerPurple
//        label.textAlignment = .right
//        label.font = Fonts.createSize(15)
//        label.sizeToFit()
//
//        return label
//    }()
//
//    let totalSessions : UILabel = {
//        let label = UILabel()
//
//        label.text = "Text"
//        label.textColor = Colors.learnerPurple
//        label.textAlignment = .right
//        label.font = Fonts.createSize(15)
//        label.sizeToFit()
//
//        return label
//    }()
//
//    let totalSessionsWithTutor : UILabel = {
//        let label = UILabel()
//
//        label.text = "Text"
//        label.textColor = Colors.learnerPurple
//        label.textAlignment = .right
//        label.font = Fonts.createSize(15)
//        label.sizeToFit()
//
//        return label
//    }()
//
//    func configureView() {
//        addSubview(title)
//        addSubview(totalSessions)
//        addSubview(totalSessionsWithTutor)
//
//        backgroundColor = .red
//        applyConstraints()
//    }
//    func applyConstraints() {
//        title.snp.makeConstraints { (make) in
//            make.top.left.equalToSuperview().inset(10)
//        }
//        totalSessions.snp.makeConstraints { (make) in
//            make.top.equalTo(title.snp.bottom)
//            make.width.equalToSuperview()
//            make.height.equalTo(20)
//        }
//        totalSessionsWithTutor.snp.makeConstraints { (make) in
//            make.top.equalTo(totalSessions.snp.bottom)
//            make.width.equalToSuperview()
//            make.height.equalTo(20)
//        }
//    }
//}

class SessionReceiptItemWithImage : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = Colors.learnerPurple
		label.textAlignment = .right
		label.font = Fonts.createSize(14)
		label.sizeToFit()
		
		return label
	}()
	
	let infoLabel : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
    let profileImageView : UIImageView = {
        let view = UIImageView()
        
        view.backgroundColor = .red
        view.layer.cornerRadius = 7
        
        return view
    }()

	func configureView() {
		addSubview(title)
		addSubview(infoLabel)
		addSubview(profileImageView)
    
		applyConstraints()
	}
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.left.centerY.equalToSuperview()
            make.width.equalTo(100)
		}
		profileImageView.snp.makeConstraints { (make) in
			make.width.height.equalTo(30)
			make.centerY.equalToSuperview()
			make.left.equalTo(title.snp.right).inset(-13)
		}
		infoLabel.snp.makeConstraints { (make) in
			make.left.equalTo(profileImageView.snp.right).inset(-8)
			make.centerY.equalToSuperview()
            make.width.equalTo(100)
		}
	}
}
class SessionReceiptItem : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = Colors.learnerPurple
		label.textAlignment = .right
		label.font = Fonts.createSize(14)
		label.sizeToFit()
		
		return label
	}()
	
	let infoLabel : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	func configureView() {
		addSubview(title)
		addSubview(infoLabel)
		
		applyConstraints()
	}
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.left.centerY.equalToSuperview()
            make.width.equalTo(100)
		}
		infoLabel.snp.makeConstraints { (make) in
			make.left.equalTo(title.snp.right).inset(-13)
			make.centerY.equalToSuperview()
		}
	}
}

class ReceiptCell : UICollectionViewCell {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureCollectionViewCell()
	}
	
	let containerView : UIView = {
		let view = UIView()
		view.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
		return view
	}()
	
	let sessionSummaryContainer : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.navBarColor
        //view.layer.cornerRadius = 8
		return view
	}()
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Your Receipt"
		label.textColor = .white
		label.font = Fonts.createBoldSize(18)
		label.textAlignment = .center
		
		return label
	}()
	
	let subtitle : UILabel = {
		let label = UILabel()
		
		label.text = "Session Summary"
		label.textColor = .white
		label.font = Fonts.createBoldSize(17)
		label.textAlignment = .left
		
		return label
	}()
	
	let infoContainer = UIView()
	let partner = SessionReceiptItemWithImage()
	var subject = SessionReceiptItem()
	var sessionLength = SessionReceiptItem()
	var hourlyRate = SessionReceiptItem()
	var tip = SessionReceiptItem()
	var total = SessionReceiptItem()
    
    let lineView : UIView = {
        let view = UIView()
        
        view.backgroundColor = .black
        
        return view
    }()
	
    let progressLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Personal Progress"
        label.textColor = .white
        label.textAlignment = .right
        label.font = Fonts.createBoldSize(17)
        label.sizeToFit()
        
        return label
    }()
    
    let totalSessions : UILabel = {
        let label = UILabel()
        
        label.text = "Text"
        label.textColor = Colors.learnerPurple
        label.font = Fonts.createSize(14)
        label.sizeToFit()
        
        return label
    }()
    
    let totalSessionsWithTutor : UILabel = {
        let label = UILabel()
        
        label.text = "Text"
        label.textColor = Colors.learnerPurple
        label.font = Fonts.createSize(14)
        label.sizeToFit()
        
        return label
    }()
	
    let progressView = UIView()
	
	func configureCollectionViewCell() {
        setLabelText()
		addSubview(containerView)
		containerView.addSubview(title)
		containerView.addSubview(sessionSummaryContainer)
		sessionSummaryContainer.addSubview(subtitle)
		sessionSummaryContainer.addSubview(infoContainer)
		infoContainer.addSubview(partner)
        infoContainer.addSubview(subject)
        infoContainer.addSubview(sessionLength)
        infoContainer.addSubview(hourlyRate)
        infoContainer.addSubview(tip)
        infoContainer.addSubview(total)
        infoContainer.addSubview(lineView)
        //infoContainer.addSubview(progressLabel)
        infoContainer.addSubview(progressView)
        progressView.addSubview(totalSessions)
        progressView.addSubview(totalSessionsWithTutor)
		
		applyConstraints()
	}
    
    func setLabelText() {
        partner.title.text = "Tutor"
        subject.title.text = "Subject"
        sessionLength.title.text = "Session Length"
        hourlyRate.title.text = "Hourly Rate"
        tip.title.text = "Tip"
        total.title.text = "Total"
        
        totalSessions.text = "Total Sessions Completed:"
        totalSessionsWithTutor.text = "Total Sessions Completed with: Name"
    }

	func applyConstraints() {
		containerView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
            make.top.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.95)
			make.height.equalTo(330)
		}
		title.snp.makeConstraints { (make) in
			make.top.centerX.width.equalToSuperview()
			make.height.equalTo(35)
		}
		sessionSummaryContainer.snp.makeConstraints { (make) in
			make.top.equalTo(title.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalToSuperview()
		}
		subtitle.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(20)
			make.width.equalToSuperview()
            make.height.equalTo(50)
		}
		infoContainer.snp.makeConstraints { (make) in
			make.top.equalTo(subtitle.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		partner.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
			make.height.equalTo(35)
		}
        subject.snp.makeConstraints { (make) in
            make.top.equalTo(partner.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(27)
        }
        sessionLength.snp.makeConstraints { (make) in
            make.top.equalTo(subject.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(27)
        }
        hourlyRate.snp.makeConstraints { (make) in
            make.top.equalTo(sessionLength.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(27)
        }
        tip.snp.makeConstraints { (make) in
            make.top.equalTo(hourlyRate.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(27)
        }
        total.snp.makeConstraints { (make) in
            make.top.equalTo(tip.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(27)
        }
        lineView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.height.equalTo(2)
            make.top.equalTo(total.snp.bottom).inset(-15)
        }
//        progressLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(lineView.snp.bottom).inset(-15)
//            make.left.equalToSuperview().inset(20)
//        }
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.width.centerX.equalToSuperview()
        }
        totalSessions.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview().multipliedBy(0.35)
        }
        totalSessionsWithTutor.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.85)
            make.left.equalToSuperview().inset(20)
        }
	}
}
