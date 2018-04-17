//
//  TutorCardCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import SnapKit

class TutorCardCollectionViewCell : BaseCollectionViewCell {
	
	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureCollectionViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let header = TutorCardHeader()
    let reviewLabel : UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = UIColor.init(hex: "AA9022")
        label.font = Fonts.createBoldSize(15)
        
        return label
    }()
    let reviewLabelContainer = UIView()
    let rateLabel : UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBoldSize(15)
        
        return label
    }()
    
    let rateLabelContainer = UIView()
    let distanceLabel = UILabel()
    let distanceLabelContainer = UIView()
	let connectButton = ConnectButton()
    let tableViewContainer = UIView()
    
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.rowHeight = 55
		tableView.showsVerticalScrollIndicator = false
		tableView.allowsSelection = false
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		tableView.delaysContentTouches = false
        tableView.allowsSelection = false
		
		return tableView
	}()
	
	func configureCollectionViewCell() {
		addSubview(header)
        addSubview(tableViewContainer)
		tableViewContainer.addSubview(tableView)
        addSubview(reviewLabelContainer)
        reviewLabelContainer.addSubview(reviewLabel)
        addSubview(rateLabelContainer)
        rateLabelContainer.addSubview(rateLabel)
        addSubview(distanceLabelContainer)
        distanceLabelContainer.addSubview(distanceLabel)
        addSubview(connectButton)
        
        tableViewContainer.backgroundColor = UIColor(hex: "1B1B26")
        
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
        tableView.register(SubjectsTableViewCell.self, forCellReuseIdentifier: "subjectsTableViewCell")
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
        tableView.register(PoliciesTableViewCell.self, forCellReuseIdentifier: "policiesTableViewCell")
        
        reviewLabelContainer.backgroundColor = Colors.yellow
        reviewLabelContainer.layer.cornerRadius = 12
        
        rateLabelContainer.backgroundColor = Colors.green
        rateLabelContainer.layer.cornerRadius = 12
        
        distanceLabelContainer.backgroundColor = .white
        distanceLabelContainer.layer.cornerRadius = 28
		
		applyConstraints()
	}
	
	func applyConstraints(){
		header.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(150)
		}
        reviewLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        reviewLabelContainer.snp.makeConstraints { (make) in
            make.bottom.equalTo(header).inset(-13)
            make.right.equalToSuperview().inset(8)
            make.width.equalTo(reviewLabel).inset(-12)
            make.height.equalTo(24)
        }
        rateLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        rateLabelContainer.snp.makeConstraints { (make) in
            make.bottom.equalTo(header).inset(-13)
            make.centerX.equalTo(header.imageView)
            make.width.equalTo(rateLabel).inset(-16)
            make.height.equalTo(24)
        }
        distanceLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(1)
        }
        distanceLabelContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(-7)
            make.right.equalToSuperview().inset(-7)
            make.width.height.equalTo(56)
        }
        tableViewContainer.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
        }
        connectButton.snp.makeConstraints { (make) in
            make.width.equalTo(180)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tableViewContainer).inset(7)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(20)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(connectButton.snp.top).inset(-5)
        }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
        
        applyDefaultShadow()
		
		header.roundCorners([.topLeft, .topRight], radius: 22)
		
		tableViewContainer.roundCorners([.bottomLeft, .bottomRight], radius: 22)
		
		header.imageView.applyDefaultShadow()
	}
	override func handleNavigation() {
		if touchStartView is ConnectButton {
		} else if touchStartView is FullProfile {
			if let current = UIApplication.getPresentedViewController() {
				current.present(ViewFullProfile(), animated: true, completion: nil)
			}
		}
	}
}
extension TutorCardCollectionViewCell : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.item {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as!
                RatingTableViewCell
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "policiesTableViewCell", for: indexPath) as! PoliciesTableViewCell
            return cell
        default:
            return UITableViewCell()
        }
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return 90
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
}

class TutorCardHeader : InteractableView {
	
	let distance = TutorDistanceView()
	
	 var imageView : UIImageView = {
		var imageView = UIImageView()
		
		//imageView.image = #imageLiteral(resourceName: "registration-image-placeholder")
        imageView.scaleImage()
		
		return imageView
	}()
	
	var name : UILabel = {
		var label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(20)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	var region : UILabel = {
		var label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createSize(16)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	var tutorData : UILabel = {
		var label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createSize(16)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
    
    let locationItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = #imageLiteral(resourceName: "location")
        
        return item
    }()
    
    let speakItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = #imageLiteral(resourceName: "speaks")
        
        return item
    }()
    
    let studysItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = UIImage(named: "studys-at")
        
        return item
    }()
    
    let tutorItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = UIImage(named: "tutored-in")
        
