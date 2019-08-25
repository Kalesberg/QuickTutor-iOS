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
    func collectionViewCell (_ cell: QTProfileVideoCollectionViewCell, didTapUpload video: TutorVideo?)
    func collectionViewCell (_ cell: QTProfileVideoCollectionViewCell, didTapDelete video: TutorVideo?)
    func collectionViewCell (_ cell: QTProfileVideoCollectionViewCell, didTapPlay video: TutorVideo?)
}


class QTProfileVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var thumbImageView: CustomImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var optButton: UIButton!
    
    private var video: TutorVideo?
    
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
    
    // MARK: - Event Handlers
    @IBAction func onClickPlay(_ sender: Any) {
        delegate?.collectionViewCell(self, didTapPlay: video)
    }
    
    @IBAction func onClickUpload(_ sender: Any) {
        delegate?.collectionViewCell(self, didTapUpload: nil)
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        delegate?.collectionViewCell(self, didTapDelete: video)
    }
    
    @IBAction func onClickOperation(_ sender: Any) {
        
    }
    
    // MAR: - Set Data Handler
    func setData (video: TutorVideo?, isEditMode: Bool) {
        self.video = video
        
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
        } else {
            uploadButton.superview?.isHidden = false
            playButton.superview?.isHidden = true
            deleteButton.superview?.isHidden = true
            optButton.superview?.isHidden = true
            thumbImageView.image = nil
        }
    }
}
