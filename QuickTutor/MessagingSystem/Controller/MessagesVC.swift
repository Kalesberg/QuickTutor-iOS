//
//  ViewController.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UIViewController {
    
    var messages = [UserMessage]()
    var conversationsDictionary = [String: UserMessage]()
    let refreshControl = UIRefreshControl()
    
    let messagesCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.register(ConversationCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let messageSessionControl: MessagingSystemToggle = {
        let control = MessagingSystemToggle()
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupViews() {
        setupMainView()
        setupMessageSessionControl()
        setupCollectionView()
        setupNavBar()
        setupRefreshControl()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        edgesForExtendedLayout = []
    }
    
    private func setupCollectionView() {
        messagesCV.delegate = self
        messagesCV.dataSource = self
        view.addSubview(messagesCV)
        messagesCV.anchor(top: messageSessionControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 29, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Messages"
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationItem.backBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "newMessageIcon"), style: .plain, target: self, action: #selector(showContacts))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backItem?.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settingsIcon"), style: .plain, target: self, action: #selector(showSettings))
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(fetchConversations), for: .valueChanged)
        messagesCV.refreshControl = refreshControl
    }
    
    private func setupMessageSessionControl() {
        view.addSubview(messageSessionControl)
        messageSessionControl.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 200, paddingLeft: 45, paddingBottom: 0, paddingRight: 45, width: 0, height: 25)
    }
    
    @objc func showContacts() {
        let vc = NewMessageVC()
        vc.delegate = self
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showSettings() {
        let vc = SettingsVC()
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func fetchConversations() {
        conversationsDictionary.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("conversations").child(uid).observe(.childAdded) { snapshot in
            let userId = snapshot.key
            Database.database().reference().child("conversations").child(uid).child(userId).observe(.childAdded, with: { snapshot in
                let messageId = snapshot.key
                self.getMessageById(messageId)
            })
            self.refreshControl.endRefreshing()
        }
    }
    
    func getMessageById(_ messageId: String) {
        Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let message = UserMessage(dictionary: value)
            message.uid = snapshot.key
            self.conversationsDictionary[message.partnerId()] = message
            self.messages = Array(self.conversationsDictionary.values)
            self.messages.sort(by: { $0.timeStamp.intValue > $1.timeStamp.intValue })
            self.messagesCV.reloadData()
        }
    }
}

extension MessagesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = messages[indexPath.item].partnerId()
        let tappedCell = collectionView.cellForItem(at: indexPath) as! ConversationCell
        vc.navigationItem.title = tappedCell.usernameLabel.text
        vc.chatPartner = tappedCell.chatPartner
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MessagesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
        return conversationsDictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? ConversationCell else {
            fatalError("Couldn't get cell for collectionView")
        }
        //        cell.updateUI(message: messages[indexPath.item])
        return cell
    }
}

extension MessagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MessagesVC: NewMessageDelegate {
    func showConversationWithUser(user: User, isConnection: Bool) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = user.uid
        vc.connectionRequestAccepted = isConnection
        vc.chatPartner = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol SegmentedViewDelegate {
    func scrollTo(index: Int)
}

class MessagingSystemToggle: UIView {
    
    var sections = ["Tutors", "Sessions"]
    var delegate: SegmentedViewDelegate?
    
    lazy var cv: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.layer.borderColor = UIColor.white.cgColor
        cv.layer.borderWidth = 0.5
        cv.layer.cornerRadius = 6
        cv.delegate = self
        cv.dataSource = self
        cv.register(MessagingSystemToggleCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    func setupViews() {
        setupCollectionView()
        setupSeparator()
    }
    
    private func setupCollectionView() {
        addSubview(cv)
        cv.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let selectedIndexPath = NSIndexPath(row: 0, section: 0)
        cv.selectItem(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: [])
    }
    
    private func setupSeparator() {
        addSubview(separator)
        separator.anchor(top: cv.topAnchor, left: nil, bottom: cv.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0.5, height: 0)
        addConstraint(NSLayoutConstraint(item: separator, attribute: .centerX, relatedBy: .equal, toItem: cv, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension MessagingSystemToggle: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! MessagingSystemToggleCell
        cell.label.text = sections[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.scrollTo(index: indexPath.item)
    }
}

class MessagingSystemToggleCell: UICollectionViewCell {
    
    var unselectedColor = UIColor.white.withAlphaComponent(0.5)
    var selectedColor = UIColor.white
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createLightSize(15)
        return label
    }()
    
    let gradientLayer: CAGradientLayer = {
        let firstColor = Colors.tutorBlue.cgColor
        let secondColor = Colors.learnerPurple.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 1
        gradientLayer.colors = [firstColor, secondColor]
        
        
        let x: Double! = 90 / 360.0
        let a = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2 * .pi * ((x+0.0)/2))),2);
        let c = pow(sinf(Float(2 * .pi * ((x+0.25)/2))),2);
        let d = pow(sinf(Float(2 * .pi * ((x+0.5)/2))),2);
        
        gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        gradientLayer.locations = [0, 0.7, 0.9, 1]
        gradientLayer.isHidden = true
        return gradientLayer
    }()
    
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? selectedColor : unselectedColor
            gradientLayer.isHidden = !isSelected
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedColor : unselectedColor
            gradientLayer.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        completeSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .clear
        setupLabel()
        setupGradientLayer()
    }
    
    func setupLabel() {
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupGradientLayer() {
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = bounds
    }
    
    func completeSetup() {
        
    }
}

extension MessagesVC: PageObservation {
    func getParentPageViewController(parentRef: PageViewController) {
        
    }
    
    
}

