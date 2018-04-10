//
//  ProfileVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/26/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    var userId: String!
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let uidLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupUsernameLabel()
        setupUidLabel()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    private func setupUsernameLabel() {
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 300, height: 50)
    }
    
    private func setupUidLabel() {
        view.addSubview(uidLabel)
        uidLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 220, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 300, height: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateUI()
    }
    
    func updateUI() {
        DataService.shared.getUserWithUid(userId) { (userIn) in
            guard let user = userIn else { return }
            self.usernameLabel.text = user.username
            self.uidLabel.text = user.uid
        }
    }
}
