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

class YourListingView : MainLayoutTitleBackTwoButton {
    var editButton = NavbarButtonEdit()
    
    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }
    
    let scrollView = UIScrollView()
    
    let collectionView : UICollectionView = {
        
        let collectionView  = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		
		collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = Colors.tutorBlue
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
		collectionView.isPagingEnabled = true
		
		return collectionView
    }()
    
    let imageView : UIImageView = {
        let view = UIImageView()

		view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        return view
    }()
    
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
    
    override func configureView() {
        addSubview(scrollView)
		addSubview(collectionView)
		collectionView.addSubview(imageView)
		imageView.addSubview(categoryLabel)
        scrollView.addSubview(infoLabel)
        super.configureView()
		
		title.label.text = "Your Listing"
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
		
        imageView.snp.makeConstraints { (make) in
			make.top.equalTo(260)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(40)
        }

        categoryLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
    }
}
class NoListingView : BaseView {
	
	let noListingsImageView : UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "sad-face")
		return imageView
	}()
	
	let noListingsTitle : UILabel = {
		let label = UILabel()
		
		label.text = "No Active Listing"
		label.font = Fonts.createSize(18)
		label.textColor = UIColor.white.withAlphaComponent(0.9)
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .center
		
		return label
	}()
	
	let noListingsSubtitle : UILabel = {
		let label = UILabel()
		
		label.text = "When you create a listing you will see it here."
		label.font = Fonts.createLightSize(16)
		label.textColor = UIColor.white.withAlphaComponent(0.8)
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .center
		
		return label
	}()
	
	let createListing : UIButton = {
		let button = UIButton(frame: .zero)
		
		button.setTitle("Create a Listing!", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = Fonts.createBoldSize(20)
		button.layer.borderColor = UIColor.white.cgColor
		button.layer.borderWidth = 1
		button.addTarget(self, action: #selector(createAListing(_:)), for: .touchUpInside)
		
		return button
	}()
	
	var delegate : CreateListing?
	
	override func configureView() {
		addSubview(createListing)
		addSubview(noListingsTitle)
		addSubview(noListingsSubtitle)
		addSubview(noListingsImageView)
		super.configureView()
		
		isUserInteractionEnabled = true
		applyConstraints()
	}
	override func applyConstraints() {
		noListingsImageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(20)
			make.width.height.equalTo(90)
			make.centerX.equalToSuperview()
		}
		noListingsTitle.snp.makeConstraints { (make) in
			make.top.equalTo(noListingsImageView.snp.bottom).inset(-10)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(25)
		}
		noListingsSubtitle.snp.makeConstraints { (make) in
			make.top.equalTo(noListingsTitle.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(25)
		}
		createListing.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview().inset(20)
			make.centerX.equalToSuperview()
			make.width.equalTo(225)
			make.height.equalTo(40)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		createListing.layer.cornerRadius = createListing.frame.height / 4
	}
	
	@objc func createAListing(_ sender: Any) {
		delegate?.createListingButtonPressed()
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

	var listings = [FeaturedTutor]() {
		didSet {
			contentView.collectionView.reloadData()
		}
	}
	
	var categories = [Category]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let tutor = CurrentUser.shared.tutor else { return }
		self.tutor = tutor		
		configureDelegates()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		fetchTutorListings()
	}
	private func fetchTutorListings() {
		self.displayLoadingOverlay()
		FirebaseData.manager.fetchTutorListings(uid: tutor.uid) { (listings) in
			if let listings = listings {
				self.listings = Array(listings.values)
				self.categories = Array(listings.keys)
			} else {
				let view = NoListingView()
				view.delegate = self
				self.contentView.collectionView.backgroundView = view
				self.contentView.editButton.isHidden = true
			}
			self.dismissOverlay()
		}
	}
	
	private func configureDelegates() {
		contentView.collectionView.delegate = self
		contentView.collectionView.dataSource = self
		contentView.collectionView.register(FeaturedTutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")
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
        cell.featuredTutor.namePrice.text = listings[indexPath.item].name
        cell.featuredTutor.region.text = listings[indexPath.item].region
        cell.featuredTutor.subject.text = listings[indexPath.item].subject
		
		let formattedString = NSMutableAttributedString()
        formattedString
            .bold("\(listings[indexPath.item].rating) ", 14, Colors.yellow)
            .regular("(\(listings[indexPath.item].reviews) ratings)", 12, Colors.yellow)
        cell.featuredTutor.ratingLabel.attributedText = formattedString
		
		contentView.categoryLabel.text = categories[indexPath.row].mainPageData.displayName
		contentView.imageView.image = UIImage(named: "\(categories[indexPath.row].subcategory.fileToRead)-pattern")
		
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
		
		return UIEdgeInsetsMake(0, leftInset, 30, rightInset)
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


