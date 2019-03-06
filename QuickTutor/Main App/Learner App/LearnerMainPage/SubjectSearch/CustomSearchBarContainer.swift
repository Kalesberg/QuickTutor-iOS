//
//  CustomSearchBarContainer.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol CustomSearchBarDelegate: class {
    func customSearchBar(_ searchBar: PaddedTextField, shouldEndEditing: Bool)
    func customSearchBar(_ searchBar: PaddedTextField, shouldBeginEditing: Bool)
    func customSearchBarDidTapLeftView(_ searchBar: PaddedTextField)
    func customSearchBarDidTapMockLeftView(_ searchBar: PaddedTextField)
}

extension CustomSearchBarDelegate {
    func customSearchBarDidTapMockLeftView(_ searchBar: PaddedTextField) {}
}

class CustomSearchBarContainer: UIView {
    
    weak var delegate: CustomSearchBarDelegate?
    var isEditing = false
    
    lazy var searchBar: PaddedTextField = {
        let field = PaddedTextField()
        field.padding.left = 40
        field.backgroundColor = Colors.gray
        field.textColor = .white
        let searchIcon = UIImageView(image: UIImage(named:"searchIconMain"))
        field.leftView = searchIcon
        field.leftView?.transform = CGAffineTransform(translationX: 12.5, y: 0)
        field.leftViewMode = .always
        field.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.75)])
        field.font = Fonts.createBoldSize(16)
        field.layer.cornerRadius = 4
        field.returnKeyType = .search
        field.clearButtonMode = .whileEditing
        field.tintColor = .white
        return field
    }()
    
    let mockLeftViewButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"newBackButton"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    let cancelEditingButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        return button
    }()
    
    var searchBarRightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupSearchBar()
        setupMockLeftViewButton()
        setupCancelEditingButton()
        setupLeftView()
    }
    
    func setupSearchBar() {
        addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        searchBarRightAnchor = searchBar.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        searchBarRightAnchor?.isActive = true
    }
    
    func setupCancelEditingButton() {
        insertSubview(cancelEditingButton, belowSubview: searchBar)
        cancelEditingButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 0)
        cancelEditingButton.addTarget(self, action: #selector(shouldEndEditing), for: .touchUpInside)
    }
    
    func setupMockLeftViewButton() {
        addSubview(mockLeftViewButton)
        mockLeftViewButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 9, paddingLeft: 7, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
        mockLeftViewButton.addTarget(self, action: #selector(handleMockLeftViewTapped), for: .touchUpInside)
    }
    
    func setupLeftView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLeftViewTap))
        tap.numberOfTapsRequired = 1
        searchBar.leftView?.addGestureRecognizer(tap)
    }
    
    @objc func handleLeftViewTap() {
        delegate?.customSearchBarDidTapLeftView(searchBar)
    }
    
    @objc func handleMockLeftViewTapped() {
        delegate?.customSearchBarDidTapMockLeftView(searchBar)
    }
    
    func shouldBeginEditing() {
        isEditing = true
        guard searchBarRightAnchor?.constant == 0 else { return }
        searchBarRightAnchor?.constant = -60
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
        }
        delegate?.customSearchBar(searchBar, shouldBeginEditing: true)
    }
    
    @objc func shouldEndEditing() {
        isEditing = false
        searchBarRightAnchor?.constant = 0
        searchBar.text = nil
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        delegate?.customSearchBar(searchBar, shouldEndEditing: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
