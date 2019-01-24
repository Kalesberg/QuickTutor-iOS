//
//  EditLanguages.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Foundation
import UIKit

class EditLanguageView: UIView {
    
    var tableView: UITableView = {
        let table = UITableView()
        table.estimatedRowHeight = 25
        table.separatorStyle = .singleLine
        table.separatorColor = .black
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = Colors.darkBackground
        table.allowsMultipleSelection = true
        return table
    }()

    func setupViews() {
        setupMainView()
        setupTableView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EditLanguageVC: UIViewController {
    
    let contentView: EditLanguageView = {
        let view = EditLanguageView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    var datasource: [String]?

    var selectedCells = [String]() {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        configureDelegates()
        loadListOfLanguages()

        guard let languages = (AccountService.shared.currentUserType == .learner) ? CurrentUser.shared.learner.languages : CurrentUser.shared.tutor.languages else { return }

        selectedCells = languages
    }

    private func configureDelegates() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CustomLanguageCell.self, forCellReuseIdentifier: "idCell")
    }

    func setupNavBar() {
        navigationItem.title = "Languages I Speak"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"newBackButton"), style: .plain, target: self, action: #selector(onBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(saveLanguages))
    }
    
    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    private func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your changes have been saved", preferredStyle: .alert)

        present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc func saveLanguages() {
        let selectedLanguages = selectedCells.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        switch AccountService.shared.currentUserType {
        case .learner:

            if !CurrentUser.shared.learner.isTutor {
                CurrentUser.shared.learner.languages = selectedLanguages
                FirebaseData.manager.updateValue(node: "student-info", value: ["lng": selectedLanguages]) { error in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                    }
                }
                displaySavedAlertController()
                break
            }
            fallthrough
        case .tutor:

            let newNodes = [
                "/student-info/\(CurrentUser.shared.learner.uid!)/lng": selectedLanguages,
                "/tutor-info/\(CurrentUser.shared.learner.uid!)/lng": selectedLanguages,
            ]

            Tutor.shared.updateSharedValues(multiWriteNode: newNodes) { error in
                if let error = error {
                    print(error)
                } else {
                    print("success")
                    self.displaySavedAlertController()
                }
            }
            CurrentUser.shared.learner.languages = selectedLanguages
            if AccountService.shared.currentUserType == .tutor {
                CurrentUser.shared.tutor.languages = selectedLanguages
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
                datasource = school.components(separatedBy: "\n") as [String]
                datasource = datasource?.filter({ !$0.isEmpty && $0.count > 0})
            } catch {
                datasource = nil
                print("Try-catch error")
            }
        }
    }
}

extension EditLanguageVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return datasource?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomLanguageCell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath) as! CustomLanguageCell

        guard let language = datasource?[indexPath.row] else { return cell }
        cell.textLabel?.text = language
        cell.checkbox.isSelected = selectedCells.contains(language)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: CustomLanguageCell = tableView.cellForRow(at: indexPath) as! CustomLanguageCell
        guard let selectedLanguage = cell.textLabel?.text else { return }

        if selectedCells.count + 1 > 5 && !selectedCells.contains(selectedLanguage) {
            AlertController.genericErrorAlertWithoutCancel(self, title: "Too Many Languages", message: "We currently only allow a maximum of 5 languages to be chosen.")
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        if selectedCells.contains((cell.textLabel?.text)!) {
            selectedCells.remove(at: selectedCells.index(of: selectedLanguage)!)
            cell.checkbox.isSelected = false
        } else {
            selectedCells.append(selectedLanguage)
            cell.checkbox.isSelected = true
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class CustomLanguageCell: UITableViewCell {

    let checkbox = RegistrationCheckbox()

    func setupViews() {
        setupBackground()
        setupTextLabel()
        setupCheckBox()
    }
    
    func setupBackground() {
        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.darkBackground.darker(by: 15)
        selectedBackgroundView = cellBackground
        
        backgroundColor = Colors.darkBackground
    }
    
    func setupTextLabel() {
        textLabel?.textColor = UIColor.white
        textLabel?.font = Fonts.createSize(16)
        textLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func setupCheckBox() {
        addSubview(checkbox)
        checkbox.isSelected = false
        checkbox.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
