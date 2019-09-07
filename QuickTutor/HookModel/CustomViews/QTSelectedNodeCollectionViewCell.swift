//
//  QTSelectedNodeCollectionViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/6/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTSelectedNodeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: QTCustomView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var node: Node!
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTSelectedNodeCollectionViewCell.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTSelectedNodeCollectionViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = Colors.newNavigationBarBackground
    }
    
    func setView(_ node: Node) {
        self.node = node
        
        containerView.borderColor = node.strokeColor
        imgIcon.image = node.icon
        lblTitle.text = node.text
    }

}
