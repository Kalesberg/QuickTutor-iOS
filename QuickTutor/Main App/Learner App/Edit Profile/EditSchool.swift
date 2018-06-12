//
//  EditSchool.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/1/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


import Foundation
import UIKit
import FirebaseAuth

class EditSchoolView : EditProfileMainLayout {
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
        
        return tableView
    }()
    
    let searchTextField : SearchTextField = {
        let textField = SearchTextField()
        textField.placeholder.text = "Search Schools"
        textField.textField.font = Fonts.createSize(16)
        textField.textField.tintColor = (AccountService.shared.currentUserType == .learner) ? Colors.learnerPurple : Colors.tutorBlue
        textField.textField.autocapitalizationType = .words
        
        return textField
    }()
    
    var header = UIView()
    
    override func configureView() {
        addSubview(tableView)
        addSubview(header)
        header.addSubview(searchTextField)
        super.configureView()
        
        title.label.text = "School"
        titleLabel.label.text = "School I attend"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        header.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).inset(-20)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.left.equalTo(tableView.snp.left)
            make.height.equalTo(80)
        }
        searchTextField.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.95)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
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
            searchTextField.tintColor = Colors.tutorBlue
        } else {
            navbar.backgroundColor = Colors.learnerPurple
            statusbarView.backgroundColor = Colors.learnerPurple
            searchTextField.tintColor = Colors.learnerPurple
        }
    }
}

class EditSchool : BaseViewController {
    
    override var contentView: EditSchoolView {
        return view as! EditSchoolView
    }
    
    var schoolArray : [String] = [] {
        didSet {
            contentView.tableView.reloadData()
        }
    }
    var filteredSchools : [String] = [] {
        didSet {
            contentView.tableView.reloadData()
        }
    }
    var shouldUpdateSearchResults : Bool = false
    var automaticScroll : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureDelegates()
        loadListOfSchools()
    }
    override func loadView() {
        view = EditSchoolView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //contentView.searchBar.becomeFirstResponder()
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
            return
        }
        
        shouldUpdateSearchResults = true
        filteredSchools = self.schoolArray.filter{($0.localizedCaseInsensitiveContains(text))}
        
        if filteredSchools.count > 0 {
            scrollToTop()
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
    private func scrollToTop() {
        contentView.tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        automaticScroll = false
    }
    
    override func handleNavigation() {
        if (touchStartView is NavbarButtonSave) {
            //save button
        }
    }
    
    private func loadListOfSchools() {
        let pathToFile = Bundle.main.path(forResource: "schools", ofType: "txt")
        if let path = pathToFile {
            do {
                let school = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                schoolArray = school.components(separatedBy: "\n") as [String]
            } catch {
                schoolArray = []
                print("Try-catch error")
            }
        }
    }
}

extension EditSchool : UITableViewDelegate, UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldUpdateSearchResults ? filteredSchools.count : schoolArray.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        formatTableView(cell)
        let data = shouldUpdateSearchResults ? filteredSchools[indexPath.row] : schoolArray[indexPath.row]
        
        cell.textLabel?.text = data
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var school : String
        school = shouldUpdateSearchResults ? filteredSchools[indexPath.row] : schoolArray[indexPath.row]
        
        switch AccountService.shared.currentUserType {
        case .learner:
            if !CurrentUser.shared.learner.isTutor {
                
                FirebaseData.manager.updateValue(node: "student-info", value: ["sch" : school])
                CurrentUser.shared.learner.school = school
                displaySavedAlertController()
                break
            }
            fallthrough
        case .tutor :
            
            let newNodes = ["/student-info/\(AccountService.shared.currentUser.uid!)/sch" : school, "/tutor-info/\(AccountService.shared.currentUser.uid!)/sch" : school]
            
            Tutor.shared.updateSharedValues(multiWriteNode: newNodes) { (error) in
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
    
    private func formatTableView(_ cell: UITableViewCell) {
        let border = UIView(frame:CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 2))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
        cell.backgroundColor = Colors.backgroundDark
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = Fonts.createSize(16)
        
        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.selectedBackgroundView = cellBackground
    }
}
extension EditSchool : UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if !automaticScroll {
            self.view.endEditing(true)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !automaticScroll {
            self.view.endEditing(true)
        }
    }
}
