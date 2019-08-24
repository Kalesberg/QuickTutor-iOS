//
//  QTProfileVideoCollectionViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/23.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import AVKit
import Lottie

protocol QTProfileVideoCollectionViewCellDelegate {
    func collectionViewCell (_ cell: QTProfileVideoCollectionViewCell, didTapUploadAt index: Int)
    func collectionViewCell (_ cell: QTProfileVideoCollectionViewCell, didTapDeleteAt index: Int)
}


class QTProfileVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var thumbImageView: CustomImageView!
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var optButton: UIButton!
    
    private var video: TutorVideo?
    private var index: Int = -1
    private var player: AVPlayer?
    
    private let LOADING_VIEW_TAG = 1989
    
    var delegate: QTProfileVideoCollectionViewCellDelegate?
    
    static var reuseIdentifier: String {
        return String(describing: QTProfileVideoCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // set container view
        containerView.layer.cornerRadius = 5
        
        // set opertaion button
        optButton.layer.cornerRadius = 25
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = player, (object as? AVPlayer) == player, keyPath == "status" {
            if player.status == .readyToPlay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.removeLoadingView()
                }
            } else if player.status == .failed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.removeLoadingView()
                }
            }
        }
    }
    
    // MARK: - Event Handlers
    @IBAction func onClickPlay(_ sender: Any) {
        guard let player = player else { return }
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        
        if let layers = playerView.layer.sublayers?
            .filter({ $0 is AVPlayerLayer }) {
            layers.forEach { $0.removeFromSuperlayer() }
        } else {
            addLoadingView()
            player.addObserver(self, forKeyPath: "status", options: [], context: nil)
        }
        playerView.layer.addSublayer(playerLayer)
        
        player.play()
        overlayView.isHidden = true
    }
    
    @IBAction func onClickUpload(_ sender: Any) {
        delegate?.collectionViewCell(self, didTapUploadAt: index)
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        delegate?.collectionViewCell(self, didTapDeleteAt: index)
    }
    
    @IBAction func onClickOperation(_ sender: Any) {
        onClickPlay(sender)
    }
    
    // MAR: - Set Data Handler
    func setData (video: TutorVideo?, index: Int, isEditMode: Bool) {
        self.video = video
        self.index = index
        
        if let video = video {
            if isEditMode {
                uploadButton.superview?.isHidden = true
                playButton.superview?.isHidden = false
                deleteButton.superview?.isHidden = false
                optButton.superview?.isHidden = true
            } else {
                uploadButton.superview?.isHidden = true
                playButton.superview?.isHidden = true
                deleteButton.superview?.isHidden = true
                optButton.superview?.isHidden = false
            }
            
            // video thumb image
            if let thumb = video.thumbUrl, !thumb.isEmpty {
                thumbImageView.loadImage(urlString: thumb)
            } else {
                thumbImageView.image = video.thumbImage
            }
            
            // set player view
            guard let videoUrl = URL(string: video.videoUrl) else { return }
            player = AVPlayer(url: videoUrl)
            NotificationCenter.default.addObserver(self, selector: #selector(pause), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            
        } else {
            uploadButton.superview?.isHidden = false
            playButton.superview?.isHidden = true
            deleteButton.superview?.isHidden = true
            optButton.superview?.isHidden = true
        }
    }
    
    private func addLoadingView () {
        // load animation view
        let loadingView = LOTAnimationView(name: "video-loading")
        loadingView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        loadingView.center = center.applying(CGAffineTransform(translationX: 0, y: 0))
        loadingView.contentMode = .scaleAspectFill
        loadingView.loopAnimation = true
        loadingView.animationSpeed = 1
        loadingView.tag = LOADING_VIEW_TAG
        
        containerView.addSubview(loadingView)
        loadingView.play()
    }
    
    private func removeLoadingView () {
        guard let loadingView = viewWithTag(LOADING_VIEW_TAG) as? LOTAnimationView else { return }
        loadingView.stop()
        loadingView.removeFromSuperview()
        player?.removeObserver(self, forKeyPath: "status")
    }
    
    // MARK: - Notification Handler
    @objc
    func pause () {
        player?.pause()
        player?.seek(to: .zero)
        overlayView.isHidden = false
    }
}
