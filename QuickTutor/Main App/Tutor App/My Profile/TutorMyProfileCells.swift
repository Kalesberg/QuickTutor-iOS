//
//  TutorMyProfileCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseStorage
import FirebaseUI
import Foundation
import SDWebImage
import SnapKit
import UIKit

class SubjectSelectionCollectionViewCell: UICollectionViewCell {
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    required override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureView()
    }

    let label: UILabel = {
        let label = UILabel()

        label.backgroundColor = .clear
        label.font = Fonts.createSize(14)
        label.textColor = .white
        label.textAlignment = .center

        return label
    }()

    let labelContainer = UIView()

    func configureView() {
        addSubview(labelContainer)
        labelContainer.addSubview(label)

        labelContainer.backgroundColor = UIColor(hex: "919191")
        labelContainer.layer.cornerRadius = 10
        labelContainer.clipsToBounds = true
        labelContainer.layer.borderColor = UIColor.white.cgColor

        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 10

        applyConstraints()
    }

    func applyConstraints() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        labelContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    func configureView() {}
    func applyConstraints() {}

    var touchStartView: (UIView & Interactable)?

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if let firstTouch = touches.first {
            let hitView = contentView.hitTest(firstTouch.location(in: contentView), with: event)

            if hitView is Interactable {
                print("BEGAN: INTERACTABLE")
                touchStartView = hitView as? (UIView & Interactable)
                touchStartView?.touchStart()
            } else {
                print("BEGAN: NOT INTERACTABLE")
            }
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if touchStartView == nil {
            print("DRAGGING ON A NONINTERACTABLE")
        } else {
            if let firstTouch = touches.first {
                let hitView = contentView.hitTest(firstTouch.location(in: contentView), with: event)
                let previousView = contentView.hitTest(firstTouch.previousLocation(in: contentView), with: event)

                if (touchStartView == hitView) && (previousView == hitView) {
                    print("DRAGGING ON START VIEW")
                    touchStartView?.draggingOn()
                } else if previousView == touchStartView {
                    print("DID DRAG OFF START VIEW")
                    touchStartView?.didDragOff()
                } else if (previousView != touchStartView) && (hitView == touchStartView) {
                    print("DID DRAG ON TO START VIEW")
                    touchStartView?.didDragOn()
                } else {
                    touchStartView?.draggingOff()
                    print("DRAGGING OFF START VIEW")
                }
            }
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if touchStartView == nil {
            print("ENDED: NON INTERACTABLE")
        } else {
            if let firstTouch = touches.first {
                let hitView = contentView.hitTest(firstTouch.location(in: contentView), with: event)
                print(hitView as Any)
                if touchStartView == hitView {
                    print("ENDED: ON START")
                    touchStartView?.touchEndOnStart()
                } else {
                    touchStartView?.touchEndOffStart()
                    touchStartView = nil
                    print("ENDED: OFF START")
                }
            }
        }

        handleNavigation()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        if touchStartView == nil {
            print("CANCELLED: NON INTERACTABLE")
        } else {
            print("CANCELLED: INTERACTABLE")
            touchStartView?.touchCancelled()
        }

        touchStartView = nil
    }

    public func handleNavigation() {}
}

class InteractableUIImageView: UIImageView, Interactable {}


class SubjectsTableViewCell : UITableViewCell {
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureView()
	}
	
    let subjectCollectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0

        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.tag = 1

        return collectionView
    }()

    var datasource = [String]() {
        didSet {
            subjectCollectionView.reloadData()
        }
    }

    let label: UILabel = {
        let label = UILabel()

        label.text = "Subjects"
        label.textColor = UIColor(hex: "5785d4")
        label.font = Fonts.createBoldSize(16)

        return label
    }()

    func configureView() {
        addSubview(label)
        addSubview(subjectCollectionView)

        backgroundColor = Colors.navBarColor
		
        subjectCollectionView.delegate = self
        subjectCollectionView.dataSource = self
        subjectCollectionView.register(SubjectSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "subjectSelectionCollectionViewCell")

        applyConstraints()
    }

    func applyConstraints() {
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.height.equalTo(55)
            make.top.equalToSuperview()
        }

        subjectCollectionView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom)
        }
    }
}

