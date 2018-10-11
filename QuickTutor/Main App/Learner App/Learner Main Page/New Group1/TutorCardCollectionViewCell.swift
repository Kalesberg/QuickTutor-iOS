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
    let body = TutorCardBody()
    let connect = ConnectButton()
    let viewFullProfile = FullProfile()

    let tableView: UITableView = {
        let tableView = UITableView()

        tableView.rowHeight = 55
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        tableView.delaysContentTouches = false

        return tableView
    }()

    func configureCollectionViewCell() {
        addSubview(header)
        addSubview(body)
        addSubview(connect)
        addSubview(tableView)
        addSubview(viewFullProfile)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TutorCardReviewCell.self, forCellReuseIdentifier: "reviewCell")

        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.8, offset: CGSize(width: 2, height: 2), radius: 10)

        applyConstraints()
    }

    func applyConstraints() {
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        body.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(15)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(body.aboutMe.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(150)
            make.centerX.equalToSuperview()
        }
        viewFullProfile.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.height.equalTo(30)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.centerX.equalToSuperview()
        }
        connect.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        header.roundCorners([.topLeft, .topRight], radius: 6)

        body.roundCorners([.bottomLeft, .bottomRight], radius: 6)

        connect.layer.cornerRadius = connect.frame.height / 2

        connect.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.8, offset: CGSize(width: 2, height: 2), radius: connect.frame.height / 2)
    }

    override func handleNavigation() {
        if touchStartView is ConnectButton {
            print("connect")
        } else if touchStartView is FullProfile {
            if let current = UIApplication.getPresentedViewController() {
                current.present(ViewFullProfile(), animated: true, completion: nil)
            }
        }
    }
}

extension TutorCardCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! TutorCardReviewCell
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 50
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = SectionHeader()
        view.category.text = "22 Reviews"
        view.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        return view
    }
}

class TutorCardHeader: InteractableView {
    let distance = TutorDistanceView()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "registration-image-placeholder")
        return imageView
    }()

    let name: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .left
        label.text = "Alex Zoltowski, 20"
        label.font = Fonts.createBoldSize(30)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let region: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .left
        label.text = "Mount Pleasant, Michigan"
        label.font = Fonts.createSize(16)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let tutorData: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .left
        label.text = "148 hours taught, 14 completed sessions"
        label.font = Fonts.createSize(16)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    override func configureView() {
        addSubview(imageView)
        addSubview(region)
        addSubview(name)
        addSubview(tutorData)
        addSubview(distance)
        super.configureView()

        backgroundColor = Colors.tutorBlue
        roundCorners([.topLeft, .topRight], radius: 6)
        applyConstraints()
    }

    override func applyConstraints() {
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        region.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).multipliedBy(1.1)
            make.centerY.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        name.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).multipliedBy(1.1)
            make.bottom.equalTo(region.snp.top)
            make.height.equalTo(25)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        tutorData.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).multipliedBy(1.1)
            make.top.equalTo(region.snp.bottom)
            make.height.equalTo(25)
            make.width.equalToSuperview()
        }
        distance.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
    }
}

class TutorDistanceView: BaseView {
    let distance: UILabel = {
        let label = UILabel()

        label.textColor = Colors.tutorBlue
        label.text = "3 miles away"
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

class TutorCardBody: InteractableView {
    let priceRating = PriceRating()
    let aboutMe = AboutMeView()

    override func configureView() {
        addSubview(priceRating)
        addSubview(aboutMe)

        super.configureView()
        aboutMe.aboutMeLabel.label.text = "About Alex"
        aboutMe.bioLabel.text = "Emma: .TopRight and .BottomRight are not working for you perhaps because the call to view.roundCorners is done BEFORE final view bounds are calculated. Note that the Bezier Path derives from the view bounds at the time it is called."
        backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)

        applyConstraints()
    }

    override func applyConstraints() {
        priceRating.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.15)
            make.width.equalToSuperview()
        }
        aboutMe.snp.makeConstraints { make in
            make.top.equalTo(priceRating.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        }
    }
}

class TutorCardReviewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let profilePic: UIImageView = {
        let imageView = UIImageView()

        imageView.image = LocalImageCache.localImageManager.getImage(number: "1")

        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.text = "Austin Welch"
        label.font = Fonts.createBoldSize(18)

        return label
    }()

    let reviewTextLabel: UILabel = {
        let label = UILabel()

        label.text = "This kid FUCKS! But i still want to see how this looks and if will allow me to go onto 2 lines"
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
        label.text = "$9.00/hour"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let rating: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(18)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.text = "4.71 * (22 ratings)"
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
        label.text = "CONNECT"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    override func configureView() {
        addSubview(connect)
        super.configureView()
        backgroundColor = Colors.learnerPurple
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
        alpha = 0.5
    }

    func touchEndOnStart() {
        alpha = 1.0
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

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
