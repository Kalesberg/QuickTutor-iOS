//
//  MainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class MainPageVC: BaseViewController {
    
    override var contentView: MainPageVCView {
        return view as! MainPageVCView
    }

    override func loadView() {
        view = MainPageVCView()
    }

    let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    var parentPageViewController: PageViewController?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        contentView.addGestureRecognizer(gestureRecognizer)
        AccountService.shared.updateFCMTokenIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSideBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        contentView.sidebar.profileView.profilePicView.sd_setImage(with: storageRef.child("student-info").child(uid).child("student-profile-pic1"), placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        contentView.sidebar.profileView.profilePicView.layer.cornerRadius = contentView.sidebar.profileView.profilePicView.frame.height / 2
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if (gestureRecognizer.state == .began || gestureRecognizer.state == .changed) && contentView.sidebar.isUserInteractionEnabled == true {
            let translation = gestureRecognizer.translation(in: view)

            let sidebar = contentView.sidebar

            // restrict moving past the boundaries of left side of screen
            if sidebar.frame.minX == 0 && translation.x >= 0.0 {
                return
            }

            // snap the left side of sidebar to left side of screen when the translation would cause the sidebar to move past the left side of the screen
            if sidebar.frame.minX + translation.x > 0.0 {
                sidebar.center.x -= sidebar.frame.minX
                return
            }

            // move sidebar
            sidebar.center.x = sidebar.center.x + translation.x
            gestureRecognizer.setTranslation(CGPoint.zero, in: view)

        } else if gestureRecognizer.state == .ended {
            if contentView.sidebar.frame.maxX < UIScreen.main.bounds.width / 1.7 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.sidebar.center.x -= self.contentView.sidebar.frame.maxX
                    self.hideBackground()
                }) { _ in
                    self.contentView.sidebar.isUserInteractionEnabled = false
                    self.contentView.sidebar.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.sidebar.center.x -= self.contentView.sidebar.frame.minX
                })
            }
        }
    }

    func updateSideBar() {}

    override func handleNavigation() {
        if touchStartView == contentView.messagesButton {
            let vc = MessagesVC()
            vc.parentPageViewController = parentPageViewController
            parentPageViewController?.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
    }

    internal func showSidebar() {
        contentView.sidebar.alpha = 1.0
        contentView.sidebar.isUserInteractionEnabled = true
    }

    internal func showBackground() {
        contentView.backgroundView.fadeIn(withDuration: 0.4, alpha: 0.75)
        contentView.backgroundView.isUserInteractionEnabled = true
    }

    internal func hideSidebar() {
        contentView.sidebar.fadeOut(withDuration: 0.2)
        contentView.sidebar.isUserInteractionEnabled = true
    }

    internal func hideBackground() {
        contentView.backgroundView.fadeOut(withDuration: 0.4)
        contentView.backgroundView.isUserInteractionEnabled = false
    }
}

extension MainPageVC: PageObservation {
    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
    }
}
