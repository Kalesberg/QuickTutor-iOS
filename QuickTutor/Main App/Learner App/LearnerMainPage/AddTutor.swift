//
//  AddTutor.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

struct UsernameQuery {
    
    let uid : String
    let name : String
    let username : String
    let imageUrl : String

    var isConnected : Bool = false

    init(snapshot: DataSnapshot) {
        uid = snapshot.key
        //ewy
        guard let value = snapshot.value as? [String : Any] else { name = ""; username = ""; imageUrl = ""; return }
        
        if let images = value["img"] as? [String : String] {
            imageUrl = images["image1"] ?? ""
        } else {
            imageUrl = ""
        }
        name = value["nm"] as? String ?? ""
        username = value["usr"] as? String ?? ""
    }
}

class AddTutorView : MainLayoutTitleBackButton {
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.rowHeight = 44
        tableView.separatorInset.left = 10
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
        
        return tableView
    }()
    
    let searchTextField : SearchTextField = {
        let textField = SearchTextField()
        textField.placeholder.text = "Search Usernames"
        textField.textField.font = Fonts.createSize(16)
        textField.textField.tintColor = Colors.learnerPurple
        textField.textField.autocapitalizationType = .words
        
        return textField
    }()
    
    override func configureView() {
        addSubview(tableView)
        addSubview(searchTextField)
        super.configureView()

        title.label.text = "Add Tutor by Username"
		title.label.textAlignment = .center
		
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        searchTextField.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(80)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(searchTextField.snp.bottom)
            make.width.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(layoutMargins.bottom)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class AddTutor : BaseViewController, ShowsConversation {
    
    override var contentView: AddTutorView {
        return view as! AddTutorView
        
    }
    
    var searchTimer = Timer()
    var connectedIds = [String]()
    var queriedIds = [String]()
    var pendingIds = [String]()
    
    var filteredUsername = [UsernameQuery]() {
        didSet {
            contentView.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureDelegates()
    
    }
    
    override func loadView() {
        view = AddTutorView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.searchTextField.textField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseData.manager.fetchLearnerConnections(uid: CurrentUser.shared.learner.uid) { (connectedIds) in
            if let connectedIds = connectedIds {
                self.connectedIds = connectedIds
            }
            FirebaseData.manager.fetchPendingRequests(uid: CurrentUser.shared.learner.uid) { (ids) in
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
        guard let text = textField.text, text.count > 0, text != ""  else {
            self.filteredUsername.removeAll()
            self.queriedIds.removeAll()
            return
        }
        func startTimer(){
            searchTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(searchUsername(_:)), userInfo: text.lowercased(), repeats: true)
        }
        startTimer()
    }

    @objc func searchUsername(_ sender: Timer) {
        guard let searchText = sender.userInfo as? String else { return }
        filteredUsername.removeAll()
        queriedIds.removeAll()
        searchTimer.invalidate()
        
        var queriedUsername = [UsernameQuery]()
        
        let ref : DatabaseReference! = Database.database().reference().child("tutor-info")
        ref.queryOrdered(byChild: "usr").queryStarting(atValue: searchText).queryEnding(atValue: searchText + "\u{f8ff}").queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
        
            for snap in snapshot.children {
                guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
                let usernameQuery = UsernameQuery(snapshot: child)
                queriedUsername.append(usernameQuery)
                self.queriedIds.append(child.key)
            }
            self.filteredUsername = queriedUsername
        }
    }
}

extension AddTutor : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredUsername.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addTutorCell", for: indexPath) as! AddTutorTableViewCell
        
        let name = filteredUsername[indexPath.section].name.split(separator: " ")
        
        cell.delegate = self
        cell.usernameLabel.text = "@\(filteredUsername[indexPath.section].username)"
        cell.nameLabel.text = (connectedIds.contains(filteredUsername[indexPath.section].uid)) ? "\(name[0]) \(String(name[1]).prefix(1)) – Connected" : "\(name[0]) \(String(name[1]).prefix(1))"
        cell.profileImageView.loadUserImages(by: filteredUsername[indexPath.section].imageUrl)
        cell.delegate = self
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FirebaseData.manager.fetchTutor(filteredUsername[indexPath.section].uid, isQuery: false) { (tutor) in
            guard let tutor = tutor else { return }
            let next = TutorMyProfile()
            next.tutor = tutor
            next.contentView.rightButton.isHidden = true
            next.contentView.title.label.text = "@\(self.filteredUsername[indexPath.section].username)"
            self.navigationController?.pushViewController(next, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension AddTutor : AddTutorButtonDelegate {
    
    func addTutorWithUid(_ uid: String) {
        DataService.shared.getTutorWithId(uid) { (tutor) in
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            vc.receiverId = uid
            vc.chatPartner = tutor
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class AddTutorTableViewCell : UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureTableViewCell()
    }
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = #imageLiteral(resourceName: "defaultProfileImage")
        
        return imageView
    }()
    
    let usernameLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(17)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .left
        
        return label
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()

        label.font = Fonts.createLightSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .left

        return label
    }()
    
    
    
    let addTutorButton : UIButton = {
        let button = UIButton()
//		button.backgroundColor = UIColor.clear
//		button.layer.borderColor = UIColor.white.cgColor
//		button.layer.borderWidth = 0.5
		button.backgroundColor = Colors.learnerPurple
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.font = Fonts.createSize(14)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    var delegate: AddTutorButtonDelegate?
    var uid: String?
    
    func configureTableViewCell() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(addTutorButton)
        
        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        selectedBackgroundView = cellBackground
        
        backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
        addTutorButton.addTarget(self, action: #selector(addTutorButtonPressed(_:)), for: .touchUpInside)

        applyConstraints()
    }
    func applyConstraints() {
        profileImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.15)
            make.height.equalToSuperview().multipliedBy(0.9)
            make.left.equalToSuperview().inset(10)
        }
        addTutorButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.10)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).inset(-20)
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.right.equalTo(addTutorButton.snp.left)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).inset(-20)
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.right.equalTo(addTutorButton.snp.left)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addTutorButton.layer.cornerRadius = addTutorButton.frame.height / 2
        addTutorButton.layer.shadowColor = UIColor.black.cgColor
        addTutorButton.layer.shadowOffset = CGSize(width: 1, height: 2)
        addTutorButton.layer.shadowOpacity = 0.4
        addTutorButton.layer.shadowRadius = 3
    }
    
    @objc func addTutorButtonPressed(_ sender: UIButton) {
        guard let uid = self.uid else { return }
        delegate?.addTutorWithUid(uid)
    }
}
extension AddTutor : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
