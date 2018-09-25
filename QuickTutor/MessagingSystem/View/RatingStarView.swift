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

class RatingStarView: UIView {
    class Star: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setImage(#imageLiteral(resourceName: "filledStar"), for: .normal)
            setImage(#imageLiteral(resourceName: "emptyStar"), for: .selected)
            contentMode = .scaleAspectFit
            imageView?.scaleImage()
            isSelected = true
            adjustsImageWhenHighlighted = false
        }

        required init?(coder _: NSCoder) {
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

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [star1, star2, star3, star4, star5])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = 10
        return stackView
    }()

    func setupViews() {
        setupStackview()
        setupButtonActions()
    }

    func setupStackview() {
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    func setupButtonActions() {
        buttons.forEach { button in
            button.addTarget(self, action: #selector(updateRating(sender:)), for: .touchDown)
        }
    }

    func setRatingTo(_ rating: Int) {
        let button = UIButton()
        button.tag = rating
        updateRating(sender: button)
    }

    @objc func updateRating(sender: UIButton) {
        rating = sender.tag
        for x in sender.tag - 1 ... 4 {
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

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
