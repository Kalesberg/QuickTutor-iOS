//
//  TutorSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class SearchView : RegistrationGradientView {
	
	var searchBar = UISearchBar()
	var tableView = UITableView()
	
	override func configureView() {
		super.configureView()
		
		addSubview(searchBar)
		addSubview(tableView)
		
//		addSubview(cardContainer)
//		cardContainer.addSubview(academics)
//		cardContainer.addSubview(remedial)
//		cardContainer.addSubview(sports)
//
//		cardContainer.backgroundColor = .black
//		academics.backgroundColor = .blue
//		academics.label.label.text = "Academics"
//		academics.imageView.backgroundColor = .purple
//		academics.imageView.alpha = 0.6
//
//		remedial.backgroundColor = .red
//		remedial.label.label.text = "Remedial"
//		remedial.imageView.backgroundColor = .orange
//		remedial.imageView.alpha = 0.6
//
//		sports.backgroundColor = .green
//		sports.label.label.text = "Sports"
//		sports.imageView.backgroundColor = .white
//		sports.imageView.alpha = 0.6

		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		searchBar.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(DeviceInfo.statusbarHeight)
			make.width.equalToSuperview()
		}
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(searchBar.snp.bottom)
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.7)
		}
//		cardContainer.snp.makeConstraints { (make) in
//			make.top.equalTo(searchBar.snp.bottom)
//			make.height.equalToSuperview().multipliedBy(0.6)
//			make.width.equalToSuperview()
//			make.centerX.equalToSuperview()
//			make.centerY.equalToSuperview().multipliedBy(1.1)
//		}
//		academics.snp.makeConstraints { (make) in
//			make.top.equalToSuperview()
//			make.width.height.equalToSuperview().multipliedBy(0.3)
//			make.left.equalToSuperview().multipliedBy(1.1)
//		}
//
//		remedial.snp.makeConstraints { (make) in
//			make.top.equalToSuperview()
//			make.width.height.equalToSuperview().multipliedBy(0.3)
//			make.centerX.equalToSuperview()
//		}
//		sports.snp.makeConstraints { (make) in
//			make.top.equalToSuperview()
//			make.width.height.equalToSuperview().multipliedBy(0.3)
//			make.right.equalToSuperview().multipliedBy(0.9)
//		}
	}
}

class TutorSubjects : BaseViewController {
	
	override var contentView: SearchView {
		return view as! SearchView
	}
	
	override func loadView() {
		view = SearchView()
	}
	
	var searchController = UISearchController(searchResultsController: nil)
	
	var searchActive : Bool = false
	
	var filtered : [String] = ["Hello", "this", "why"]

	override func viewDidLoad() {
        super.viewDidLoad()

		contentView.tableView.dataSource = self
		contentView.tableView.delegate = self
		contentView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	
	}
	
	override func viewWillAppear(_ animated: Bool) {
		contentView.tableView.reloadData()
	}
	
	override func handleNavigation() {
		
//		if(touchStartView == contentView.academics) {
//			//filter category to only academics
//			print("Academics")
//		}
//		if (touchStartView == contentView.remedial) {
//			//filter category to only remedial
//			print("Remedial")
//		}
//		if (touchStartView == contentView.sports) {
//			//filter category to only
//			print("Sports")
//		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    @objc func nextButton(_ sender: UIButton!) {
		//let next = TutorBio()
		//navigationController!.pushViewController(next, animated: true)
	}
}
extension TutorSubjects : UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filtered.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.detailTextLabel?.text = filtered[indexPath.row]
		print("cellfor")
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("Selected Row")
	}
}

//struct Subject {
//	var category : String
//	var subcategory : String
//	var parents : [String]
//	var subject : String
//	var children : [String]
//}
//
//
//class SubjectTableViewCell : UITableViewCell {
//
//	var background : UIView!
//	var subjectLabel : UILabel!
//	var globalTutors : UILabel!
//	var localTutors : UILabel!
//
//	var subject : Subject? {
//		didSet {
//			if let subject = subject {
//				subjectLabel.text = subject.subject
//				globalTutors.text = "1005 Global Tutors"
//				localTutors.text = "132 Local Tutors"
//				setNeedsLayout()
//			}
//		}
//	}
//	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//		super.init(style: style, reuseIdentifier: reuseIdentifier)
//		configureView()
//	}
//
//	public required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		configureView()
//	}
//	internal func configureView() {
//		isUserInteractionEnabled = true
//		backgroundColor = UIColor.clear
//		selectionStyle = .none
//
//		background = UIView(frame: .zero)
//		background.alpha = 0.6
//		contentView.addSubview(background)
//
//		subjectLabel = UILabel(frame: .zero)
//		subjectLabel.textAlignment = .left
//		subjectLabel.textColor = .white
//		subjectLabel.adjustsFontForContentSizeCategory = true
//		subjectLabel.adjustsFontSizeToFitWidth = true
//		subjectLabel.font = Fonts.createLightSize(15)
//
//		globalTutors = UILabel(frame: .zero)
//		globalTutors.textAlignment = .right
//		globalTutors.textColor = .white
//		globalTutors.adjustsFontForContentSizeCategory = true
//		globalTutors.adjustsFontSizeToFitWidth = true
//		globalTutors.font = Fonts.createLightSize(15)
//
//		localTutors = UILabel(frame: .zero)
//		localTutors.textAlignment = .left
//		localTutors.textColor = .white
//		localTutors.adjustsFontForContentSizeCategory = true
//		localTutors.adjustsFontSizeToFitWidth = true
//		localTutors.font = Fonts.createLightSize(15)
//
//	}
//	override func prepareForReuse() {
//		super.prepareForReuse()
//	}
//
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		background.frame = CGRect(x: 0, y: 5, width: frame.width, height: frame.height)
//		subjectLabel.snp.makeConstraints { (make) in
//			make.left.equalToSuperview().multipliedBy(1.3)
//			make.centerY.equalToSuperview()
//			make.width.equalToSuperview().multipliedBy(0.5)
//			make.height.equalToSuperview().multipliedBy(0.5)
//		}
//		globalTutors.snp.makeConstraints { (make) in
//			make.right.equalToSuperview().multipliedBy(0.7)
//			make.centerY.equalToSuperview()
//			make.width.equalToSuperview().multipliedBy(0.5)
//			make.height.equalToSuperview().multipliedBy(0.5)
//		}
//		localTutors.snp.makeConstraints { (make) in
//			make.top.equalTo(globalTutors.snp.bottom)
//			make.left.equalToSuperview().multipliedBy(1.3)
//			make.centerY.equalToSuperview()
//			make.width.equalToSuperview().multipliedBy(0.5)
//			make.height.equalToSuperview().multipliedBy(0.5)
//		}
//	}
//	internal func applyConstraints() {
//		fatalError("Override this method")
//	}
//}
