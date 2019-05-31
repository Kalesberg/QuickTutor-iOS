//
//  AddTutorTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class AddTutorTableViewCell: UITableViewCell {
	
	let profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = #imageLiteral(resourceName: "registration-image-placeholder")
		imageView.layer.masksToBounds = false
		imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
		return imageView
	}()
	
	let usernameLabel: UILabel = {
		let label = UILabel()
		label.font = Fonts.createBlackSize(14)
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		label.textAlignment = .left
		return label
	}()
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.font = Fonts.createBoldSize(12)
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		label.textAlignment = .left
		return label
	}()
	
	let addTutorButton: DimmableButton = {
		let button = DimmableButton()
		button.backgroundColor = Colors.purple
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.font = Fonts.createBoldSize(12)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 2)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 3
        button.layer.cornerRadius = 4
		return button
	}()
	
	var delegate: AddTutorButtonDelegate?
	var uid: String?
    
    func setupViews() {
        setupBackgroundView()
        setupProfileImageView()
        setupAddTutorButton()
        setupUsernameLabel()
        setupNameLabel()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.left.equalToSuperview().inset(10)
        }
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).inset(-10)
            make.height.equalTo(10)
            make.top.equalTo(usernameLabel.snp.bottom)
            make.right.equalTo(addTutorButton.snp.left)
        }
    }
    
    func setupAddTutorButton() {
        addSubview(addTutorButton)
        addTutorButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        addTutorButton.addTarget(self, action: #selector(addTutorButtonPressed(_:)), for: .touchUpInside)
    }
    
    func setupUsernameLabel() {
        addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).inset(-10)
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.right.equalTo(addTutorButton.snp.left)
        }
    }
    
    func setupBackgroundView() {
        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        selectedBackgroundView = cellBackground
        backgroundColor = Colors.newScreenBackground
    }
	
	@objc func addTutorButtonPressed(_: Any) {
        addTutorButton.isEnabled = false
        guard let uid = self.uid else { return }
        delegate?.addTutorWithUid(uid, completion: {
            self.addTutorButton.isEnabled = true
        })
		
	}
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
}
