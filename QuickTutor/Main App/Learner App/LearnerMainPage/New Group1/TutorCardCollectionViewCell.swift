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

    let distanceExtraLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(12)
        label.textColor = Colors.lightBlue
        label.textAlignment = .center
        
        return label
    }()
    
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
    
    var delegate : AddTutorButtonDelegate?
    
    var datasource : AWTutor! {
        didSet{
            tableView.reloadData()
        }
    }
    
    func configureCollectionViewCell() {
		configureViews()
		configureDelegates()
		
		distanceLabelContainer.isHidden = true
		distanceLabel.numberOfLines  = 0
		
		applyConstraints()
    }
    
    func applyConstraints(){
        header.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(15)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            if UIScreen.main.bounds.height == 480 {
                make.height.equalTo(140)
            } else {
                make.height.equalTo(170)
            }
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
            make.left.equalToSuperview().inset(20)
            make.width.equalTo(rateLabel).inset(-16)
            make.height.equalTo(24)
        }
        distanceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(4)
            make.width.equalToSuperview().inset(2)
            make.centerX.equalToSuperview()
        }
        distanceExtraLabel.snp.makeConstraints { (make) in
            make.top.equalTo(distanceLabel.snp.bottom).inset(5)
            make.width.equalTo(distanceLabel)
            make.centerX.equalToSuperview()
        }
        distanceLabelContainer.snp.makeConstraints { (make) in
            make.top.equalTo(header).inset(-7)
            make.right.equalToSuperview().inset(-7)
            make.width.height.equalTo(56)
        }
        tableViewContainer.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide).inset(23)
            } else {
                make.bottom.equalToSuperview().inset(23)
            }
            make.centerX.equalToSuperview()
        }
        connectButton.snp.makeConstraints { (make) in
            make.width.equalTo(180)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tableViewContainer).inset(-20)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(20)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tableViewContainer.snp.bottom).inset(22)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyDefaultShadow()
        header.roundCorners([.topLeft, .topRight], radius: 22)
        tableViewContainer.roundCorners([.bottomLeft, .bottomRight], radius: 22)
        header.profilePics.applyDefaultShadow()
    }
	private func configureDelegates() {
		tableView.dataSource = self
		tableView.delegate = self
		
		tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
		tableView.register(SubjectsTableViewCell.self, forCellReuseIdentifier: "subjectsTableViewCell")
		tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
		tableView.register(NoRatingsTableViewCell.self, forCellReuseIdentifier: "noRatingsTableViewCell")
		tableView.register(PoliciesTableViewCell.self, forCellReuseIdentifier: "policiesTableViewCell")
		tableView.register(ExtraInfoCardTableViewCell.self, forCellReuseIdentifier: "extraInfoCardTableViewCell")
	}
	private func configureViews() {
		addSubview(header)
		addSubview(tableViewContainer)
		tableViewContainer.addSubview(tableView)
		addSubview(reviewLabelContainer)
		reviewLabelContainer.addSubview(reviewLabel)
		addSubview(rateLabelContainer)
		rateLabelContainer.addSubview(rateLabel)
		addSubview(distanceLabelContainer)
		distanceLabelContainer.addSubview(distanceLabel)
		distanceLabelContainer.addSubview(distanceExtraLabel)
		addSubview(connectButton)
		
		tableViewContainer.backgroundColor = UIColor(hex: "1B1B26")

		reviewLabelContainer.backgroundColor = Colors.yellow
		reviewLabelContainer.layer.cornerRadius = 12
		
		rateLabelContainer.backgroundColor = Colors.green
		rateLabelContainer.layer.cornerRadius = 12
		
		distanceLabelContainer.backgroundColor = .white
		distanceLabelContainer.layer.cornerRadius = 28
	
	}
    override func handleNavigation() {
        if touchStartView is ConnectButton {
            if CurrentUser.shared.learner.hasPayment {
                self.addTutorWithUid(datasource.uid)
            } else {
                let view = (next?.next?.next as! TutorConnect).contentView
                view.addPaymentModal.isHidden = false
            }

        } else if touchStartView is FullProfile {
            if let current = UIApplication.getPresentedViewController() {
                current.present(ViewFullProfile(), animated: true, completion: nil)
            }
        } else if touchStartView is TutorCardProfilePic {
            let vc = (next?.next?.next as! TutorConnect)
			FirebaseData.manager.getProfileImagesFor(uid: datasource.uid) { (imageUrls) in
				if let imageUrls = imageUrls {
					vc.setUpImages(images: imageUrls)
				}
			}
            vc.contentView.backgroundView.isHidden = false
            vc.horizontalScrollView.isHidden = false
            vc.horizontalScrollView.isUserInteractionEnabled = true
		}
    }
}

