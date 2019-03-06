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
        tableView.backgroundColor = Colors.backgroundDark
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

    var shouldUpdateSearchResults: Bool = false
    var automaticScroll: Bool = false
    var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupSearchController()
        hideKeyboardWhenTappedAround()
        configureDelegates()
        loadListOfSchools()
        navigationItem.title = "Edit Shool"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(displaySavedAlertController))
    }
    
    func setupSearchController() {
        if #available(iOS 11.0, *) {
            searchController.searchBar.tintColor = .white
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search schools"
            definesPresentationContext = true
            navigationItem.searchController = searchController
        }
    }
    
    override func loadView() {
        view = contentView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // contentView.searchBar.becomeFirstResponder()
    }

    private func configureDelegates() {
        contentView.searchTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "idCell")
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        automaticScroll = true

        guard let text = textField.text else {
            automaticScroll = false
            shouldUpdateSearchResults = false
            return
        }

        if text == "" {
            automaticScroll = false
            shouldUpdateSearchResults = false
            contentView.tableView.reloadData()
            return
        }

        shouldUpdateSearchResults = true
        filteredSchools = schoolArray.filter { ($0.localizedCaseInsensitiveContains(text)) }

        if filteredSchools.count > 0 {
            scrollToTop()
        }
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
}

extension EditSchoolVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return shouldUpdateSearchResults ? filteredSchools.count : schoolArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        let data = shouldUpdateSearchResults ? filteredSchools[indexPath.row] : schoolArray[indexPath.row]

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
        school = shouldUpdateSearchResults ? filteredSchools[indexPath.row] : schoolArray[indexPath.row]
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
