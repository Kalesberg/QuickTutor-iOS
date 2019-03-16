//
//  QTRatingView.swift
//  QuickTutor
//
//  Created by Michael Burkard on 3/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

@IBDesignable class QTRatingView: UIView {
    
    @IBInspectable var spacing: CGFloat = 3.0
    
    class QTStarButton: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setImage(UIImage(named: "ic_star_empty"), for: .normal)
            setImage(UIImage(named: "ic_star_filled"), for: .selected)
            contentMode = .scaleAspectFit
            imageView?.scaleImage()
            isSelected = true
            adjustsImageWhenHighlighted = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var rating = 0
    var didUpdateRating: ((Int) -> ())?
    
    let star1: QTStarButton = {
        let button = QTStarButton()
        button.tag = 1
        return button
    }()
    
    let star2: QTStarButton = {
        let button = QTStarButton()
        button.tag = 2
        return button
    }()
    
    let star3: QTStarButton = {
        let button = QTStarButton()
        button.tag = 3
        return button
    }()
    
    let star4: QTStarButton = {
        let button = QTStarButton()
        button.tag = 4
        return button
    }()
    
    let star5: QTStarButton = {
        let button = QTStarButton()
        button.tag = 5
        return button
    }()
    
    lazy var buttons = [star1, star2, star3, star4, star5]
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [star1, star2, star3, star4, star5])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = spacing
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
            buttons[x].isSelected = false
        }
        var x = 0
        while x < sender.tag {
            buttons[x].isSelected = true
            x += 1
        }
    }
}