extension TutorCardCollectionViewCell : AddTutorButtonDelegate {
    func addTutorWithUid(_ uid: String) {
        
        DataService.shared.getTutorWithId(uid) { (tutor) in
            
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            
            vc.receiverId = uid
            vc.chatPartner = tutor
            vc.shouldSetupForConnectionRequest = true
            vc.tutor = self.datasource
            
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
extension TutorCardCollectionViewCell : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.item {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
            
            if let bio = datasource?.tBio {
                cell.bioLabel.text = bio + "\n"
            } else {
                cell.bioLabel.text = "Learner has no bio!\n"
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "extraInfoCardTableViewCell", for: indexPath) as! ExtraInfoCardTableViewCell
            
            for view in cell.contentView.subviews {
                view.snp.removeConstraints()
            }

            cell.speakItem.removeFromSuperview()
            cell.studysItem.removeFromSuperview()
            
            cell.locationItem.label.text = datasource?.region
            
            cell.locationItem.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(12)
                make.right.equalToSuperview().inset(20)
                make.height.equalTo(35)
                make.top.equalToSuperview().inset(10)
            }
            
            cell.tutorItem.label.text = "Has tutored \(datasource?.tNumSessions! ?? 0) sessions"
            
            if let languages = datasource?.languages {
                cell.speakItem.label.text = "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"
                cell.contentView.addSubview(cell.speakItem)
                
                cell.tutorItem.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().inset(12)
                    make.right.equalToSuperview().inset(20)
                    make.height.equalTo(35)
                    make.top.equalTo(cell.locationItem.snp.bottom)
                }
                
                if datasource?.school != ""  {
                    cell.studysItem.label.text = datasource.school
                    cell.contentView.addSubview(cell.studysItem)
                    
                    cell.speakItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                    }
                    
                    cell.studysItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.speakItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                } else {
                    cell.speakItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                }
            } else {
                if datasource?.school != "" {
                    cell.studysItem.label.text = datasource.school
                    cell.contentView.addSubview(cell.studysItem)
                    
                    cell.tutorItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.locationItem.snp.bottom)
                    }
                    
                    cell.studysItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                } else {
                    cell.tutorItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.locationItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                }
            }
            
            cell.applyConstraints()
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
            cell.datasource = datasource?.subjects
            return cell
        case 3:
            
            guard let datasource = datasource?.reviews else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as! NoRatingsTableViewCell
                return cell
            }
            
            if datasource.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as! NoRatingsTableViewCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as! RatingTableViewCell
            
            cell.seeAllButton.isHidden = !(datasource.count > 2)
            cell.datasource = datasource
            
            return cell

        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "policiesTableViewCell", for: indexPath) as! PoliciesTableViewCell
            
            if let policy = datasource?.policy {
                let policies = policy.split(separator: "_")
                
                let formattedString = NSMutableAttributedString()
                
                formattedString
                    .regular(datasource.distance.distancePreference(datasource.preference), 14, .white)
                    .regular(datasource.preference.preferenceNormalization(), 14, .white)
                    .regular(String(policies[2]).cancelNotice(), 14, .white)
                    .regular(String(policies[0]).lateNotice(), 14, .white)
                    .regular(String(policies[1]).lateFee(), 13, Colors.qtRed)
                    .regular(String(policies[3]).cancelFee(), 13, Colors.qtRed)
                
                cell.policiesLabel.attributedText = formattedString
            } else {
                // show "No Policies cell"
            }
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
            return UITableViewAutomaticDimension
        case 2:
            return 90
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
}

class TutorCardProfilePic : UIImageView, Interactable {
    
}

class TutorCardHeader : InteractableView {
    
    let distance = TutorDistanceView()
    
    var profilePics : TutorCardProfilePic = {
        let view = TutorCardProfilePic()
        
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    var name : UILabel = {
        var label = UILabel()
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(20)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    override func configureView() {
        addSubview(profilePics)
        addSubview(name)
        super.configureView()
        
        backgroundColor = Colors.tutorBlue
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        profilePics.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            if UIScreen.main.bounds.height == 480 {
                make.height.width.equalTo(85)
            } else {
                make.height.width.equalTo(110)
            }
            
        }
        name.snp.makeConstraints { (make) in
            make.top.equalTo(profilePics.snp.bottom)
            make.bottom.equalToSuperview().inset(5)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
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

//class TutorCardBody : InteractableView {
//
//    let priceRating = PriceRating()
//    let aboutMe = AboutMeView()
//
//    override func configureView() {
//        addSubview(priceRating)
//        addSubview(aboutMe)
//
//        super.configureView()
//        aboutMe.aboutMeLabel.label.text = "About Alex"
//
//        backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
//
//        applyConstraints()
//    }
//
//    override func applyConstraints() {
//        priceRating.snp.makeConstraints { (make) in
//            make.top.equalToSuperview()
//            make.centerX.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.15)
//            make.width.equalToSuperview()
//        }
//        aboutMe.snp.makeConstraints { (make) in
//            make.top.equalTo(priceRating.snp.bottom)
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.25)
//        }
//    }
//}


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
        
        //imageView.image = LocalImageCache.localImageManager.getImage(number: "1")
        
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
        label.text = "Connect"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    override func configureView() {
        addSubview(connect)
        super.configureView()
        
        backgroundColor = Colors.learnerPurple
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        
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

