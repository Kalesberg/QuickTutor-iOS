//
//  StarView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class StarView: UIView {
    
    lazy var stars = [star1, star2, star3, star4, star5]
    var starSideLength: CGFloat = 9
    
    let star1: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_star_sm_filled"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star2: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_star_sm_filled"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star3: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_star_sm_filled"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star4: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_star_sm_filled"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let star5: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_star_sm_filled"))
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
        star1.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: starSideLength, height: starSideLength)
    }
    
    private func setupStar2() {
        addSubview(star2)
        star2.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star1.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: starSideLength, height: starSideLength)
    }
    
    private func setupStar3() {
        addSubview(star3)
        star3.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star2.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: starSideLength, height: starSideLength)
    }
    
    private func setupStar4() {
        addSubview(star4)
        star4.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star3.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: starSideLength, height: starSideLength)
    }
    
    private func setupStar5() {
        addSubview(star5)
        star5.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star4.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: starSideLength, height: starSideLength)
    }
    
    func tintStars(color: UIColor) {
        stars.forEach { (iv) in
            iv.image = iv.image!.withRenderingMode(.alwaysTemplate)
            iv.tintColor = color
        }
    }
    
    func setRating(_ rating: Int) {
        print("Rating is", rating)
        stars.forEach({ $0.image = UIImage(named: "ic_star_sm_empty") })
        for x in 0..<rating {
            stars[x].image = UIImage(named: "ic_star_sm_filled")
        }
        tintStars(color: Colors.purple)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
