//
//  CustomSearchBar.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CustomSearchBar: PaddedTextField {
    let searchIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "searchIcon-1"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        }

        set {}
    }

    func setupViews() {
        setupSearchIcon()
        font = Fonts.createSize(14)
        clearButtonMode = .whileEditing
    }

    func setupSearchIcon() {
        addSubview(searchIcon)
        searchIcon.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 7, paddingLeft: 10, paddingBottom: 7, paddingRight: 0, width: 20, height: 0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
