//
//  YourListingVC.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol CreateListing {
    func createListingButtonPressed()
}

protocol UpdateListingCallBack {
	func updateListingCallBack(price: Int, subject: String, image: UIImage, category: Category)
}

class YourListingView: MainLayoutTitleTwoButton {
    var editButton = NavbarButtonEdit()
    var backButton = NavbarButtonBack()

    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }

    override var leftButton: NavbarButton {
        get {
            return backButton
        } set {
            backButton = newValue as! NavbarButtonBack
        }
    }

    let fakeBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "484782")
        return view
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0

        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor(hex: "484782")
        collectionView.isPagingEnabled = true

        return collectionView
    }()

    let imageView: UIImageView = {
        let view = UIImageView()

        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true

        return view
    }()

    let imageViewBackground = UIView()

    let categoryLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(20)
        label.textColor = .white

        return label
    }()

    let infoLabel: UILabel = {
        let label = UILabel()

        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("\nWhat is this?", 18, .white)
            .regular("\n\nThis is where you can view and edit how your listing is seen by learners on the home page. Your listing is different from your actual profile.\n\nYou can customize the photo, price, and subject that you want learners to see on the home page of the learner app.\n\nTap \"Edit\" in the top-right of the screen.\n\n", 15, .white)

        label.attributedText = formattedString
        label.numberOfLines = 0

        return label
    }()

    let hideButtonContainer = UIView()

    let hideButton: UIButton = {
        let button = UIButton()

        button.setTitle("Hide Listing", for: .normal)
        button.backgroundColor = Colors.tutorBlue
        button.layer.cornerRadius = 7
        button.titleLabel?.font = Fonts.createBoldSize(18)

        return button
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createLightSize(13)

        return label
    }()

    let infoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundDark
        return view
    }()

    override func configureView() {
        insertSubview(fakeBackground, belowSubview: navbar)
        insertSubview(scrollView, belowSubview: navbar)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(hideButtonContainer)
        scrollView.addSubview(imageViewBackground)
        scrollView.addSubview(infoContainer)
        infoContainer.addSubview(infoLabel)
        imageViewBackground.addSubview(imageView)
        imageView.addSubview(categoryLabel)
        hideButtonContainer.addSubview(hideButton)
        hideButtonContainer.addSubview(descriptionLabel)
        super.configureView()
        navbar.applyDefaultShadow()
        navbar.clipsToBounds = false
        navbar.layer.masksToBounds = false
        bringSubviewToFront(navbar)
        bringSubviewToFront(statusbarView)
        navbar.layer.borderWidth = 0


        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
        

        title.label.text = "Listings"
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageViewBackground.applyGradient(firstColor: UIColor(hex: "6562C9").cgColor, secondColor: UIColor(hex: "6562C9").cgColor, angle: 90, frame: imageViewBackground.bounds)
    }

    override func applyConstraints() {
        super.applyConstraints()
        fakeBackground.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).inset(1)
            make.centerX.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).inset(1)
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.centerX.equalToSuperview()
            make.height.equalTo(300)
        }

        imageViewBackground.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(40)
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        infoContainer.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }

        hideButtonContainer.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom)
            make.height.equalTo(80)
            make.centerX.width.equalToSuperview()
        }

        hideButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(150)
            make.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(hideButton.snp.bottom).inset(-10)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(25)
            make.bottom.equalToSuperview()
        }
    }
}

class YourListingVC: BaseViewController {
    override var contentView: YourListingView {
        return view as! YourListingView
    }

