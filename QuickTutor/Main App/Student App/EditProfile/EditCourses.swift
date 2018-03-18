//
//  EditCourses.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class EditCoursesView : EditProfileMainLayout {
  
    var infoLabel = LeftTextLabel()
    var addCourseButton = AddCourseButton()
    
    override func configureView() {
        addSubview(infoLabel)
        addSubview(addCourseButton)
        super.configureView()
        
        title.label.text = "Courses"
        titleLabel.label.text = "Add Course Codes"
        
        let attributedString = NSMutableAttributedString(string: "·  Insert your current course codes.\n·  This can be a helpful reference for tutors.\n·  Maximum of 10 courses.")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        infoLabel.label.attributedText = attributedString;
        infoLabel.label.font = Fonts.createSize(14)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.width.equalTo(titleLabel)
            make.centerX.equalToSuperview()
        }
        
        addCourseButton.snp.makeConstraints { (make) in
            make.width.equalTo(infoLabel)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalTo(infoLabel.snp.bottom)
        }
    }
}

class AddCourseButton : InteractableView, Interactable {
    
    var plusImage = UIImageView()
    var label = UILabel()
    
    override func configureView() {
        addSubview(plusImage)
        addSubview(label)
        super.configureView()
        
        plusImage.image = UIImage(named: "add-image-profile")
        
        label.text = "Add a new course"
        label.font = Fonts.createSize(14)
        label.textColor = Colors.green
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        plusImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
        }
    }
    
    func touchStart() {
        plusImage.alpha = 0.7
        label.alpha = 0.7
    }
    
    func didDragOff() {
        plusImage.alpha = 1.0
        label.alpha = 0.7
    }
}

class EditCourses : BaseViewController {
    
    override var contentView: EditCoursesView {
        return view as! EditCoursesView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func loadView() {
        view = EditCoursesView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //contentView.searchBar.becomeFirstResponder()
    }
    
    override func handleNavigation() {
        if(touchStartView == contentView.addCourseButton) {
            
        }
    }
}
