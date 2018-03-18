//
//  TutorAddSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorAddSubjectsView : MainLayoutOneButton {
    
    var searchBar = UISearchBar()
    var backButton = NavbarButtonBack()
    override var leftButton: NavbarButton {
        get {
            return backButton
        } set {
            backButton = newValue as! NavbarButtonBack
        }
    }
    
    override func configureView() {
        navbar.addSubview(leftButton)
        navbar.addSubview(searchBar)
        super.configureView()
        
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage(color: UIColor.clear)
        
        
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.font = Fonts.createSize(18)
        textField?.textColor = .white
        textField?.adjustsFontSizeToFitWidth = true
        textField?.autocapitalizationType = .words
        textField?.attributedPlaceholder = NSAttributedString(string: "Subjects I Teach", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        textField?.keyboardAppearance = .dark
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        leftButton.allignLeft()
        
        searchBar.snp.makeConstraints { (make) in
            make.height.equalTo(55)
            make.left.equalTo(leftButton.snp.right).inset(5)
            make.right.equalToSuperview().inset(5)
            make.centerY.equalTo(backButton).inset(6)
        }
    }
}


class TutorAddSubjects : BaseViewController {
    
    override var contentView: TutorAddSubjectsView {
        return view as! TutorAddSubjectsView
    }
    override func loadView() {
        view = TutorAddSubjectsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.searchBar.becomeFirstResponder()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
