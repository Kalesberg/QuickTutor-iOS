//
//  QTTutorDiscoverShareViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTTutorDiscoverShareViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var shareUrlLabel: UILabel!
    @IBOutlet weak var copyLinkButton: QTCustomButton!
    @IBOutlet weak var shareButton: QTCustomButton!
    
    var user: AWTutor!
    
    // MARK: - Functions
    func setData() {
        
        guard let userId = AccountService.shared.currentUser.uid else { return }
        
        avatarImageView.isSkeletonable = true
        shareUrlLabel.isSkeletonable = true
        shareUrlLabel.linesCornerRadius = 5
        copyLinkButton.isSkeletonable = true
        shareButton.isSkeletonable = true
        
        self.view.showSkeleton(usingColor: Colors.gray)
        UserFetchService.shared.getTutorWithId(uid: userId) { (tutor) in
            self.user = tutor
            self.avatarImageView.sd_setImage(with: tutor?.profilePicUrl)
            self.shareUrlLabel.text = "https://quicktutor.com/\(self.user.username ?? "")"
            
            if self.view.isSkeletonActive {
                self.view.hideSkeleton()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func onCopyLinkButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.tutorShareUrlCopied, object: nil)
    }
    
    @IBAction func onShareButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.tutorShareProfileTapped, object: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setData()
    }
}