extension SubjectsTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectSelectionCollectionViewCell", for: indexPath) as! SubjectSelectionCollectionViewCell

        cell.label.text = datasource[indexPath.row]
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (datasource[indexPath.row] as NSString).size(withAttributes: nil).width + 35, height: 30)
    }
}

class RatingTableViewCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureView()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    let tableView: UITableView = {
        let tableView = UITableView()
		
		tableView.backgroundColor = Colors.navBarColor
        tableView.estimatedRowHeight = 60
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.estimatedSectionHeaderHeight = 30
		tableView.delaysContentTouches = true
		tableView.separatorColor = Colors.navBarColor
		
        return tableView
    }()


    var datasource = [Review]() {
        didSet {
			updateTableViewConstraints()
            tableView.reloadData()
        }
    }
    var isViewing: Bool = false
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	func configureView() {
        contentView.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyProfileReview.self, forCellReuseIdentifier: "reviewCell")
		
		backgroundColor = Colors.navBarColor
        selectionStyle = .none

        applyConstraints()
    }

	func applyConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.98)
            if datasource.count == 1 {
                make.height.equalTo(120)
            } else {
                make.height.equalTo(190)
            }
        }
    }
	private func updateTableViewConstraints() {
		tableView.snp.remakeConstraints { make in
			make.top.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.95)
			make.height.equalTo(datasource.count == 1 ? 120 : 190)
		}
	}
}

class NoRatingsBackgroundView : UIView {

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}

    let title: UILabel = {
        let label = UILabel()

        label.text = "No reviews yet!"
        label.font = Fonts.createBoldSize(16)
        label.textColor = .white
		label.textAlignment = .center

        return label
    }()

	func configureView() {
		addSubview(title)

        backgroundColor = Colors.navBarColor

        applyConstraints()
    }

	func applyConstraints() {
		title.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.height.equalTo(50)
        }
	}
}

extension RatingTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return (datasource.count >= 2) ? 2 : datasource.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! TutorMyProfileLongReviewTableViewCell
		
        let data = datasource[indexPath.row]
        let formattedName = data.studentName.split(separator: " ")
        cell.nameLabel.text = "\(String(formattedName[0]).capitalized) \(String(formattedName[1]).capitalized.prefix(1))."
        cell.reviewTextLabel.text = "\"\(data.message)\""
        cell.subjectLabel.attributedText = NSMutableAttributedString().bold("\(data.rating) ★", 14, Colors.gold).bold(" - \(data.subject)", 13, .white)
        cell.dateLabel.text = "\(data.formattedDate)"

        let reference = storageRef.child("student-info").child(data.reviewerId).child("student-profile-pic1")
        cell.profilePic.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))

        return UITableViewCell()
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        cell.backgroundColor = Colors.navBarColor
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let label = UILabel()

        label.font = Fonts.createBoldSize(16)
        label.text = "Reviews (\((datasource.count)))"
        label.textColor = isViewing ? Colors.otherUserColor() : Colors.currentUserColor()
        return label
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 40
    }
}

