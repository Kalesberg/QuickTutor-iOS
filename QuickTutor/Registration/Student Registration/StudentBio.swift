////
////  StudentBio.swift
////  QuickTutor
////
////  Created by QuickTutor on 1/9/18.
////  Copyright © 2018 QuickTutor. All rights reserved.
////
//
//import UIKit
//import SnapKit
//
//class StudentBioView : BioView {
//    
//    var skipButton = SkipButton()
//    
//    override func configureView() {
//        super.configureView()
//        contentView.addSubview(skipButton)
//        
//        navBar.progress = 1.0
//        navBar.applyConstraints()
//        
//        applyConstraints()
//    }
//    
//    override func applyConstraints() {
//        super.applyConstraints()
//        
//        skipButton.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().inset(10)
//            make.height.equalTo(characterCount)
//            make.top.equalTo(bioTextView.snp.bottom)
//        }
//    }
//}
//
//
////Interactables
//class SkipButton: BaseView, Interactable {
//    
//    var label = LeftTextLabel()
//    
//    override func configureView() {
//        addSubview(label)
//        
//        label.label.text = "Skip this step »"
//        label.label.font = Fonts.createSize(18)
//        
//        applyConstraints()
//    }
//    
//    override func applyConstraints() {
//        label.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//    }
//    
////    override func touchStart() {
////        alpha = 0.7
////    }
////    
////    override func didDragOff() {
////        alpha = 1.0
////    }
////    
////    override func didDragOn() {
////        touchStart()
////    }
////    
////    override func touchEndOnStart() {
////        didDragOff()
////    }
//}
//
//class StudentBio: BaseViewController {
//    
//    override var contentView: StudentBioView {
//        return view as! StudentBioView
//    }
//    
//    override func loadView() {
//        view = StudentBioView()
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        contentView.bioTextView.textView.becomeFirstResponder()
//    }
//    
//    override func handleNavigation() {
//        if (touchStartView == contentView.backButton) {
//            navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
//            navigationController!.popViewController(animated: false)
//        } else if (touchStartView == contentView.nextButton) {
//            if contentView.bioTextView.textView.text.count <= 150 {
//              //  Registration.studentBio = contentView.bioTextView.textView.text!
//                navigationController!.pushViewController(UserPolicy(), animated: true)
//            } else {
//                print("Error: Too many characters")
//            }
//        } else if (touchStartView == contentView.skipButton) {
//            //Registration.studentBio = ""
//            navigationController!.pushViewController(UserPolicy(), animated: true)
//        }
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//}