    override func loadView() {
        view = YourListingView()
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    var tutor: AWTutor! {
        didSet {
            contentView.collectionView.reloadData()
        }
    }

    var featuredCategory: String?
    var categories = [Category]()

    var listings = [FeaturedTutor]() {
        didSet {
            listings.count == 0 ? setupViewForNoListing() : setupViewForListing()
            contentView.collectionView.reloadData()
        }
    }

    var hideListing: Bool! {
        didSet {
            setupHideListingButton()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let tutor = CurrentUser.shared.tutor else { return }
        self.tutor = tutor
        configureDelegates()
        contentView.hideButton.addTarget(self, action: #selector(handleHideButton), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTutorListings()
    }

    private func setupViewForNoListing() {
        let view = NoListingBackgroundView()
        view.delegate = self
        contentView.collectionView.backgroundView = view
        contentView.editButton.isHidden = true
        contentView.hideButton.isHidden = true
        contentView.descriptionLabel.isHidden = true
    }

    private func setupViewForListing() {
        hideListing = (listings[0].isHidden == 1)
        contentView.collectionView.backgroundView = nil
        contentView.editButton.isHidden = false
        contentView.hideButton.isHidden = false
        contentView.descriptionLabel.isHidden = false
    }

    private func setupHideListingButton() {
        contentView.hideButton.backgroundColor = hideListing ? UIColor.gray : Colors.learnerPurple
        contentView.hideButton.setTitle(hideListing ? "Unhide listing" : "Hide Listing", for: .normal)
        contentView.descriptionLabel.text = hideListing ? "Your listing is currently hidden from the main page." : "Your listing is visible to all learners on the main page."
    }

    //this function needs some refactoring.
    private func fetchTutorListings() {
        displayLoadingOverlay()
        FirebaseData.manager.fetchTutorListings(uid: tutor.uid) { listings in
            if let listings = listings {
                self.listings = Array(listings.values)
                self.categories = Array(listings.keys)
                if listings.count > 0 {
                    self.featuredCategory = self.categories[0].subcategory.fileToRead
                }
            }
            self.dismissOverlay()
        }
    }

    private func configureDelegates() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(FeaturedTutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")
    }

    @objc private func handleHideButton() {
        hideListing = !hideListing
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonEdit {
            let cell = contentView.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! FeaturedTutorCollectionViewCell

            let vc = EditListingVC()
            vc.price = listings[0].price
            vc.image = cell.featuredTutor.imageView.image
            vc.subject = listings[0].subject
			vc.subjects = tutor.subjects ?? []
			vc.categoryOfCurrentListing = self.featuredCategory
            vc.delegate = self
			vc.isEditingExistingListing = true
            navigationController?.pushViewController(vc, animated: true)

        } else if touchStartView is NavbarButtonBack {
			guard let featuredCategory = featuredCategory else { return }
            let value = (hideListing == true) ? 1 : 0
            FirebaseData.manager.hideListing(uid: CurrentUser.shared.learner.uid, category: featuredCategory, isHidden: value)
        }
    }
}

extension YourListingVC: UpdateListingCallBack {
	func updateListingCallBack(price: Int, subject: String, image: UIImage, category: Category) {
        let cell = contentView.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! FeaturedTutorCollectionViewCell
        cell.price.text = "$\(price)/hr"
        cell.featuredTutor.subject.text = subject
        cell.featuredTutor.imageView.image = image
		
    }
}

extension YourListingVC: CreateListing {
    func createListingButtonPressed() {
		let vc = EditListingVC()
		vc.subjects = CurrentUser.shared.tutor.subjects ?? []
		vc.isEditingExistingListing = false
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

extension YourListingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return listings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell

        cell.featuredTutor.imageView.loadUserImagesWithoutMask(by: listings[indexPath.item].imageUrl)
        cell.price.text = listings[indexPath.item].price.priceFormat()
        cell.view.backgroundColor = Colors.green
        cell.featuredTutor.namePrice.text = listings[indexPath.item].name
        cell.featuredTutor.region.text = listings[indexPath.item].region
        cell.featuredTutor.subject.text = listings[indexPath.item].subject
		cell.featuredTutor.ratingLabel.attributedText = NSMutableAttributedString().bold("\(listings[indexPath.item].rating) ", 14, Colors.gold)
		cell.featuredTutor.numOfRatingsLabel.attributedText = NSMutableAttributedString().regular("(\(listings[indexPath.item].reviews) ratings)", 13, Colors.gold)

        cell.layer.cornerRadius = 6
        contentView.categoryLabel.text = categories[indexPath.row].mainPageData.displayName
        contentView.imageView.image = UIImage(named: "\(categories[indexPath.row].subcategory.fileToRead)-pattern")?.alpha(0.35)

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 210)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 20
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        let totalCellWidth = 150 * listings.count
        let totalSpacingWidth = 20 * (listings.count - 1)
        let leftInset = (UIScreen.main.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 30, right: rightInset)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        cell.shrink()
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
}
