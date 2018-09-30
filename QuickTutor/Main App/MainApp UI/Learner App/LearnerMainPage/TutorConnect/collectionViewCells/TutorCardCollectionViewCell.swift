//
import SnapKit
//  TutorCardCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit

class TutorCardCollectionViewCell: BaseCollectionViewCell {
    required override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureCollectionViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let header = TutorCardHeader()

    let reviewLabel: UILabel = {
        let label = UILabel()

        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBoldSize(15)

        return label
    }()

    let reviewLabelContainer = UIView()

    let rateLabel: UILabel = {
        let label = UILabel()

        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBoldSize(15)

        return label
    }()

    let rateLabelContainer = UIView()
    let connectButton = ConnectButton()
    let tableViewContainer = UIView()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 55
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delaysContentTouches = false
        tableView.allowsSelection = false
        return tableView
    }()

    let dropShadowView = UIView()

    var delegate: AddTutorButtonDelegate?

    var datasource: AWTutor! {
        didSet {
            tableView.reloadData()
        }
    }

    func configureCollectionViewCell() {
        configureViews()
        configureDelegates()

        applyConstraints()
    }

    func applyConstraints() {
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(135)
        }

        rateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        rateLabelContainer.snp.makeConstraints { make in
            make.top.equalTo(header).inset(-13)
            make.left.equalToSuperview().inset(-5)
            make.width.equalTo(rateLabel).inset(-16)
            make.height.equalTo(24)
        }
        tableViewContainer.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide).inset(23)
            } else {
                make.bottom.equalToSuperview().inset(23)
            }
            make.centerX.equalToSuperview()
        }
        connectButton.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tableViewContainer).inset(-20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tableViewContainer.snp.bottom).inset(22)
        }

        dropShadowView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview().inset(1)
            make.centerX.equalToSuperview()
            make.height.equalTo(2)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyDefaultShadow()
        header.roundCorners([.topLeft, .topRight], radius: 10)
        tableViewContainer.roundCorners([.bottomLeft, .bottomRight], radius: 10)
        dropShadowView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 1.0, offset: CGSize(width: 0, height: 1), radius: 1)
        dropShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }

    private func configureDelegates() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
        tableView.register(SubjectsTableViewCell.self, forCellReuseIdentifier: "subjectsTableViewCell")
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
        //tableView.register(NoRatingsTableViewCell.self, forCellReuseIdentifier: "noRatingsTableViewCell")
        tableView.register(PoliciesTableViewCell.self, forCellReuseIdentifier: "policiesTableViewCell")
        tableView.register(ExtraInfoCardTableViewCell.self, forCellReuseIdentifier: "extraInfoCardTableViewCell")
    }

    private func configureViews() {
        addSubview(header)
        addSubview(tableViewContainer)
        tableViewContainer.addSubview(tableView)
        addSubview(dropShadowView)
        addSubview(reviewLabelContainer)
        reviewLabelContainer.addSubview(reviewLabel)
        addSubview(rateLabelContainer)
        rateLabelContainer.addSubview(rateLabel)
        addSubview(connectButton)

        tableViewContainer.backgroundColor = Colors.registrationDark

        reviewLabelContainer.backgroundColor = Colors.gold
        reviewLabelContainer.layer.cornerRadius = 12

        rateLabelContainer.backgroundColor = Colors.green
        rateLabelContainer.layer.cornerRadius = 12

        layoutIfNeeded()
    }

    override func handleNavigation() {
        if touchStartView is ConnectButton {
            if CurrentUser.shared.learner.hasPayment {
                addTutorWithUid(datasource.uid) {
                    // TODO: Add functionality once callback returns.
                }
            } else {
                let vc = next?.next?.next as! TutorConnectVC
                vc.displayAddPaymentMethod()
            }
        } else if touchStartView is FullProfile {
            if let current = UIApplication.getPresentedViewController() {
                current.present(ViewFullProfileVC(), animated: true, completion: nil)
            }
        } else if touchStartView is TutorCardProfilePic {
            let vc = (next?.next?.next as! TutorConnectVC)
            vc.displayProfileImageViewer(imageCount: datasource.images.filter({ $0.value != "" }).count, userId: datasource.uid)
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

extension TutorCardCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch indexPath.item {
//        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
//
//            if let bio = datasource?.tBio {
//                cell.bioLabel.text = bio + "\n"
//            } else {
//                cell.bioLabel.text = "Tutor has no bio!\n"
//            }
//
//            return cell
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "extraInfoCardTableViewCell", for: indexPath) as! ExtraInfoCardTableViewCell
//
//            for view in cell.contentView.subviews {
//                view.snp.removeConstraints()
//            }
//
//            cell.speakItem.removeFromSuperview()
//            cell.studysItem.removeFromSuperview()
//            cell.locationItem.label.text = datasource?.region
//            cell.locationItem.snp.makeConstraints { make in
//                make.left.equalToSuperview().inset(12)
//                make.right.equalToSuperview().inset(20)
//                make.height.equalTo(35)
//                make.top.equalTo(cell.label.snp.bottom).inset(-6)
//            }
//
//            cell.tutorItem.label.text = "Has tutored \(datasource?.tNumSessions ?? 0) sessions"
//
//            if let languages = datasource?.languages {
//                cell.speakItem.label.text = "Speaks: \(languages.compactMap({ $0 }).joined(separator: ", "))"
//                cell.contentView.addSubview(cell.speakItem)
//
//                cell.tutorItem.snp.makeConstraints { make in
//                    make.left.equalToSuperview().inset(12)
//                    make.right.equalToSuperview().inset(20)
//                    make.height.equalTo(35)
//                    make.top.equalTo(cell.locationItem.snp.bottom)
//                }
//
//                if datasource.school != "" && datasource.school != nil {
//                    cell.studysItem.label.text = datasource.school
//                    cell.contentView.addSubview(cell.studysItem)
//
//                    cell.speakItem.snp.makeConstraints { make in
//                        make.left.equalToSuperview().inset(12)
//                        make.right.equalToSuperview().inset(20)
//                        make.height.equalTo(35)
//                        make.top.equalTo(cell.tutorItem.snp.bottom)
//                    }
//
//                    cell.studysItem.snp.makeConstraints { make in
//                        make.left.equalToSuperview().inset(12)
//                        make.right.equalToSuperview().inset(20)
//                        make.height.equalTo(35)
//                        make.top.equalTo(cell.speakItem.snp.bottom)
//                        make.bottom.equalToSuperview().inset(10)
//                    }
//                } else {
//                    cell.speakItem.snp.makeConstraints { make in
//                        make.left.equalToSuperview().inset(12)
//                        make.right.equalToSuperview().inset(20)
//                        make.height.equalTo(35)
//                        make.top.equalTo(cell.tutorItem.snp.bottom)
//                        make.bottom.equalToSuperview().inset(10)
//                    }
//                }
//            } else {
//                if datasource.school != "" && datasource.school != nil {
//                    cell.studysItem.label.text = datasource.school
//                    cell.contentView.addSubview(cell.studysItem)
//                    cell.tutorItem.snp.makeConstraints { make in
//                        make.left.equalToSuperview().inset(12)
//                        make.right.equalToSuperview().inset(20)
//                        make.height.equalTo(35)
//                        make.top.equalTo(cell.locationItem.snp.bottom)
//                    }
//
//                    cell.studysItem.snp.makeConstraints { make in
//                        make.left.equalToSuperview().inset(12)
//                        make.right.equalToSuperview().inset(20)
//                        make.height.equalTo(35)
//                        make.top.equalTo(cell.tutorItem.snp.bottom)
//                        make.bottom.equalToSuperview().inset(10)
//                    }
//                } else {
//                    cell.tutorItem.snp.makeConstraints { make in
//                        make.left.equalToSuperview().inset(12)
//                        make.right.equalToSuperview().inset(20)
//                        make.height.equalTo(35)
//                        make.top.equalTo(cell.locationItem.snp.bottom)
//                        make.bottom.equalToSuperview().inset(10)
//                    }
//                }
//            }
//
//            cell.applyConstraints()

            return cell

//        case 2:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
//            guard let datasource = datasource?.subjects else { return cell }
//
//            cell.datasource = datasource
//            return cell
//        case 3:
//
//            guard let datasource = datasource?.reviews, datasource.count != 0 else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as! NoRatingsTableViewCell
//                cell.isViewing = true
//                return cell
//            }
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as! RatingTableViewCell
//
//            if datasource.count == 1 {
//                cell.tableView.snp.remakeConstraints { make in
//                    make.top.equalToSuperview()
//                    make.width.equalToSuperview().multipliedBy(0.95)
//                    make.height.equalTo(120)
//                    make.centerX.equalToSuperview()
//                }
//            }
//            cell.isViewing = true
//            cell.datasource = datasource.sorted(by: { $0.date > $1.date })
//
//            return cell
//
//        case 4:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "policiesTableViewCell", for: indexPath) as! PoliciesTableViewCell
//
//            if let policy = datasource?.policy {
//                let policies = policy.split(separator: "_")
//
//                let formattedString = NSMutableAttributedString()
//
//                formattedString
//                    .bold("•  ", 20, .white)
//                    .regular(datasource.distance.distancePreference(datasource.preference), 16, Colors.grayText)
//                    .bold("•  ", 20, .white)
//                    .regular(datasource.preference.preferenceNormalization(), 16, Colors.grayText)
//                    .bold("•  ", 20, .white)
//                    .regular(String(policies[0]).lateNotice(), 16, Colors.grayText)
//                    .bold("•  ", 20, .white)
//                    .regular(String(policies[2]).cancelNotice(), 16, Colors.grayText)
//                    .regular(String(policies[1]).lateFee(), 16, Colors.qtRed)
//                    .regular(String(policies[3]).cancelFee(), 16, Colors.qtRed)
//
//                cell.policiesLabel.attributedText = formattedString
//            } else {
//                // show "No Policies cell"
//            }
//            return cell
//        default:
//            return UITableViewCell()
//        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0, 1, 3, 4:
            return UITableView.automaticDimension
        case 2:
            return 90
        default:
            return 0
        }
    }
}

