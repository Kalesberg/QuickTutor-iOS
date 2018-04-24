//
//  RatingStarView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol RatingStarViewDelegate {
    func didUpdateRating(rating: Int)
}

class RatingStartView: UIView {
    
    class Star: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setImage(#imageLiteral(resourceName: "filledStar"), for: .normal)
            setImage(#imageLiteral(resourceName: "emptyStar"), for: .selected)
            contentMode = .scaleAspectFit
            isSelected = true
            adjustsImageWhenHighlighted = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var rating = 0
    var delegate: RatingStarViewDelegate?
    
    let star1: Star = {
        let button = Star()
        button.tag = 1
        return button
    }()
    
    let star2: Star = {
        let button = Star()
        button.tag = 2
        return button
    }()
    
    let star3: Star = {
        let button = Star()
        button.tag = 3
        return button
    }()
    
    let star4: Star = {
        let button = Star()
        button.tag = 4
        return button
    }()
    
    let star5: Star = {
        let button = Star()
        button.tag = 5
        return button
    }()
    
    lazy var buttons = [star1, star2, star3, star4, star5]
    
    func setupViews() {
        setupStar1()
        setupStar2()
        setupStar3()
        setupStar4()
        setupStar5()
        setupButtonActions()
    }
    
    func setupStar1() {
        addSubview(star1)
        star1.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 45, height: 0)
    }
    
    func setupStar2() {
        addSubview(star2)
        star2.anchor(top: topAnchor, left: star1.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 45, height: 0)
    }
    
    func setupStar3() {
        addSubview(star3)
        star3.anchor(top: topAnchor, left: star2.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 45, height: 0)
    }
    
    func setupStar4() {
        addSubview(star4)
        star4.anchor(top: topAnchor, left: star3.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 45, height: 0)
    }
    
    func setupStar5() {
        addSubview(star5)
        star5.anchor(top: topAnchor, left: star4.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 45, height: 0)
    }
    
    func setupButtonActions() {
        buttons.forEach { (button) in
            button.addTarget(self, action: #selector(updateRating(sender:)), for: .touchDown)
        }
    }
    
    @objc func updateRating(sender: UIButton) {
        rating = sender.tag
        for x in sender.tag - 1...4 {
            buttons[x].isSelected = true
        }
        var x = 0
        while x < sender.tag {
            buttons[x].isSelected = false
            x += 1
        }
        
        delegate?.didUpdateRating(rating: sender.tag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

