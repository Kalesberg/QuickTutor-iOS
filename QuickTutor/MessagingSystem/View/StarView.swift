//
//  StarView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class StarView: UIView {
    let star1: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star2: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star3: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star4: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star5: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filledStar"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    func setupViews() {
        setupStar1()
        setupStar2()
        setupStar3()
        setupStar4()
        setupStar5()
    }

    let rightPadding: CGFloat = 1
    private func setupStar1() {
        addSubview(star1)
        star1.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 7, height: 7)
    }

    private func setupStar2() {
        addSubview(star2)
        star2.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star1.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }

    private func setupStar3() {
        addSubview(star3)
        star3.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star2.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }

    private func setupStar4() {
        addSubview(star4)
        star4.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star3.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }

    private func setupStar5() {
        addSubview(star5)
        star5.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star4.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
