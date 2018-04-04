//
//  MainLayoutView.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

//TODO Design:
//  - Put shadow in front of elements, not behind them

import Foundation
import UIKit


class SearchLayoutView : BaseLayoutView {
	
	let statusbarView : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.registrationDark
		
		return view
	}()
	
	
	let navbar : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.registrationDark
		view.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: CGSize(width: 0, height: 3.0), radius: 1.0)

		return view
	}()
	
	let searchTextField = AddSubjectSearchField()
	
	var leftButton = NavbarButton()
	
	override func configureView() {
		super.configureView()
		
		insertSubview(statusbarView, at: 0)
		insertSubview(navbar, at: 1)
		
		navbar.addSubview(searchTextField)
		navbar.addSubview(leftButton)
		
		backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		statusbarView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.equalToSuperview()
			make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
		}
		
		navbar.snp.makeConstraints { (make) in
			make.top.equalTo(statusbarView.snp.bottom)
			make.width.equalToSuperview()
			make.height.equalTo(120)
		}
		
		leftButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.height.equalToSuperview().dividedBy(2.6)
			make.width.equalToSuperview().multipliedBy(0.175)
		}

		searchTextField.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().dividedBy(2)
			make.centerX.equalToSuperview()
		}
	}
}

class MainLayoutView: BaseLayoutView {

    var statusbarView = UIView()
    var navbar = UIView()
    
    override func configureView() {
        super.configureView()

        insertSubview(statusbarView, at: 0)
        insertSubview(navbar, at: 1)
        
        backgroundColor = Colors.backgroundDark
    
        statusbarView.backgroundColor = Colors.registrationDark
        
        navbar.backgroundColor = Colors.registrationDark
        navbar.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: CGSize(width: 0, height: 3.0), radius: 1.0)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        statusbarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
        }
        
        navbar.snp.makeConstraints { (make) in
            make.top.equalTo(statusbarView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(70)
        }
    }
}


class MainLayoutOneButton: MainLayoutView {

    var leftButton = NavbarButton()
    
    override func configureView() {
        navbar.addSubview(leftButton)
        super.configureView()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        leftButton.allignLeft()
    }
}


class MainLayoutTwoButton: MainLayoutOneButton {
    
    var rightButton = NavbarButton()
    
    override func configureView() {
        navbar.addSubview(rightButton)
        super.configureView()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        rightButton.allignRight()
    }
}


struct TitleComponent {
    var title = CenterTextLabel()
}

protocol HasTitleComponent {
    var titleComponent: TitleComponent { get set }
}

protocol Titleable: HasTitleComponent where Self: MainLayoutView { }

extension Titleable {
    var title: CenterTextLabel {
        get { return titleComponent.title }
        set { titleComponent.title = newValue }
    }
    
    func addTitle() {
        navbar.addSubview(title)
        
        title.label.font = Fonts.createBoldSize(22)
        title.applyConstraints()
        
        title.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(5)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
    }
}


class MainLayoutTitleOneButton: MainLayoutOneButton, Titleable {
    
    var titleComponent = TitleComponent()
    
    override func configureView() {
        addTitle()
        super.configureView()
    }
}


class MainLayoutTitleTwoButton: MainLayoutTwoButton, Titleable {
    
    var titleComponent = TitleComponent()

    override func configureView() {
        addTitle()
        super.configureView()
    }
}


class MainLayoutTitleBackButton: MainLayoutTitleOneButton {
    
    var backButton = NavbarButtonBack()
    
    override var leftButton: NavbarButton {
        get {
            return backButton
        } set {
            backButton = newValue as! NavbarButtonBack
        }
    }
}


class MainLayoutTitleBackTwoButton: MainLayoutTitleTwoButton {
    
    var backButton = NavbarButtonBack()
    
    override var leftButton: NavbarButton {
        get {
            return backButton
        } set {
            backButton = newValue as! NavbarButtonBack
        }
    }
}

class MainLayoutTitleBackSaveButton: MainLayoutTitleBackTwoButton {
    
    var saveButton = NavbarButtonSave()
    
    override var rightButton: NavbarButton {
        get {
            return saveButton
        } set {
            saveButton = newValue as! NavbarButtonSave
        }
    }
}

class MainLayoutHeader : MainLayoutTitleBackButton {
    
    var header = LeftTextLabel()
    
    override func configureView() {
        addSubview(header)
        super.configureView()
        
        header.label.font = Fonts.createSize(21.5)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        header.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
        
        header.label.snp.remakeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
        }
    }
}

class MainLayoutHeaderScroll : MainLayoutTitleBackButton {
    
    var scrollView = BaseScrollView()
    var header = LeftTextLabel()
    
    override func configureView() {
        addSubview(scrollView)
        scrollView.addSubview(header)
        super.configureView()
        
        header.label.font = Fonts.createSize(22)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        scrollView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        header.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
        
        header.label.snp.remakeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
        }
    }
}
