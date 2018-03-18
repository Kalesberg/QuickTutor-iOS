//
//  TutorInformationPacket.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth

class TutorInformationPacket: UIViewController {
	
	let user = Auth.auth().currentUser!
	
	@IBOutlet weak var nextButtonOutlet: UIButton!
	@IBOutlet weak var backButtonOutlet: UIButton!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	//    @objc func nextButtonAction(_ sender: Any) {
	//        if Tutor.shared.uploadTutor(userId: user.uid){
	//            present(StoryboardSwitch.sharedManager.switchTo(storyboard: "Tutor" , viewcontroller: Constants.TUTOR_MAIN_PAGE_VC), animated: true, completion: nil)
	//            self.navigationController!.viewControllers.removeAll()
	//        }else{
	//            print("Oops!")
	//        }
	//    }
	
}