class MyProfileReview: UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	let profilePic: UIImageView = {
		let imageView = UIImageView()
		imageView.layer.masksToBounds = false
		imageView.scaleImage()
		imageView.clipsToBounds = true
		return imageView
	}()
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.sizeToFit()
		label.font = Fonts.createBoldSize(16)
		return label
	}()
	
	let subjectLabel = UILabel()
	
	let reviewTextLabel: UILabel = {
		let label = UILabel()
		label.textColor = Colors.grayText
		label.font = Fonts.createItalicSize(14)
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.sizeToFit()
		return label
	}()
	
	let dateLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = Fonts.createSize(12)
		label.textAlignment = .right
		return label
	}()
		
	var reviewLabelHeight : CGFloat {
		layoutIfNeeded()
		reviewTextLabel.sizeToFit()
		return (dateLabel.frame.height + reviewTextLabel.frame.height + nameLabel.frame.height + reviewTextLabel.intrinsicContentSize.height)
	}
	let buttonMask : UIButton = {
		let button = UIButton()
		button.backgroundColor = .clear
		return button
	}()
	func configureView() {
		addSubview(profilePic)
		addSubview(nameLabel)
		addSubview(subjectLabel)
		addSubview(reviewTextLabel)
		addSubview(dateLabel)
		addSubview(buttonMask)
		
		backgroundColor = Colors.navBarColor
		
		applyConstraints()
	}
	
	func applyConstraints() {
		profilePic.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.height.width.equalTo(50)
			make.left.equalToSuperview().inset(10)
		}
		nameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(-5)
			make.height.equalTo(30)
			make.left.equalTo(profilePic.snp.right).inset(-5)
		}
		subjectLabel.snp.makeConstraints { make in
			make.left.equalTo(nameLabel.snp.right).inset(-5)
			make.height.equalTo(30)
			make.centerY.equalTo(nameLabel)
			make.top.equalToSuperview()
		}
		reviewTextLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom)
			make.left.equalTo(profilePic.snp.right).inset(-5)
			make.right.equalToSuperview().inset(5)
		}
		dateLabel.snp.makeConstraints { make in
			make.top.equalTo(reviewTextLabel.snp.bottom)
			make.width.equalToSuperview()
			make.right.equalToSuperview().inset(5)
			make.bottom.equalToSuperview()
		}
		buttonMask.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		profilePic.layer.cornerRadius = profilePic.frame.height / 2
	}
}

class TutorMyProfileLongReviewTableViewCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	var minHeight: CGFloat?
	
	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
		let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
		guard let minHeight = minHeight else { return size }
		return CGSize(width: size.width, height: max(size.height, minHeight))
	}
	
    let profilePic: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = false
        imageView.scaleImage()
        imageView.clipsToBounds = true
        return imageView
	}()

    let nameLabel: UILabel = {
        let label = UILabel()
		label.sizeToFit()
        label.font = Fonts.createBoldSize(16)
        return label
    }()

    let subjectLabel = UILabel()

    let reviewTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText
        label.font = Fonts.createItalicSize(14)
        label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		
		return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(12)
		label.textAlignment = .right
        return label
    }()

    let container = UIView()
    var isViewing: Bool = false

	func configureTableViewCell() {
        addSubview(container)
       	addSubview(profilePic)
		addSubview(nameLabel)
        addSubview(subjectLabel)
        addSubview(reviewTextLabel)
        addSubview(dateLabel)

		backgroundColor = .clear
        selectionStyle = .none
		
		applyConstraints()
    }

    func applyConstraints() {
        profilePic.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.height.width.equalTo(50)
			make.left.equalToSuperview().inset(10)
        }

        nameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(-5)
			make.height.equalTo(30)
            make.left.equalTo(profilePic.snp.right).inset(-5)
		}

        subjectLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).inset(-5)
			make.height.equalTo(30)
            make.centerY.equalTo(nameLabel)
			make.top.equalToSuperview()
        }

        reviewTextLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(profilePic.snp.right).inset(-5)
            make.right.equalToSuperview().inset(5)
			
        }
        dateLabel.snp.makeConstraints { make in
			make.top.equalTo(reviewTextLabel.snp.bottom)
			make.width.equalToSuperview()
			make.bottom.right.equalToSuperview().inset(5)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePic.layer.cornerRadius = profilePic.frame.height / 2
        nameLabel.textColor = isViewing ? Colors.otherUserColor() : Colors.currentUserColor()
    }
}

extension String {
	func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		return ceil(boundingBox.height)
	}
}
