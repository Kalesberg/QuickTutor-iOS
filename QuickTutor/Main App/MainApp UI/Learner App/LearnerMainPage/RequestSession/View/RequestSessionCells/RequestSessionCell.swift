//
//  RequestSessionCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionTableViewCell : UITableViewCell {
    
    var isRotated = false
    
    let title : UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.4901960784, green: 0.4980392157, blue: 0.9568627451, alpha: 1)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createSize(16)
        return label
    }()
    
    let subtitle : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createBoldSize(15)
        return label
    }()
    
    let icon : UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "backButton")
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi  / -2))
        return imageView
    }()
    
    func configureTableViewCell() {
        addSubview(title)
        addSubview(subtitle)
        addSubview(icon)
        
        backgroundColor = Colors.navBarColor
        selectionStyle = .none
        
        applyConstraints()
    }
    
    func applyConstraints() {
        title.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(icon.snp.left)
            make.height.equalTo(20)
        }
        subtitle.snp.makeConstraints { (make) in
            make.top.equalTo(title.snp.bottom)
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(icon.snp.left)
            make.height.equalTo(20)
        }
        icon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(30)
            make.width.equalTo(20)
        }
    }
    
    func applyRotation() {
        UIView.animate(withDuration: 0.2) {
            let degrees: CGFloat = self.isRotated ? 0 : CGFloat.pi * 0.999 / 2
            self.icon.transform = CGAffineTransform(rotationAngle: degrees)
            self.isRotated = !self.isRotated
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
