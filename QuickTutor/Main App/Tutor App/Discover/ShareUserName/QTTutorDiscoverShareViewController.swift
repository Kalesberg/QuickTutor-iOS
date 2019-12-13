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
    @IBOutlet weak var containerView: QTCustomView!
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var shareUrlLabel: UILabel!
    @IBOutlet weak var copyLinkButton: QTCustomButton!
    @IBOutlet weak var shareButton: QTCustomButton!
    
    var user: AWTutor!
    
    // MARK: - Functions
    func configureViews() {
        copyLinkButton.backgroundColor = Colors.purple
        shareButton.backgroundColor = Colors.orange
    }
    
    func setSkeletonView() {
        avatarImageView.isSkeletonable = true
        shareUrlLabel.isSkeletonable = true
        shareUrlLabel.linesCornerRadius = 5
        copyLinkButton.isSkeletonable = true
        shareButton.isSkeletonable = true
        self.view.isSkeletonable = true
        self.containerView.isSkeletonable = true
        
        self.view.showSkeleton(usingColor: Colors.gray)
    }
    
    func setData() {
        
        if AccountService.shared.currentUser == nil {
            return
        }
        
        guard let userId = AccountService.shared.currentUser.uid else { return }
        
        UserFetchService.shared.getTutorWithId(uid: userId) { (tutor) in
            if self.view.isSkeletonActive {
                self.view.hideSkeleton()
            }
            self.user = tutor
            self.avatarImageView.sd_setImage(with: tutor?.profilePicUrl)
            self.shareUrlLabel.text = "https://quicktutor.com/\(self.user.username ?? "")"
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

        configureViews()
        setSkeletonView()
        setData()
    }
}
