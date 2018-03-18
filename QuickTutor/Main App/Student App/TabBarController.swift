//
//  TabBarController.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewControllers = [MainPage(), EditBio()]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
