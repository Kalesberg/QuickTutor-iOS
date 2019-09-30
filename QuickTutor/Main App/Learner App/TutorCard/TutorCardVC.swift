//
//  TutorCardVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TutorCardVC: UIViewController {
    
    let contentView = TutorCardView()
    var isViewing = false
    var tutor: AWTutor? {
        didSet {
            guard let tutor = tutor else { return }
            contentView.updateUI(tutor)
        }
    }
    var subject: String?
    var actionSheet: FileReportActionsheet?
    
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
        navigationController?.view.backgroundColor = Colors.newScreenBackground
        navigationItem.title = tutor?.username
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
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
        guard let tutor = tutor else { return [] }
        
        var images = [LightboxImage]()
        let existedImages = tutor.images.filter { (_, imageUrl) -> Bool in
            return URL(string: imageUrl) != nil
        }
        let sorted = existedImages.sorted { (arg0, arg1) -> Bool in
            return arg0.key.compare(arg1.key) == .orderedAscending
        }
        images.append(contentsOf: sorted.compactMap({LightboxImage(imageURL: URL(string: $1)!)}))
        
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
    
    func tutorCardHeaderViewDidTapMoreIcon() {
        showActionSheet()
    }
    
    func showActionSheet() {
        if #available(iOS 11.0, *) {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: view.safeAreaInsets.bottom, name: String("Zach"))
        } else {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: 0, name: String("Zach"))
        }
        actionSheet?.partnerId = tutor?.uid
        actionSheet?.parentViewController = self
        actionSheet?.isConnected = contentView.isConnected
        actionSheet?.subject = subject
        actionSheet?.show()
    }
}
