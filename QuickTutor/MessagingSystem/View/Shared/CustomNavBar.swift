//
//  CustomNavBar.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/8/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class CustomNavBar: UINavigationBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = Colors.navBarColor
        heightAnchor.constraint(equalToConstant: 300).isActive = true
    }    
}

protocol CustomNavBarDisplay: class  {
    func updateNavBar()
}

extension CustomNavBarDisplay where Self: UIViewController {
    func updateNavBar() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 22))
        
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(searchBar)
        searchBar.isUserInteractionEnabled = true
        
        
        let leftButtonWidth: CGFloat = 35 // left padding
        let rightButtonWidth: CGFloat = 75 // right padding
        let width = view.frame.width - leftButtonWidth - rightButtonWidth
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: container.topAnchor, constant: -4),
            searchBar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            searchBar.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: 0),
            searchBar.widthAnchor.constraint(equalToConstant: width)
        ])
        
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.titleView = container
    }
}


