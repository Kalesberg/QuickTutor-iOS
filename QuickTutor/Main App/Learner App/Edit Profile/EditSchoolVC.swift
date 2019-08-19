//
//  EditSchool.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/1/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import FirebaseAuth
import Foundation
import UIKit

class EditSchoolVC: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var school: String?
    
    var searchSource: [String]?
    
    static var controller: EditSchoolVC {
        return EditSchoolVC(nibName: String(describing: EditSchoolVC.self), bundle: nil)
    }

    var schoolArray: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var filteredSchools: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var automaticScroll: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        loadListOfSchools()
        
        setupViews()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        hideTabBar(hidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabBar(hidden: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    func setupNavBar() {
        navigationItem.title = "Edit School"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupViews() {
        searchView.layer.applyShadow(color: UIColor(red: 21/255, green: 21/255, blue: 30/255, alpha: 1.0).cgColor,
                                      opacity: 1,
                                      offset: CGSize(width: 0, height: 10),
                                      radius: 10)
        setupSearchField()
        setupTableView()
        closeButton.isHidden = school?.isEmpty ?? true
    }
    
    func setupSearchField() {
        searchTextField.addTarget(self, action: #selector(handleSearchTextFieldChange(_:)), for: .editingChanged)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for a school", attributes: [.foregroundColor : Colors.grayText80])
        searchTextField.text = school
    }
    
    func setupTableView() {
        tableView.register(QTEditSchoolTableViewCell.nib, forCellReuseIdentifier: QTEditSchoolTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = UIColor.clear
    }
    
    @IBAction func onCloseButtonClicked(_ sender: Any) {
        searchTextField.text = ""
        closeButton.isHidden = true
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
    
    @objc
    func handleSearchTextFieldChange(_ textField: UITextField) {
        guard let searchText = textField.text, !searchText.isEmpty else {
            closeButton.isHidden = true
            tableView.reloadData()
            return
        }
        
        filterContentForSearchText(searchText)
        
        closeButton.isHidden = false
    }

    private func scrollToTop() {
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        automaticScroll = false
    }

    private func loadListOfSchools() {
        let pathToFile = Bundle.main.path(forResource: "schools", ofType: "txt")
        if let path = pathToFile {
            do {
                let school = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                schoolArray = school.components(separatedBy: "\n") as [String]
                schoolArray.removeLast() // There's a new line at the EOF which is causing an empty row.
                schoolArray.sort()
                schoolArray.insert("No School", at: 0)
            } catch {
                schoolArray = []
            }
        }
    }
    
    private func isFiltering() -> Bool {
        return !isSearchTextFieldEmpty()
    }
    
    private func isSearchTextFieldEmpty() -> Bool {
        return searchTextField.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSchools = schoolArray.filter({( school : String) -> Bool in
            return school.lowercased().contains(searchText.lowercased())
        })
    }
}

extension EditSchoolVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return isFiltering() ? filteredSchools.count : schoolArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTEditSchoolTableViewCell.reuseIdentifier, for: indexPath) as! QTEditSchoolTableViewCell
        let data = isFiltering() ? filteredSchools[indexPath.row] : schoolArray[indexPath.row]

        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.newScreenBackground.darker(by: 5)
        cell.selectedBackgroundView = cellBackground
        
        cell.schoolLabel.text = data
        
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
            if !CurrentUser.shared.learner.hasTutor {
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
