//
//  QTQuickRequestTypeViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTQuickRequestTypeViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var helpView: QTCustomView!
    @IBOutlet weak var onlineTypeView: QTCustomView!
    @IBOutlet weak var inPersonTypeView: QTCustomView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nextButton: QTCustomButton!
    
    var helpAlert: QTQuickRequestAlertModal?
    
    static var controller: QTQuickRequestTypeViewController {
        return QTQuickRequestTypeViewController(nibName: String(describing: QTQuickRequestTypeViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        configureViews()
        setupTargets()
        changeSessionTypeViews()
    }

    // MARK: - Actions
    @IBAction func onClickRequestTypeInfoButtonClicked(_ sender: Any) {
        helpAlert = QTQuickRequestAlertModal(frame: .zero)
        helpAlert?.set("An all-in-one platform.",
                  "QuickTutor has in-app messaging & scheduling, handles all platform transactions and offers in-person meet-ups and instant in-app video-calling.")
        helpAlert?.show()
    }
    
    @IBAction func onNextButtonClicked(_ sender: Any) {
        let vc = QTQuickRequestSubmitViewController.controller
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func handleOnlineTypeViewTapped() {
        QTQuickRequestService.shared.sessionType = .online
        changeSessionTypeViews()
    }
    
    @objc
    func handleInPersonTypeViewTapped() {
        QTQuickRequestService.shared.sessionType = .inPerson
        changeSessionTypeViews()
    }
    
    
    // MARK: - Functions
    func configureViews() {
        title = "Quick Request"
        
        // Set the drop shadow of quick request help view.
        helpView.applyDefaultShadow()
        
        // Set the drop shadow of the bottom view.
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -5)
        bottomView.layer.shadowRadius = 5
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.5
        
    }
    
    func setupTargets() {
        
        onlineTypeView.isUserInteractionEnabled = true
        onlineTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOnlineTypeViewTapped)))
        
        inPersonTypeView.isUserInteractionEnabled = true
        inPersonTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInPersonTypeViewTapped)))
    }
    
    func changeSessionTypeViews() {
        
        switch QTQuickRequestService.shared.sessionType {
        case .online:
            onlineTypeView.borderColor = Colors.purple
            onlineTypeView.borderWidth = 1
            onlineTypeView.backgroundColor = Colors.newScreenBackground
            
            inPersonTypeView.borderWidth = 0
            inPersonTypeView.backgroundColor = .black
        case .inPerson:
            onlineTypeView.borderWidth = 0
            onlineTypeView.backgroundColor = .black
            
            inPersonTypeView.borderColor = Colors.purple
            inPersonTypeView.borderWidth = 1
            inPersonTypeView.backgroundColor = Colors.newScreenBackground
        default:
            break
        }
    }

}
