//
//  QTConnectTutorTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/7/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

protocol QTConnectTutorTableViewCellDelegate {
    func onClickBtnConnect(_ cell: UITableViewCell, connect tutor: AWTutor)
}

class QTConnectTutorTableViewCell: UITableViewCell {

    var delegate: QTConnectTutorTableViewCellDelegate?
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblTutorName: UILabel!
    @IBOutlet weak var lblTutorFeaturedSubject: UILabel!
    @IBOutlet weak var btnConnect: DimmableButton!
    
    private var objTutor: AWTutor?
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTConnectTutorTableViewCell.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTConnectTutorTableViewCell.self)
    }
    
    func setView(_ objTutor: AWTutor) {
        if isSkeletonActive {
            hideSkeleton()
        }
        
        self.objTutor = objTutor
        
        imgAvatar.sd_setImage(with: objTutor.profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        lblTutorName.text = objTutor.formattedName
        lblTutorFeaturedSubject.text = objTutor.featuredSubject
        
        btnConnect.isHidden = false
    }

    @IBAction func onClickBtnConnect(_ sender: Any) {
        guard let objTutor = objTutor else { return }
        
        delegate?.onClickBtnConnect(self, connect: objTutor)
    }
}
