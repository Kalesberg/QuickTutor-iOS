//
//  Interactables.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol Interactable {
    func touchStart()
    func draggingOn()
    func didDragOff()
    func draggingOff()
    func didDragOn()
    func touchEndOnStart()
    func touchEndOffStart()
    func touchCancelled()
}

//Set default behavior for Interactable, they do nothing :)
extension Interactable {
    func touchStart() {}
    func draggingOn() {}
    func didDragOff() {}
    func draggingOff() {}
    func didDragOn() { touchStart() }
    func touchEndOnStart() { didDragOff() }
    func touchEndOffStart() { didDragOff() }
    func touchCancelled() { didDragOff() }
}

//An Interactable that adds an additional view that is the same size as the parent
protocol InteractableBackground: Interactable, HasBackgroundComponent where Self: UIView { }

//Default behaviors for an InteractableBackground, we're essentially "overriding" the default behaviors that was set in the Interactable extension (the ones that do nothing)
extension InteractableBackground {
    var backgroundView: UIView {
        get { return backgroundComponent.view }
        set { backgroundComponent.view = newValue }
    }
    
    func addBackgroundView() {
        addSubview(backgroundView)
        
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0
        backgroundView.isUserInteractionEnabled = false
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func touchStart() { backgroundView.fadeIn(withDuration: 0.2, alpha: 0.3) }
    func didDragOff() { backgroundView.fadeOut(withDuration: 0.2) }
}


//Instantiate this when you don't need to make a subclass for an interactable (i.e. when the interactable needs no responsiveness)
class InteractableObject: UIView, Interactable {}

//Subclass this for a view that is already an Interactable
class InteractableView: BaseView { override func configureView() { } }

//Subclass this for a view that is already an Interactable and includes a background view
class InteractableBackgroundView: BaseView, InteractableBackground {
    var backgroundComponent = ViewComponent()
    override func configureView() { addBackgroundView() }
}


//Components
struct ViewComponent {
    var view = UIView()
}

//Component protocols
protocol HasBackgroundComponent { var backgroundComponent: ViewComponent { get set } }
protocol HasKeyboardComponent { var keyboardComponent: ViewComponent { get set } }

//Adds an additional blank view that is the size of the keyboard
protocol Keyboardable: HasKeyboardComponent where Self: UIView { }

extension Keyboardable {
    var keyboardView: UIView {
        get { return keyboardComponent.view }
        set { keyboardComponent.view = newValue }
    }
    
    func addKeyboardView() {
        addSubview(keyboardView)
        
        keyboardView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(0)
            make.height.equalTo(DeviceInfo.keyboardHeight)
        }
    }
}
