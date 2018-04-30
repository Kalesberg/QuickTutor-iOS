//
//  TutorConnect.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol ApplyLearnerFilters {
    var filters : (Int,Int,Bool)! { get set }
    func applyFilters()
}

protocol ConnectButtonPress {
    var connectedTutor : AWTutor! { get set }
    func connectButtonPressed(uid: String)
}

class TutorConnectView : MainLayoutTwoButton {
    
    var back = NavbarButtonX()
    var filters = NavbarButtonLines()
    
    let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage(color: UIColor.clear)
        
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.font = Fonts.createSize(14)
        textField?.textColor = .white
        textField?.adjustsFontSizeToFitWidth = true
        textField?.autocapitalizationType = .words
        textField?.attributedPlaceholder = NSAttributedString(string: "Experiences", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        textField?.keyboardAppearance = .dark
        
        return searchBar
    }()
    
    let collectionView : UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        
        collectionView.backgroundColor = Colors.backgroundDark
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        return collectionView
    }()
    
    override var leftButton : NavbarButton {
        get {
            return back
        } set {
            back = newValue as! NavbarButtonX
        }
    }
    
    override var rightButton: NavbarButton {
        get {
            return filters
        } set {
            filters = newValue as! NavbarButtonLines
        }
    }
    
    override func configureView() {
        navbar.addSubview(searchBar)
        addSubview(collectionView)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalTo(back.snp.right)
            make.right.equalTo(rightButton.snp.left)
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(3)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

class TutorConnect : BaseViewController, ApplyLearnerFilters, ConnectButtonPress {

    var filters: (Int, Int, Bool)!
    
    func applyFilters() {
        //sort here... reset the datasource
        let sortedTutors = datasource.sorted { (tutor1 : AWTutor, tutor2 : AWTutor) -> Bool in

            let ratio1 = Double(tutor1.price) / Double(filters.1) / (tutor1.tRating / 5.0)
            let ratio2 = Double(tutor2.price) / Double(filters.1) / (tutor2.tRating / 5.0)

            return ratio1 < ratio2
        }
        self.datasource = sortedTutors
    }
    
    override var contentView: TutorConnectView {
        return view as! TutorConnectView
    }
    
    override func loadView() {
        view = TutorConnectView()
    }
    
    var connectedTutor : AWTutor!

    var featuredTutor : AWTutor! {
        didSet {
            self.datasource.append(featuredTutor)
        }
    }
    
	var datasource = [AWTutor]() {
        didSet {
			print("sourse!", datasource)
            contentView.collectionView.reloadData()
        }
    }

    var subcategory : String! {
        didSet {
            QueryData.shared.queryAWTutorBySubcategory(subcategory: subcategory!) { (tutors) in
                if let tutor = tutors {
					print(tutor, "kjhjhkgkhkjhkj")
                    self.datasource = tutor
                }
            }
        }
    }
    
    var subject : (String, String)! {
        didSet {
            QueryData.shared.queryAWTutorBySubject(subcategory: subject.0, subject: subject.1) { (tutors) in
                if let tutors = tutors {
                    self.datasource = tutors
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
        
        contentView.collectionView.register(TutorCardCollectionViewCell.self, forCellWithReuseIdentifier: "tutorCardCell")
    }
    
    func connectButtonPressed(uid: String) {
        addTutorWithUid(uid)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func handleNavigation() {
        if touchStartView is NavbarButtonLines {
            
            let next = LearnerFilters()
            next.delegate = self
            
            self.present(next, animated: true, completion: nil)
		} else if touchStartView is NavbarButtonX {
			let transition = CATransition()
			navigationController?.view.layer.add(transition.popFromTop(), forKey: nil)
			navigationController?.popViewController(animated: false)
		}
    }
}

extension TutorConnect : AddTutorButtonDelegate {
    
    func addTutorWithUid(_ uid: String) {
        
        DataService.shared.getTutorWithId(uid) { (tutor) in
            
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            
            vc.receiverId = uid
            vc.chatPartner = tutor
            vc.shouldSetupForConnectionRequest = true
            vc.tutor = self.connectedTutor
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension TutorConnect : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension TutorConnect : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorCardCell", for: indexPath) as! TutorCardCollectionViewCell
        
        let data = datasource[indexPath.item]

        cell.header.imageView.loadUserImages(by: (data.images["image1"])!)
        cell.header.name.text = data.name.components(separatedBy: " ")[0]

        cell.reviewLabel.text = "\(data.reviews?.count ?? 0) Reviews ★ \(data.tRating!)"
        cell.rateLabel.text = "$\(data.price!) / hour"
        
       	cell.datasource = datasource[indexPath.row]
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("12", 17, Colors.lightBlue)
            .regular("\n", 0, .clear)
            .bold("miles", 12, Colors.lightBlue)
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = -2
        
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        cell.distanceLabel.attributedText = formattedString
        cell.distanceLabel.numberOfLines = 0
        cell.delegate = self
        
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.width - 20

        return CGSize(width: width, height: collectionView.frame.height)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
