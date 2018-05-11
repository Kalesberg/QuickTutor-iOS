//
//  RegistrationNextButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class RegistrationNextButton: BaseView, Interactable {

    var image : UIImageView = {
        let image = UIImageView()
        
        image.image = #imageLiteral(resourceName: "next-button")
        
        return image
    }()
    
    override func configureView() {
        addSubview(image)

        applyConstraints()
    }
    
    override func applyConstraints() {
        image.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }
    
    func touchStart() {
        image.snp.updateConstraints { (make) in
            make.width.height.equalTo(40)
        }
        
        needsUpdateConstraints()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func didDragOff() {
        image.snp.updateConstraints { (make) in
            make.width.height.equalTo(35)
        }
        
        needsUpdateConstraints()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }
}
