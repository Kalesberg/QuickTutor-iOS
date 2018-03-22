//
//  EditLanguages.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
// TODO Design:
//  - Make cell height smaller
//
//TODO Backend:
//  - is the searchbar necessary?
// 	- Currently allow 10 languages, need to add an error message for when the user hits that limit
//  - Remove last item from array of languages cuz xcode forces an empty line at the end of the file EDIT:
// I force this empty item ^ to ensure we don't unwrap a non-optional variable. I then account for it later in the code.
//  - Change cell checkbox to its opposite when it's tapped, will prolly have to cast the cell to the checkbox object, will prolly have to disable interaction on the checkbox
//	Haven't touched this class too because i didnt want to deal with the language.txt.


import Foundation
import UIKit

class EditLanguageView : EditProfileMainLayout {
	
	var tableView = UITableView()
	var searchBar = UISearchBar()
	
	override func configureView() {
		addSubview(tableView)
		addSubview(searchBar)
		super.configureView()
		
		title.label.text = "Language"
		titleLabel.label.text = "Languages you speak"
		
		tableView.estimatedRowHeight = 25
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tableView.allowsMultipleSelection = true
		
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .minimal
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		textField?.font = Fonts.createSize(18)
		textField?.textColor = .white
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words	
		textField?.attributedPlaceholder = NSAttributedString(string: "Enter a language", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        textField?.keyboardAppearance = .dark
		
	}
	override func applyConstraints() {
		super.applyConstraints()
        
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.width.equalTo(searchBar)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
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
	
	var languages : NSArray = []
	var filteredLanguages : NSArray = []
	let currentLanguges = LearnerData.userData.languages
	var selectedCells : [String]!
	var shouldUpdateSearchResults = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
		loadListOfLanguages()
		selectedCells = currentLanguges!.filter{ ($0 != "") }
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		//contentView.searchBar.becomeFirstResponder()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
	}
	
	private func configure() {
		contentView.searchBar.delegate   = self
		contentView.tableView.delegate   = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(CustomLanguageCell.self, forCellReuseIdentifier: "idCell")
	}
	
	override func handleNavigation() {
		if (touchStartView is NavbarButtonSave) {
			saveLanguages()
		}
	}
	private func saveLanguages() {
		LearnerData.userData.languages = selectedCells
		FirebaseData.manager.updateValue(value: ["lng" : selectedCells])
		navigationController?.popViewController(animated: true)
	}
	
	private func loadListOfLanguages() {
		let pathToFile = Bundle.main.path(forResource: "languages", ofType: "txt")
        if let path = pathToFile {
            do {
                let school = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                languages = school.components(separatedBy: ",") as NSArray
            } catch {
                languages = [""]
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
		if shouldUpdateSearchResults {
			return filteredLanguages.count
		} else {
			return languages.count
		}
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : CustomLanguageCell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath) as! CustomLanguageCell
		if shouldUpdateSearchResults {
			cell.textLabel?.text = (filteredLanguages[indexPath.row] as! String)
			if selectedCells.contains((cell.textLabel?.text)!) || (currentLanguges?.contains((cell.textLabel?.text)!))! {
				cell.checkbox.isSelected = true
			} else{
				cell.checkbox.isSelected = false
			}
		}
		else {
			cell.textLabel?.text = (languages[indexPath.row] as! String)
			if selectedCells.contains((cell.textLabel?.text)!) || (currentLanguges?.contains((cell.textLabel?.text)!))! {
				cell.checkbox.isSelected = true
			} else{
				cell.checkbox.isSelected = false
			}
		}
		return cell
	}
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell : CustomLanguageCell = tableView.cellForRow(at: indexPath) as! CustomLanguageCell
		
		if self.selectedCells.contains((cell.textLabel?.text)!) {
			self.selectedCells.remove(at: selectedCells.index(of:(cell.textLabel?.text)!)!)
			cell.checkbox.isSelected = false
			tableView.deselectRow(at: indexPath, animated: true)
		} else {
			self.selectedCells.append((cell.textLabel?.text)!)
			cell.checkbox.isSelected = true
			tableView.deselectRow(at: indexPath, animated: true)
		}
		print(self.selectedCells)
	}
}

extension EditLanguage : UISearchBarDelegate {
	
	private func scrollToTop() {
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
	}
	
	internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		shouldUpdateSearchResults = true
		
		if let searchString = contentView.searchBar.text {
			let predicate = NSPredicate(format: "SELF contains[c] %@", searchString)
			filteredLanguages = languages.filtered(using: predicate) as NSArray
			if filteredLanguages.count > 0 {
				scrollToTop()
			} else {
				filteredLanguages = languages
			}
		}
		contentView.tableView.reloadData()
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
	
	var checkbox = RegistrationCheckbox()

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
