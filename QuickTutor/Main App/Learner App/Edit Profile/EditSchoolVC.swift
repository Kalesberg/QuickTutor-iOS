//
//  EditSchool.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/1/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import FirebaseAuth
import Foundation
import UIKit

class EditSchoolView: UIView {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .black
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Colors.darkBackground
        return tableView
    }()

    let searchTextField: SearchTextField = {
        let textField = SearchTextField()
        textField.placeholder.text = "Search Schools"
        textField.textField.font = Fonts.createSize(16)
        textField.textField.tintColor = (AccountService.shared.currentUserType == .learner) ? Colors.purple : Colors.purple
        textField.textField.autocapitalizationType = .words
        return textField
    }()
    
    func setupViews() {
        setupMainView()
        setupSearchField()
        setupTableView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupSearchField() {
        addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(80)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
            make.centerX.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EditSchoolVC: UIViewController {
    
    let contentView: EditSchoolView = {
        let view = EditSchoolView()
        return view
    }()

    var schoolArray: [String] = [] {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var filteredSchools: [String] = [] {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var automaticScroll: Bool = false
    var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        hideKeyboardWhenTappedAround()
        configureDelegates()
        loadListOfSchools()
        navigationItem.title = "Edit School"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(displaySavedAlertController))
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        hideTabBar(hidden: true)
    }
    
    func setupSearchController() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            searchController.definesPresentationContext = true
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.tintColor = .white
            searchController.searchBar.placeholder = "Search schools"
            searchController.searchResultsUpdater = self
        }
    }
    
    override func loadView() {
        view = contentView
    }

    private func configureDelegates() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "idCell")
    }

    @objc func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your changes have been saved", preferredStyle: .alert)

        present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func scrollToTop() {
        contentView.tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        automaticScroll = false
    }

    private func loadListOfSchools() {
        let pathToFile = Bundle.main.path(forResource: "schools", ofType: "txt")
        if let path = pathToFile {
            do {
                let school = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                schoolArray = school.components(separatedBy: "\n") as [String]
                schoolArray.insert("No School", at: 0)
            } catch {
                schoolArray = []
            }
        }
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !isSearchBarEmpty()
    }
    
    private func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSchools = schoolArray.filter({( school : String) -> Bool in
            return school.lowercased().contains(searchText.lowercased())
        })
    }
}

extension EditSchoolVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return isFiltering() ? filteredSchools.count : schoolArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        let data = isFiltering() ? filteredSchools[indexPath.row] : schoolArray[indexPath.row]

        cell.backgroundColor = Colors.darkBackground
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = Fonts.createSize(16)
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.darkBackground.darker(by: 15)
        cell.selectedBackgroundView = cellBackground

        cell.textLabel?.text = data
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var school: String
        school = isFiltering() ? filteredSchools[indexPath.row] : schoolArray[indexPath.row]
        if school == "No School" {
            // Delete School from learner and tutor account
            let nodesToRemove = [
                "/student-info/\(CurrentUser.shared.learner.uid!)/sch": NSNull(),
                "tutor-info/\(CurrentUser.shared.learner.uid!)/sch": NSNull(),
            ]
            Tutor.shared.updateSharedValues(multiWriteNode: nodesToRemove) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
                CurrentUser.shared.learner.school = ""
                if AccountService.shared.currentUserType == .tutor {
                    CurrentUser.shared.tutor.school = ""
                }
            }
            displaySavedAlertController()
            return
        }
        switch AccountService.shared.currentUserType {
        case .learner:
            if !CurrentUser.shared.learner.isTutor {
                FirebaseData.manager.updateValue(node: "student-info", value: ["sch": school]) { error in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                    }
                }
                CurrentUser.shared.learner.school = school
                displaySavedAlertController()
                break
            }
            fallthrough
        case .tutor:

            let newNodes = ["/student-info/\(CurrentUser.shared.learner.uid!)/sch": school, "/tutor-info/\(CurrentUser.shared.learner.uid!)/sch": school]

            Tutor.shared.updateSharedValues(multiWriteNode: newNodes) { error in
                if let error = error {
                    print(error)
                } else {
                    self.displaySavedAlertController()
                }
            }
            CurrentUser.shared.learner.school = school
            if CurrentUser.shared.tutor != nil {
                CurrentUser.shared.tutor.school = school
            }
        default:
            break
        }
    }
}

extension EditSchoolVC: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        if !automaticScroll {
            view.endEditing(true)
        }
    }
}

extension EditSchoolVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}
