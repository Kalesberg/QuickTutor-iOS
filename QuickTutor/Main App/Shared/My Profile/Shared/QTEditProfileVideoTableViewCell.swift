//
//  QTEditProfileVideoTableViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/23.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit


class QTEditProfileVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var videos: [TutorVideo] = []
    var delegate: QTProfileVideoCollectionViewCellDelegate?
    
    static var reuseIdentifier: String {
        return String(describing: QTEditProfileVideoTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(QTProfileVideoCollectionViewCell.nib, forCellWithReuseIdentifier: QTProfileVideoCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func insertVideo (_ index: Int, video: TutorVideo) {
        guard index >= 0 else { return }
        self.videos.append(video)
        collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func deleteVideo(_ index: Int) {
        guard index >= 0 else { return }
        self.videos.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension QTEditProfileVideoTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        if videos.count == 0 {
            return CGSize(width: width - 40, height: height)
        } else {
            return CGSize(width: width / 2, height: height)
        }
    }
}

extension QTEditProfileVideoTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTProfileVideoCollectionViewCell.reuseIdentifier, for: indexPath) as! QTProfileVideoCollectionViewCell
        if indexPath.item == videos.count {
            cell.setData(video: nil, isEditMode: true)
        } else {
            cell.setData(video: videos[indexPath.item], isEditMode: true)
        }
        cell.delegate = delegate
        return cell
    }
}

extension QTEditProfileVideoTableViewCell: UICollectionViewDelegate {
}