class TutorCardProfilePic: UIImageView, Interactable {}

class TutorCardHeader: InteractableView {
    let distance = TutorDistanceView()

    let profilePics: TutorCardProfilePic = {
        let view = TutorCardProfilePic()

        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    let name: UILabel = {
        var label = UILabel()

        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(24)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    let darkPattern: UIImageView = {
        let view = UIImageView()

        view.image = #imageLiteral(resourceName: "very-dark-pattern")
        view.contentMode = .scaleAspectFill

        return view
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
        label.font = Fonts.createBoldSize(16)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true

        return label
    }()

    let gradientView = UIView()

    override func configureView() {
        addSubview(darkPattern)
        addSubview(gradientView)
        addSubview(profilePics)
        addSubview(name)
        addSubview(reviewLabel)
        addSubview(featuredSubject)
        super.configureView()

        translatesAutoresizingMaskIntoConstraints = false

        applyConstraints()
    }

    override func applyConstraints() {
        darkPattern.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        profilePics.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.width.height.equalTo(90)
            make.bottom.equalToSuperview().inset(15)
        }
        name.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(125)
            make.top.equalTo(profilePics).inset(5)
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
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.applyGradient(firstColor: Colors.navBarColor.cgColor, secondColor: UIColor.clear.cgColor, angle: 0, frame: gradientView.bounds)

        // darkPattern.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.63, offset: CGSize(width: 3, height: 3), radius: 6)
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

class TutorCardReviewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let profilePic: UIImageView = {
        let imageView = UIImageView()

        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = Fonts.createBoldSize(18)

        return label
    }()

    let reviewTextLabel: UILabel = {
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
        profilePic.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(49)
            make.width.equalTo(49)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }

        reviewTextLabel.snp.makeConstraints { make in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.centerY.equalToSuperview().multipliedBy(1.4)
            make.right.equalToSuperview()
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

class ConnectButton: InteractableView, Interactable {
    let connect: UILabel = {
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

        backgroundColor = UIColor(hex: "6562c9")
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false

        applyConstraints()
    }

    override func applyConstraints() {
        connect.snp.makeConstraints { make in
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

    func touchEndOnStart() {
        growShrink()
    }
}

class FullProfile: InteractableView, Interactable {
    let connect: UILabel = {
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
        connect.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
