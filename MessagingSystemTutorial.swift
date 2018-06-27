//
//  MessagingSystemTutorial.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class MessagingSystemTutorial : UIButton {
    
    let view : UIButton = {
        let view = UIButton()
        view.backgroundColor = Colors.purple
        view.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        view.applyDefaultShadow()
        view.layer.cornerRadius = 17
        view.isUserInteractionEnabled = false
        view.alpha = 0
        return view
    }()
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        
        return label
    }()
    
    let image : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "finger")
        view.transform = CGAffineTransform(scaleX: 1, y: -1)
        view.scaleImage()
        view.alpha = 0
        
        return view
    }()
    
    var count : Int = 0
    
    let phrases = ["Your first message is a connection request. Write something friendly!", "You can continue messaging the tutor once they have accepted your connection request.", "Once they accept your connection request, you can use this button to schedule sessions or send images!"]
    
    required init() {
        super.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        addSubview(view)
        addSubview(label)
        addSubview(image)
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        alpha = 0
        label.text = phrases[0]
        applyConstraints()
    }
    
    func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(15)
            make.center.equalToSuperview()
        }
        
        view.anchor(top: nil, left: self.leftAnchor, bottom: self.getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 34, height: 34)
        
        image.anchor(top: nil, left: self.leftAnchor, bottom: view.topAnchor, right: nil, paddingTop: 0, paddingLeft: 1, paddingBottom: 15, paddingRight: 0, width: 60, height: 60)
    }
}
