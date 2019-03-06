//
//  TutorCardVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorCardVC: UIViewController {
    
    let contentView = TutorCardView()
    var tutor: AWTutor?
    var subject: String?
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        contentView.tutor = tutor
        contentView.headerView.subjectLabel.text = subject
        contentView.parentViewController = self
        contentView.headerView.delegate = self
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isHidden = false
        navigationController?.view.backgroundColor = Colors.darkBackground
        navigationItem.title = tutor?.username
    }
    
    func showMessageVC() {
        let vc = ConversationVC()
        vc.receiverId = tutor?.uid
        vc.chatPartner = tutor
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TutorCardVC: TutorCardHeaderViewDelegate {
    func tutorCardHeaderViewDidTapProfilePicture(_ tutorCard: TutorCardHeaderView) {
        let images = createLightBoxImages()
        presentLightBox(images)
    }
    
    func createLightBoxImages() -> [LightboxImage] {
        var images = [LightboxImage]()
        tutor?.images.forEach({ (arg) in
            let (_, imageUrl) = arg
            guard let url = URL(string: imageUrl) else { return }
            images.append(LightboxImage(imageURL: url))
        })
        return images
    }
    
    func presentLightBox(_ images: [LightboxImage]) {
        let controller = LightboxController(images: images, startIndex: 0)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    func tutorCardHeaderViewDidTapMessageIcon() {
        showMessageVC()
    }
}
