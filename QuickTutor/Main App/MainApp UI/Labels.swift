//
//  Labels.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

//import Foundation
//import UIKit
//import SnapKit
//
//class SectionTitle : LeftTextLabel {
//
//    override func configureView() {
//        super.configureView()
//
//        label.font = Fonts.createBoldSize(17)
//    }
//
//    override func applyConstraints() {
//        label.snp.makeConstraints { (make) in
//            make.width.equalToSuperview()
//            make.centerX.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.8)
//            make.centerY.equalToSuperview().multipliedBy(1.4)
//        }
//    }
//
//    func constrainSelf(top: ConstraintItem) {
//        self.snp.makeConstraints { (make) in
//            make.height.equalTo(50)
//            make.width.equalToSuperview().multipliedBy(0.9)
//            make.centerX.equalToSuperview()
//            make.top.equalTo(top)
//        }
//    }
//}
//
//class SectionSubTitle : LeftTextLabel {
//
//    override func configureView() {
//        super.configureView()
//
//        label.font = Fonts.createBoldSize(16)
//    }
//
//    override func applyConstraints() {
//        label.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//    }
//
//    func constrainSelf(top: ConstraintItem) {
//        self.snp.makeConstraints { (make) in
//            make.height.equalTo(50)
//            make.width.equalToSuperview().multipliedBy(0.9)
//            make.centerX.equalToSuperview()
//            make.top.equalTo(top)
//        }
//    }
//}
//
//
//public class SectionBody: UILabel, BaseViewProtocol {
//    public required init() {
//        super.init(frame: .zero)
//        configureView()
//    }
//
//    public required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        configureView()
//    }
//
//    func configureView() {
//        font = Fonts.createSize(15)
//        textColor = Colors.grayText
//        numberOfLines = 0
//        sizeToFit()
//    }
//    func applyConstraints() { }
//
//    func constrainSelf(top: ConstraintItem) {
//        self.snp.makeConstraints { (make) in
//            make.top.equalTo(top)
//            make.width.equalToSuperview().multipliedBy(0.9)
//            make.centerX.equalToSuperview()
//        }
//    }
//}

