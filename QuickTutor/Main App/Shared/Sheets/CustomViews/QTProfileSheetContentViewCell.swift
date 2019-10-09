//
//  QTProfileSheetContentViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/10/5.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol QTProfileSheetContentViewCellDelegate {
    func profileSheetContentViewDidSelect(_ contentViewCell: QTProfileSheetContentViewCell)
}

class QTProfileSheetContentViewCell: UICollectionViewCell {

    @IBOutlet weak var button: DimmableButton!
    
    var delegate: QTProfileSheetContentViewCellDelegate?
    
    static var reuseIdentifier: String {
        return String(describing: QTProfileSheetContentViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }

    // MARK: - Event Handler
    @IBAction func onClickButton(_ sender: Any) {
        delegate?.profileSheetContentViewDidSelect(self)
    }
}
