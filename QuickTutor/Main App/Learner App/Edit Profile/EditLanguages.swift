//
//  EditLanguages.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


import Foundation
import UIKit

class EditLanguageView : EditProfileMainLayout {
	
	var tableView = UITableView()
	
	override func configureView() {
		addSubview(tableView)
		super.configureView()
		
		title.label.text = "Languages"
		titleLabel.label.text = "Languages you speak"
		
		tableView.estimatedRowHeight = 25
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tableView.allowsMultipleSelection = true
		
		
	}
	override func applyConstraints() {
		super.applyConstraints()
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.9)
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
			} else {
				make.bottom.equalToSuperview()
			}
			make.centerX.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if AccountService.shared.currentUserType == .tutor {
			navbar.backgroundColor = Colors.tutorBlue
			statusbarView.backgroundColor = Colors.tutorBlue
		} else {
			navbar.backgroundColor = Colors.learnerPurple
			statusbarView.backgroundColor = Colors.learnerPurple
		}
	}
}

class EditLanguage : BaseViewController {
	
	override var contentView: EditLanguageView {
		return view as! EditLanguageView
	}
	override func loadView() {
		view = EditLanguageView()
	}
	
	var datasource : [String]?
	
	var selectedCells = [String]() {
		didSet {
			contentView.tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureDelegates()
		loadListOfLanguages()
		
		guard let languages = (AccountService.shared.currentUserType == .learner) ? CurrentUser.shared.learner.languages : CurrentUser.shared.tutor.languages else { return }
		
		selectedCells = languages
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
	}
	
	private func configureDelegates() {
		contentView.tableView.delegate   = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(CustomLanguageCell.self, forCellReuseIdentifier: "idCell")
	}
	
	override func handleNavigation() {
		if (touchStartView is NavbarButtonSave) {
			self.dismissKeyboard()
			saveLanguages()
		}
	}
	private func displaySavedAlertController() {
		let alertController = UIAlertController(title: "Saved!", message: "Your changes have been saved", preferredStyle: .alert)
		
		self.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when){
			alertController.dismiss(animated: true){
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	
	private func saveLanguages() {
		switch AccountService.shared.currentUserType {
		case .learner:
			if !CurrentUser.shared.learner.isTutor {
				
				CurrentUser.shared.learner.languages = selectedCells
				FirebaseData.manager.updateValue(node: "student-info", value: ["lng" : selectedCells]) { (error) in
					if let error = error {
						AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
					}
				}
				displaySavedAlertController()
				break
				
			}
			fallthrough
		case .tutor :
			
			let newNodes = ["/student-info/\(AccountService.shared.currentUser.uid!)/lng" : selectedCells, "/tutor-info/\(AccountService.shared.currentUser.uid!)/lng" : selectedCells]
			
			Tutor.shared.updateSharedValues(multiWriteNode: newNodes) { (error) in
				if let error = error {
					print(error)
				} else {
					print("success")
					self.displaySavedAlertController()
				}
			}
			CurrentUser.shared.learner.languages = selectedCells
			
			if AccountService.shared.currentUserType == .tutor {
				CurrentUser.shared.tutor.languages = selectedCells
			}
		default:
			break
		}
	}
	
	private func loadListOfLanguages() {
		let pathToFile = Bundle.main.path(forResource: "languages", ofType: "txt")
		if let path = pathToFile {
			do {
				let school = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
				datasource = school.components(separatedBy: ",") as [String]
			} catch {
				datasource = nil
				print("Try-catch error")
			}
		}
	}
}
extension EditLanguage : UITableViewDelegate, UITableViewDataSource {
	
	internal func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return datasource?.count ?? 0
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : CustomLanguageCell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath) as! CustomLanguageCell
		
		guard let language = datasource?[indexPath.row] else { return  cell }
		cell.textLabel?.text = language
		cell.checkbox.isSelected =  selectedCells.contains(language)
		
		return cell
	}
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell : CustomLanguageCell = tableView.cellForRow(at: indexPath) as! CustomLanguageCell
		
		if self.selectedCells.contains((cell.textLabel?.text)!) {
			self.selectedCells.remove(at: selectedCells.index(of:(cell.textLabel?.text)!)!)
			cell.checkbox.isSelected = false
		} else {
			self.selectedCells.append((cell.textLabel?.text)!)
			cell.checkbox.isSelected = true
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

class CustomLanguageCell : UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let checkbox = RegistrationCheckbox()
	
	func configureTableViewCell() {
		addSubview(checkbox)
		
		checkbox.isSelected = false
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
		
		backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		textLabel?.textColor = UIColor.white
		textLabel?.font = Fonts.createSize(16)
		
		applyConstraints()
	}
	
	func applyConstraints() {
		checkbox.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.centerY.equalToSuperview()
			make.width.equalTo(50)
		}
	}
}
