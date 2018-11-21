//
//  AddTutorTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class AddTutorTableViewCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configureTableViewCell()
	}
	
	let profileImageView: UIImageView = {
		let imageView = UIImageView()
		
		imageView.image = #imageLiteral(resourceName: "registration-image-placeholder")
		imageView.layer.masksToBounds = false
		imageView.clipsToBounds = true
		return imageView
	}()
	
	let usernameLabel: UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(17)
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		label.textAlignment = .left
		
		return label
	}()
	
	let nameLabel: UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createLightSize(14)
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		label.textAlignment = .left
		
		return label
	}()
	
	let addTutorButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = Colors.learnerPurple
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.font = Fonts.createSize(14)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		
		return button
	}()
	
	var delegate: AddTutorButtonDelegate?
	var uid: String?
	
	func configureTableViewCell() {
		addSubview(profileImageView)
		addSubview(nameLabel)
		addSubview(usernameLabel)
		addSubview(addTutorButton)
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor.black.withAlphaComponent(0.7)
		selectedBackgroundView = cellBackground
		
		backgroundColor = Colors.darkBackground
		addTutorButton.addTarget(self, action: #selector(addTutorButtonPressed(_:)), for: .touchUpInside)
		
		applyConstraints()
	}
	
	func applyConstraints() {
		profileImageView.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.width.equalTo(50)
			make.height.equalTo(50)
			make.left.equalToSuperview().inset(10)
		}
		addTutorButton.snp.makeConstraints { make in
			make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.width.equalTo(100)
			make.height.equalToSuperview().multipliedBy(0.7)
		}
		usernameLabel.snp.makeConstraints { make in
			make.left.equalTo(profileImageView.snp.right).inset(-20)
			make.top.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.right.equalTo(addTutorButton.snp.left)
		}
		nameLabel.snp.makeConstraints { make in
			make.left.equalTo(profileImageView.snp.right).inset(-20)
			make.bottom.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.right.equalTo(addTutorButton.snp.left)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		addTutorButton.layer.cornerRadius = addTutorButton.frame.height / 2
		addTutorButton.layer.shadowColor = UIColor.black.cgColor
		addTutorButton.layer.shadowOffset = CGSize(width: 1, height: 2)
		addTutorButton.layer.shadowOpacity = 0.4
		addTutorButton.layer.shadowRadius = 3
		
		profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
	}
	
	@objc func addTutorButtonPressed(_: Any) {
		addTutorButton.isEnabled = false
		if CurrentUser.shared.learner.hasPayment {
			guard let uid = self.uid else { return }
			delegate?.addTutorWithUid(uid, completion: {
				self.addTutorButton.isEnabled = true
			})
		} else {
			let vc = next?.next?.next as! AddTutorVC
			vc.displayAddPaymentMethod()
		}
	}
}
