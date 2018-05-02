//
//  AddTutorVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class AddTutorVC: UIViewController, ShowsConversation {
    
    var filteredUsers = [User]()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = . vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.register(AddTutorCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let searchBar: CustomSearchBar = {
        let field = CustomSearchBar()
        field.borderStyle = .none
        field.backgroundColor = .white
        field.keyboardAppearance = .dark
        field.layer.cornerRadius = 17
        return field
    }()
    
    func setupViews() {
        setupMainView()
        setupSearchBar()
        setupCollectionView()
        searchForUsername("Alex")
    }
    
    func setupMainView() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Add Tutor By Username"
        
        let backButtonImage = UIImage(named: "navbar-x")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(popVC))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.backBarButtonItem = backButton
        view.backgroundColor = Colors.darkBackground
    }
    
    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 34)
        searchBar.addTarget(self, action: #selector(textDidChange(sender:)), for: UIControlEvents.editingChanged)
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func popVC() {
		let transition = CATransition()
		let nav = self.navigationController
		
		DispatchQueue.main.async {
			nav?.view.layer.add(transition.popFromTop(), forKey: nil)
			nav?.popViewController(animated: false)
		}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
}

extension AddTutorVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! AddTutorCell
        cell.updateUI(filteredUsers[indexPath.item].uid)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
}

extension AddTutorVC: UICollectionViewDelegate {
    func searchForUsername(_ username: String) {
        self.filteredUsers.removeAll()
        let ref = Database.database().reference().child("tutor-info")
        ref.queryOrdered(byChild: "nm").queryEqual(toValue: username).observeSingleEvent(of: .value) { (snapshot) in
            guard let results = snapshot.value as? [String: Any] else { return }
            results.forEach({ (arg) in
                
                let (key, value) = arg
                guard let uid = Auth.auth().currentUser?.uid, key != uid else { return }
                DataService.shared.getTutorWithId(key, completion: { (tutor) in
                    self.filteredUsers.append(tutor!)
                    
                    self.collectionView.reloadData()
                })
            })
            
        }
    }
}

extension AddTutorVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 131)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension AddTutorVC: UITextFieldDelegate {
    
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text?.lowercased() else { return }
        searchForUsername(text.lowercased())
    }
}

extension AddTutorVC: AddTutorButtonDelegate {

    func addTutorWithUid(_ uid: String) {
        DataService.shared.getTutorWithId(uid) { (tutor) in
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            vc.receiverId = uid
            vc.chatPartner = tutor
            vc.shouldSetupForConnectionRequest = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

protocol ShowsConversation {
    func showConversation(uid: String)
}

extension ShowsConversation {
    func showConversation(uid: String) {
        let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.receiverId = uid
        navigationController.pushViewController(vc, animated: true)
        
    }
}
