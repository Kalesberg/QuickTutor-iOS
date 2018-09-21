//
//  YourListing.swift
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
	func updateListingCallBack(price: Int, subject: String, image: UIImage)
}

class YourListingView : MainLayoutTitleTwoButton {
	
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
	
	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = true
		return scrollView
	}()
	
    let collectionView : UICollectionView = {
        let collectionView  = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		
		collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor(hex: "344161")
		collectionView.isPagingEnabled = true
		
		return collectionView
    }()
    
    let imageView : UIImageView = {
        let view = UIImageView()

		view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        return view
    }()
    
    let imageViewBackground = UIView()
    
    let categoryLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
		
        return label
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("\nWhat is this?", 18, .white)
            .regular("\n\nThis is where you can view and edit how your listing is seen by learners on the home page. Your listing is different from your actual profile.\n\nYou can customize the photo, price, and subject that you want learners to see on the home page of the learner app.\n\nTap \"Edit\" in the top-right of the screen.\n\n", 15, .white)
        
        label.attributedText = formattedString
        label.numberOfLines = 0
        
        return label
    }()
    
    let hideButton : UIButton = {
        let button = UIButton()
        
        button.setTitle("Hide Listing", for: .normal)
        button.backgroundColor = Colors.tutorBlue
        button.layer.cornerRadius = 7
        button.titleLabel?.font = Fonts.createBoldSize(18)
        
        return button
    }()
	
	let descriptionLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createLightSize(13)
		
		return label
	}()
	
    override func configureView() {
        addSubview(scrollView)
		addSubview(collectionView)
		collectionView.addSubview(imageViewBackground)
        imageViewBackground.addSubview(imageView)
		imageView.addSubview(categoryLabel)
        scrollView.addSubview(infoLabel)
        scrollView.addSubview(hideButton)
		scrollView.addSubview(descriptionLabel)
        super.configureView()
        
        let navbarColor = UIColor(hex: "5785D4")
        
        navbar.backgroundColor = navbarColor
        statusbarView.backgroundColor = navbarColor
		
		title.label.text = "Your Listing"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageViewBackground.applyGradient(firstColor: UIColor(hex: "456AA8").cgColor, secondColor: UIColor(hex: "5785D4").cgColor, angle: 90, frame: imageViewBackground.bounds)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
		
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-1)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(300)
		}
		
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
		
        imageViewBackground.snp.makeConstraints { (make) in
			make.top.equalTo(260)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
        
        hideButton.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
            make.top.equalTo(infoLabel.snp.bottom)
        }
		descriptionLabel.snp.makeConstraints { (make) in
			make.top.equalTo(hideButton.snp.bottom).inset(-10)
			make.width.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalTo(layoutMargins.bottom)
			}
		}
    }
}


class YourListing : BaseViewController {
    
    override var contentView: YourListingView {
        return view as! YourListingView
    }
    
    override func loadView() {
        view = YourListingView()
		contentView.layoutIfNeeded()
		contentView.scrollView.setContentSize()
    }
	
	var tutor : AWTutor! {
		didSet{
			contentView.collectionView.reloadData()
		}
	}
	var featuredCategory: String!
	var categories = [Category]()
	
	var listings = [FeaturedTutor]() {
		didSet {
			if listings.count == 0 {
				setupViewForNoListing()
			} else {
				setupViewForListing()
			}
			contentView.collectionView.reloadData()
		}
	}
	
	var hideListing : Bool! {
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
		self.contentView.collectionView.backgroundView = nil
		contentView.editButton.isHidden = false
		contentView.hideButton.isHidden = false
		contentView.descriptionLabel.isHidden = false
	}
	
	private func setupHideListingButton() {
		contentView.hideButton.backgroundColor = hideListing ? UIColor.gray : Colors.tutorBlue
		contentView.hideButton.setTitle(hideListing ? "Unhide listing" : "Hide Listing" , for: .normal)
		contentView.descriptionLabel.text = hideListing ? "Your listing is currently hidden from the main page." : "Your listing is visible to all learners on the main page."
	}
	
	//this function needs some refactoring.
	private func fetchTutorListings() {
		self.displayLoadingOverlay()
		FirebaseData.manager.fetchTutorListings(uid: tutor.uid) { (listings) in
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

			let next = EditListing()
			next.price = listings[0].price
			next.image = cell.featuredTutor.imageView.image
			next.subject = listings[0].subject
			next.category = categories[0].subcategory.fileToRead
			next.delegate = self
			navigationController?.pushViewController(next, animated: true)
		
		} else if touchStartView is NavbarButtonBack {
			let value = (hideListing == true) ? 1 : 0
			FirebaseData.manager.hideListing(uid: CurrentUser.shared.learner.uid, category: featuredCategory, isHidden: value)
		}
	}
}
extension YourListing : UpdateListingCallBack {
	func updateListingCallBack(price: Int, subject: String, image: UIImage) {
		let cell = contentView.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! FeaturedTutorCollectionViewCell
		cell.price.text = "$\(price)/hr"
		cell.featuredTutor.subject.text = subject
		cell.featuredTutor.imageView.image = image
	}
}
extension YourListing : CreateListing {
	func createListingButtonPressed() {
		findTopSubjects { (category) in
			if let category = category {
				let next = EditListing()
				next.category = category
				self.navigationController?.pushViewController(next, animated: true)
			}
		}
	}
	private func findTopSubjects(_ completion: @escaping (String?) -> Void){
		func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
			return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
		}
		FirebaseData.manager.fetchSubjectsTaught(uid: tutor.uid) { (subcategoryList) in
			let avg = subcategoryList.map({$0.rating / 5}).average
			
			let topSubcategory = subcategoryList.sorted {
				return bayesianEstimate(C: avg, r: $0.rating / 5, v: Double($0.numSessions), m: 10) > bayesianEstimate(C: avg, r: $1.rating / 5, v: Double($1.numSessions), m: 10)
				}.first
			
			guard let subcategory = topSubcategory?.subcategory else { return completion(nil) }
			completion(SubjectStore.findCategoryBy(subcategory: subcategory))
		}
	}
}

extension YourListing : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
		
		let formattedString = NSMutableAttributedString()
        formattedString
            .bold("\(listings[indexPath.item].rating) ", 14, Colors.yellow)
            .regular("(\(listings[indexPath.item].reviews) ratings)", 12, Colors.yellow)
        cell.featuredTutor.ratingLabel.attributedText = formattedString
		
		contentView.categoryLabel.text = categories[indexPath.row].mainPageData.displayName
		contentView.imageView.image = UIImage(named: "\(categories[indexPath.row].subcategory.fileToRead)-pattern")?.alpha(0.35)
		cell.layer.cornerRadius = 6
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 150, height: 210)
    }
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		
		let totalCellWidth = 150 * listings.count
		let totalSpacingWidth = 20 * (listings.count - 1)
		
		let leftInset = (UIScreen.main.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
		let rightInset = leftInset
		
		return UIEdgeInsets.init(top: 0, left: leftInset, bottom: 30, right: rightInset)
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


