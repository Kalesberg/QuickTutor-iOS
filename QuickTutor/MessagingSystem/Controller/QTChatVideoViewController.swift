//
//  QTChatVideoViewController.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/22.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import MobilePlayer
import SnapKit
import Firebase
import Photos

class QTChatVideoViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    private var messageId: String!
    private var videoUrl: URL!
    private var playerVC: MobilePlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create player view controller
        playerVC = MobilePlayerViewController(contentURL: videoUrl)
        playerVC.activityItems = [videoUrl]
        
        (playerVC.getViewForElementWithIdentifier("close") as? UIButton)?.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        (playerVC.getViewForElementWithIdentifier("action") as? UIButton)?.addTarget(self, action: #selector(onClickShare), for: .touchUpInside)
        
        // add player controller
        addChild(playerVC)
        containerView.addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { make in
            make.width.height.equalTo(self.containerView)
            make.center.equalTo(self.containerView)
        }
    }

    class func new (messageId: String, videoUrl: URL) -> QTChatVideoViewController {
        let vc = QTChatVideoViewController (nibName: "QTChatVideoViewController", bundle: nil)
        vc.videoUrl = videoUrl
        vc.messageId = messageId
        return vc
    }
    
    // MARK: - Event Handler
    @objc
    private func onClickClose () {
        if let cacheDir = getCacheDir(), FileManager.default.fileExists(atPath: cacheDir) {
            do {
                try FileManager.default.removeItem(atPath: cacheDir)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func onClickShare () {
        let actionSheet = UIAlertController(title: "Save Video", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Save to Album", style: .default, handler: { action in
            self.saveVideo ()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Donwload Handlers
    private func getCacheDir () -> String? {
        guard let cacheDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        guard let cacheDirString = (cacheDir as NSString).strings(byAppendingPaths: ["chat-video"]).first else {
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: cacheDirString) {
            do {
                try FileManager.default.createDirectory(atPath: cacheDirString,
                                                        withIntermediateDirectories: false,
                                                        attributes: nil)
                return cacheDirString
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
        return cacheDirString
    }
    
    // MARK: - Save Video Handler
    private func saveVideo () {
        displayLoadingOverlay()
        DispatchQueue.global(qos: .background).async {
            if let urlData = NSData(contentsOf: self.videoUrl),
                let cacheDir = self.getCacheDir(),
                let path = (cacheDir as NSString).strings(byAppendingPaths: ["tmp-video.mp4"]).first {
                DispatchQueue.main.async {
                    urlData.write(toFile: path, atomically: true)
                    if let cacheURL = URL(string: path) {
                        PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                            // check if user authorized access photos for your app
                            if authorizationStatus == .authorized {
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: cacheURL)}) { completed, error in
                                        if let error = error {
                                            self.showErrorMessage(error.localizedDescription)
                                        } else if completed {
                                            self.showMessage("Saved video")
                                        }
                                }
                            }
                        })
                    } else {
                        self.showErrorMessage("Cannot get video path!")
                    }
                }
            }
        }
    }
    
    private func showErrorMessage (_ error: String) {
        DispatchQueue.main.async {
            self.dismissOverlay()
            
            let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showMessage (_ message: String) {
        DispatchQueue.main.async {
            self.dismissOverlay()
            
            let alert = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
