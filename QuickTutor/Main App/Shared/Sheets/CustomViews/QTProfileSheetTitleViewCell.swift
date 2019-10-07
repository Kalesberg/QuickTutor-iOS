//
//  QTProfileSheetTitleViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/10/5.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTProfileSheetTitleViewCell: UICollectionViewCell {

    @IBOutlet weak var closeButton: UIButton!
    
    var didClickClose: (() ->())?
    
    static var reuseIdentifier: String {
        return String(describing: QTProfileSheetTitleViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // button image
        closeButton.imageView?.contentMode = .scaleAspectFill
    }
    
    // MARK: - Event Handler
    @IBAction func onClickClose(_ sender: Any) {
        didClickClose?()
    }
}
