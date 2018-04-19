//
//  InPersonSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class InPersonSessionVC: UIViewController {
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = Colors.navBarColor
        removeStartData()
    }
}

