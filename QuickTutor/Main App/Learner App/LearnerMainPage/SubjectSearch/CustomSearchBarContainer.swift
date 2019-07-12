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
    func customSearchBarDidTapFiltersButton(_ searchBar: PaddedTextField)
    func customSearchBarDidTapCancelEditButton(_ searchBar: PaddedTextField)
    func customSearchBarDidTapClearButton(_ searchBar: PaddedTextField)
}

extension CustomSearchBarDelegate {
    func customSearchBarDidTapMockLeftView(_ searchBar: PaddedTextField) {}
    func customSearchBarDidTapFiltersButton(_ searchBar: PaddedTextField) {}
}

class CustomSearchBarContainer: UIView {
    
    weak var delegate: CustomSearchBarDelegate?
    var isEditing = false
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.newScreenBackground
        return view
    }()
    
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
        field.clearButtonMode = .never
        field.tintColor = .white
        field.autocorrectionType = .no
        return field
    }()
    
    let mockLeftViewButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"newBackButton"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    let filtersButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"filterIcon"), for: .normal)
        button.contentMode = .scaleAspectFill
        return button
    }()
    
    let searchClearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_search_close"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    let cancelEditingButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.titleLabel?.textAlignment = .center
        button.isHidden = true
        return button
    }()
    
    var searchBarRightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupContainerView()
        setupSearchBar()
        setupSearchClearButton()
        setupMockLeftViewButton()
        setupFiltersButton()
        setupCancelEditingButton()
        setupLeftView()
    }
    
    func setupContainerView() {
        addSubview(containerView)
        containerView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 57)
    }
    
    func setupSearchBar() {
        containerView.addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 10, paddingRight: 20, width: 0, height: 0)
        searchBarRightAnchor = searchBar.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        searchBarRightAnchor?.isActive = true
        searchClearButton.isHidden = true
    }
    
    func setupSearchClearButton() {
        containerView.addSubview(searchClearButton)
        searchClearButton.anchor(top: nil, left: nil, bottom: nil, right: searchBar.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        containerView.addConstraint(NSLayoutConstraint(item: searchClearButton, attribute: .centerY, relatedBy: .equal, toItem: searchBar, attribute: .centerY, multiplier: 1, constant: 0))
        searchClearButton.addTarget(self, action: #selector(handleSearchClearButtonTapped), for: .touchUpInside)
    }
    
    func setupCancelEditingButton() {
        containerView.insertSubview(cancelEditingButton, belowSubview: searchBar)
        cancelEditingButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 70, height: 0)
        cancelEditingButton.addTarget(self, action: #selector(cancelEditing), for: .touchUpInside)
    }
    
    func setupMockLeftViewButton() {
        containerView.addSubview(mockLeftViewButton)
        mockLeftViewButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 9, paddingLeft: 27, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
        mockLeftViewButton.addTarget(self, action: #selector(handleMockLeftViewTapped), for: .touchUpInside)
    }
    
    func setupLeftView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLeftViewTap))
        tap.numberOfTapsRequired = 1
        searchBar.leftView?.addGestureRecognizer(tap)
    }
    
    func setupFiltersButton() {
        containerView.addSubview(filtersButton)
        filtersButton.anchor(top: nil, left: nil, bottom: nil, right: searchBar.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 18, height: 18)
        containerView.addConstraint(NSLayoutConstraint(item: filtersButton, attribute: .centerY, relatedBy: .equal, toItem: searchBar, attribute: .centerY, multiplier: 1, constant: 0))
        filtersButton.addTarget(self, action: #selector(handleFiltersButtonTapped), for: .touchUpInside)
    }
    
    @objc func handleLeftViewTap() {
        delegate?.customSearchBarDidTapLeftView(searchBar)
    }
    
    @objc func handleMockLeftViewTapped() {
        delegate?.customSearchBarDidTapMockLeftView(searchBar)
    }
    
    @objc func handleFiltersButtonTapped() {
        delegate?.customSearchBarDidTapFiltersButton(searchBar)
    }
    
    @objc func handleSearchClearButtonTapped() {
        searchClearButton.isHidden = true
        searchBar.text = ""
        searchBar.becomeFirstResponder()
        delegate?.customSearchBarDidTapClearButton(searchBar)
    }
    
    func showSearchClearButton(_ show: Bool = true) {
        searchClearButton.isHidden = !show
    }
    
    func shouldBeginEditing() {
        isEditing = true
        cancelEditingButton.isHidden = false
        guard searchBarRightAnchor?.constant == 0 else { return }
        self.layoutIfNeeded()
        searchBarRightAnchor?.constant = -70
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        delegate?.customSearchBar(searchBar, shouldBeginEditing: true)
    }
    
    @objc func shouldEndEditing() {
        isEditing = false
        searchBarRightAnchor?.constant = 0
        searchBar.text = nil
        delegate?.customSearchBar(searchBar, shouldEndEditing: true)
    }
    
    @objc func cancelEditing() {
        isEditing = false
        searchBarRightAnchor?.constant = 0
        searchBar.text = nil
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            self.cancelEditingButton.isHidden = true
            self.showSearchClearButton(false)
        }
        delegate?.customSearchBarDidTapCancelEditButton(searchBar)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