        return item
    }()
    
    let container = UIView()

	override func configureView() {
		addSubview(imageView)
        addSubview(name)
        addSubview(container)
        container.addSubview(locationItem)
        container.addSubview(tutorItem)
        container.addSubview(speakItem)
        container.addSubview(studysItem)
		super.configureView()
		
		backgroundColor = Colors.tutorBlue
        
		applyConstraints()
	}
	
	override func applyConstraints() {
		imageView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.7)
			make.width.equalToSuperview().multipliedBy(0.3)
		}
        name.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.top.equalTo(imageView.snp.top)
            make.right.equalToSuperview().inset(3)
        }
        container.snp.makeConstraints { (make) in
            make.top.equalTo(name.snp.bottom)
            make.left.equalTo(name).inset(-4)
            make.right.equalTo(name)
            make.bottom.equalToSuperview().inset(10)
        }
        locationItem.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        tutorItem.snp.makeConstraints { (make) in
            make.top.equalTo(locationItem.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        speakItem.snp.makeConstraints { (make) in
            make.top.equalTo(tutorItem.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        studysItem.snp.makeConstraints { (make) in
            make.top.equalTo(speakItem.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
//        region.snp.makeConstraints { (make) in
//            make.left.equalTo(imageView.snp.right).multipliedBy(1.1)
//            make.centerY.equalToSuperview()
//            make.height.equalTo(25)
//            make.width.equalToSuperview().multipliedBy(0.4)
//        }
//        tutorData.snp.makeConstraints { (make) in
//            make.left.equalTo(imageView.snp.right).multipliedBy(1.1)
//            make.top.equalTo(region.snp.bottom)
//            make.height.equalTo(25)
//            make.width.equalToSuperview()
//        }
//        distance.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().inset(10)
//            make.right.equalToSuperview().inset(30)
//            make.height.equalTo(30)
//            make.width.equalTo(70)
//        }
	}
}

class TutorDistanceView : BaseView {
	
	let distance : UILabel = {
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
		distance.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.height.equalToSuperview()
			make.width.equalToSuperview()
		}
	}
}

class TutorCardBody : InteractableView {
	
	let priceRating = PriceRating()
	let aboutMe = AboutMeView()
	
	override func configureView() {
		addSubview(priceRating)
		addSubview(aboutMe)
		
		super.configureView()
		aboutMe.aboutMeLabel.label.text = "About Alex"
		
		backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		priceRating.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.15)
			make.width.equalToSuperview()
		}
		aboutMe.snp.makeConstraints { (make) in
			make.top.equalTo(priceRating.snp.bottom)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.25)
		}
	}
}

class TutorCardReviewCell : UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let profilePic : UIImageView  = {
		let imageView = UIImageView()
		
		imageView.image = LocalImageCache.localImageManager.getImage(number: "1")
		
		return imageView
	}()
	
	let nameLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createBoldSize(18)

		return label
	}()
	
	let reviewTextLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.grayText
		label.font = Fonts.createItalicSize(13)
		label.numberOfLines = 3
		label.lineBreakMode = .byWordWrapping
		
		return label
	}()
	
	func configureTableViewCell() {
		addSubview(profilePic)
		addSubview(nameLabel)
		addSubview(reviewTextLabel)
		
		
		backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		profilePic.scaleImage()

		applyConstraints()
	}
	
	func applyConstraints() {
		
		profilePic.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(10)
			make.centerY.equalToSuperview()
			make.height.equalTo(49)
			make.width.equalTo(49)
		}
		
		nameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(profilePic.snp.right).inset(-10)
			make.centerY.equalToSuperview().multipliedBy(0.6)
		}
		
		reviewTextLabel.snp.makeConstraints { (make) in
			make.left.equalTo(profilePic.snp.right).inset(-10)
			make.centerY.equalToSuperview().multipliedBy(1.4)
			make.right.equalToSuperview()
		}
	}
}

class PriceRating : BaseView {
	
	let price : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(18)
		label.textColor = .green
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let rating : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(18)
		label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let footer : UIView = {
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
		price.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalToSuperview()
			make.width.equalToSuperview().dividedBy(3)
		}
		rating.snp.makeConstraints { (make) in
			make.height.equalToSuperview()
			make.width.equalToSuperview().dividedBy(3)
			make.right.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		footer.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.height.equalTo(1)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}
class ConnectButton : InteractableView, Interactable {
	
	let connect : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(18)
		label.textColor = .white
		label.text = "Connect!"
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	override func configureView() {
		addSubview(connect)
		super.configureView()
        
		backgroundColor = Colors.green
        layer.cornerRadius = 8
        
		applyConstraints()
	}
	
	override func applyConstraints() {
		connect.snp.makeConstraints { (make) in
			make.height.equalToSuperview()
			make.width.equalToSuperview()
			make.center.equalToSuperview()
		}
	}
	func touchStart() {
		alpha = 0.6
	}
    func didDragOff() {
		alpha = 1.0
	}
}
class FullProfile : InteractableView, Interactable {
	
	let connect : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(18)
		label.textColor = .white
		label.text = "View Full Profile"
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	override func configureView() {
		addSubview(connect)
		super.configureView()
		backgroundColor = .green
		applyConstraints()
	}
	
	override func applyConstraints() {
		connect.snp.makeConstraints { (make) in
			make.height.equalToSuperview()
			make.width.equalToSuperview()
			make.center.equalToSuperview()
		}
	}
}
extension UIView {
	func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
	
		mask.path = path.cgPath
		
		self.layer.mask = mask
	}
}
