//
//  QTChatVideoPlayerViewController.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/24.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import AVKit
import Photos

class QTChatVideoPlayerViewController: AVPlayerViewController {
    
    var videoUrl: URL!
    
    private var shareButtonView: UIView!
    private var shareButtonImageView: UIImageView!
    
    private var playerItemContext = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // share button
        let left = DeviceInfo.statusbarHeight == 40 ? 28.0 : 8.0
        let top = DeviceInfo.statusbarHeight == 40 ? 70.0 : 60.0
        shareButtonView = UIView(frame: CGRect(x: left, y: DeviceInfo.statusbarHeight + top, width: 60, height: 48))
        shareButtonView.layer.cornerRadius = 18
        shareButtonView.backgroundColor = UIColor(hex: "252626")
        contentOverlayView?.addSubview(shareButtonView)
        
        // button image
        shareButtonImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        shareButtonImageView.image = UIImage(named: "ic_save_media")
        shareButtonImageView.center = CGPoint(x: 30, y: 24)
        shareButtonView.addSubview(shareButtonImageView)
        
        // share button hidden
        player?.currentItem?.addObserver(self,
                                         forKeyPath: #keyPath(AVPlayerItem.status),
                                         options: [.old, .new],
                                         context: &playerItemContext)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cacheDir = getCacheDir(), FileManager.default.fileExists(atPath: cacheDir) {
            do {
                try FileManager.default.removeItem(atPath: cacheDir)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if self.shareButtonView.isHidden == false {
                        self.shareButtonAnimation()
                    }
                }
            case .failed:
                break
            case .unknown:
                break
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: contentOverlayView) else { return }
        if shareButtonView.frame.contains(location) {
            UIView.animate(withDuration: 0.1) {
                var frame = self.shareButtonImageView.frame
                frame.size.width = 19
                frame.size.height = 19
                self.shareButtonImageView.frame = frame
                self.shareButtonImageView.center = CGPoint(x: 30, y: 24)
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        shareButtonAnimation()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let location = touches.first?.location(in: contentOverlayView) else { return }
        if shareButtonView.frame.contains(location) {
            onClickShare ()
            UIView.animate(withDuration: 0.1) {
                var frame = self.shareButtonImageView.frame
                frame.size.width = 24
                frame.size.height = 24
                self.shareButtonImageView.frame = frame
                self.shareButtonImageView.center = CGPoint(x: 30, y: 24)
            }
        }
        shareButtonAnimation()
    }
    
    private func shareButtonAnimation () {
        if self.shareButtonView.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.shareButtonView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.shareButtonView.isHidden = true
            }
        }
    }
    
    // MARK: - Event Handler
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
    
    // MARK: - Notification Handler
    @objc
    private func pause () {
        UIView.animate(withDuration: 0.3) {
            self.shareButtonView.isHidden = false
        }
    }
}
