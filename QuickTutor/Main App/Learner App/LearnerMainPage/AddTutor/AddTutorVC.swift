//
//  AddTutor.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import FirebaseUI
import FirebaseAuth
import Lottie
import UIKit

struct UsernameQuery {
    let uid: String
    let name: String
    let username: String
    let imageUrl: String

    var isConnected: Bool = false

    init(snapshot: DataSnapshot) {
        uid = snapshot.key
        // ewy
        guard let value = snapshot.value as? [String: Any] else { name = ""; username = ""; imageUrl = ""; return }

        if let images = value["img"] as? [String: String],
            images.keys.contains("image1") {
            imageUrl = images["image1"] ?? ""
        } else {
            imageUrl = ""
        }
        name = value["nm"] as? String ?? ""
        username = value["usr"] as? String ?? ""
    }
}


class AddTutorVC: BaseViewController {
    override var contentView: AddTutorView {
        return view as! AddTutorView
    }

    var searchTimer = Timer()
    var connectedIds = [String]()
    var queriedIds = [String]()
    var pendingIds = [String]()
	
	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    var filteredUsername = [UsernameQuery]() {
        didSet {
            if filteredUsername.isEmpty && contentView.searchTextField.textField.text!.count > 0 {
                let backgroundView = TutorCardCollectionViewBackground()
                backgroundView.label.attributedText = NSMutableAttributedString().bold("No Tutors Found", 22, .white)
                contentView.tableView.backgroundView = backgroundView
            } else {
                contentView.tableView.backgroundView = nil
            }
            contentView.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureDelegates()
        navigationItem.title = "Add Tutor by Username"
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    @objc func onBack() {
        
    }

    override func loadView() {
        view = AddTutorView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.searchTextField.textField.becomeFirstResponder()
    }

    override func viewWillAppear(_: Bool) {
        FirebaseData.manager.fetchLearnerConnections(uid: CurrentUser.shared.learner.uid) { connectedIds in
            if let connectedIds = connectedIds {
                self.connectedIds = connectedIds
            }
            FirebaseData.manager.fetchPendingRequests(uid: CurrentUser.shared.learner.uid) { ids in
                guard let ids = ids else { return }
                ids.forEach({
                    if !self.connectedIds.contains($0) {
                        self.pendingIds.append($0)
                    }
                })
                self.contentView.tableView.reloadData()
            }
        }
    }

    private func configureDelegates() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(AddTutorTableViewCell.self, forCellReuseIdentifier: "addTutorCell")
        contentView.searchTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        searchTimer.invalidate()
        guard let text = textField.text, text.count > 0, text != "" else {
            filteredUsername.removeAll()
            queriedIds.removeAll()
            contentView.loadingIndicator.displayDefaultText()
            return
        }
        func startTimer() {
            searchTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(searchUsername(_:)), userInfo: text.lowercased(), repeats: true)
            contentView.loadingIndicator.displayLoadingIndicator(with: "Searching for \"\(text)\"")
        }
        startTimer()
    }

    @objc func searchUsername(_ sender: Timer) {
        contentView.loadingIndicator.dismissLoadingIndicator()
        guard let searchText = sender.userInfo as? String else { return }
        queriedIds.removeAll()
        searchTimer.invalidate()

        var queriedUsername = [UsernameQuery]()

        let ref: DatabaseReference! = Database.database().reference().child("tutor-info")
        ref.queryOrdered(byChild: "usr").queryStarting(atValue: searchText).queryEnding(atValue: searchText + "\u{f8ff}").queryLimited(toFirst: 50).observeSingleEvent(of: .value) { snapshot in

            for snap in snapshot.children {
                guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
                let usernameQuery = UsernameQuery(snapshot: child)
                queriedUsername.append(usernameQuery)
                self.queriedIds.append(child.key)
            }
            self.filteredUsername.removeAll()
            self.filteredUsername = queriedUsername
        }
    }
    
}

extension AddTutorVC: CustomModalDelegate {
    func handleConfirm() {
        let next = CardManagerViewController()
        next.popBackTo = AddTutorVC()
        next.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(next, animated: true)
    }
}

extension AddTutorVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string == "" && (textField.text!.count - 1 == 0) {
            contentView.loadingIndicator.displayDefaultText()
        }
        return true
    }
}

extension AddTutorVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func numberOfSections(in _: UITableView) -> Int {
        return filteredUsername.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addTutorCell", for: indexPath) as! AddTutorTableViewCell
		let reference = storageRef.child("student-info").child(filteredUsername[indexPath.section].uid).child("student-profile-pic1")

        let name = filteredUsername[indexPath.section].name.split(separator: " ")

        cell.delegate = self
        cell.usernameLabel.text = filteredUsername[indexPath.section].username
        cell.nameLabel.text = (connectedIds.contains(filteredUsername[indexPath.section].uid)) ? "\(name[0]) \(String(name[1]).prefix(1)) – Connected" : "\(name[0]) \(String(name[1]).prefix(1))"
        cell.profileImageView.sd_setImage(with: reference)
        cell.uid = filteredUsername[indexPath.section].uid

        if pendingIds.contains(filteredUsername[indexPath.section].uid) {
            cell.nameLabel.text = "\(name[0]) \(String(name[1]).prefix(1)). – Pending"
            cell.addTutorButton.setTitle("Pending", for: .normal)
        } else if connectedIds.contains(filteredUsername[indexPath.section].uid) {
            cell.nameLabel.text = "\(name[0]) \(String(name[1]).prefix(1)). – Connected"
            cell.addTutorButton.setTitle("Message", for: .normal)
        } else {
            cell.nameLabel.text = "\(name[0]) \(String(name[1]).prefix(1))."
            cell.addTutorButton.setTitle("Connect", for: .normal)
        }
        return cell
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 16
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayLoadingOverlay()
        tableView.allowsSelection = false
        FirebaseData.manager.fetchTutor(filteredUsername[indexPath.section].uid, isQuery: false) { tutor in
            if let tutor = tutor {
                DispatchQueue.main.async {
                    let controller = QTProfileViewController.controller
                    controller.user = tutor
                    controller.profileViewType = .tutor
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            tableView.allowsSelection = true
            self.dismissOverlay()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AddTutorVC: AddTutorButtonDelegate {
    func addTutorWithUid(_ uid: String, completion: (() -> Void)?) {
        UserFetchService.shared.getTutorWithId(uid) { tutor in
            if let tutor = tutor {
                let vc = ConversationVC()
                vc.receiverId = uid
                vc.chatPartner = tutor
                self.navigationController?.pushViewController(vc, animated: true)
            }
            completion!()
        }
    }
}

extension AddTutorVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        view.endEditing(true)
    }
}

protocol ShowsConversation {
    func showConversation(uid: String)
}

extension ShowsConversation {
    func showConversation(uid: String) {
        let vc = ConversationVC()
        vc.receiverId = uid
        navigationController.pushViewController(vc, animated: true)
    }
}
