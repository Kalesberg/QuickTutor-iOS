//
//  DimmableButton.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit


class DimmableUICollectionViewCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            
        }
    }
    
    override var isSelected: Bool {
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DimmableButton: UIButton {
    @objc override func setupTargets() {
        super.setupTargets()
    }

    @objc override func handleTouchDown() {
        super.handleTouchDown()
    }

    @objc override func handleTouchUp() {
        super.handleTouchUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTargets()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTargets()
    }
    
}

extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: -1 * abs(percentage))
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + percentage / 100, 1.0),
                           green: min(g + percentage / 100, 1.0),
                           blue: min(b + percentage / 100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
}

extension CGColor {
    func uiColor() -> UIColor {
        return UIColor(cgColor: self)
    }
}

extension UIButton {
    @objc func setupTargets() {
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc func handleTouchDown() {
        backgroundColor = backgroundColor?.darker(by: 15)
        guard let titleColor = titleColor(for: .normal), let borderColor = layer.borderColor?.uiColor() else { return }
        setTitleColor(titleColor.darker(by: 15), for: .normal)
        layer.borderColor = borderColor.darker(by: 15)?.cgColor
    }
    
    @objc func handleTouchUp() {
        backgroundColor = backgroundColor?.lighter(by: 15)
        guard let titleColor = titleColor(for: .normal), let borderColor = layer.borderColor?.uiColor() else { return }
        setTitleColor(titleColor.lighter(by: 15), for: .normal)
        layer.borderColor = borderColor.lighter(by: 15)?.cgColor
    }
    
    @objc func handleTouchUpTitleDimming() {
        guard let titleColor = titleColor(for: .normal) else { return }
        setTitleColor(titleColor.lighter(by: 30), for: .normal)
    }
    
    @objc func handleTouchDownTitleDimming() {
        guard let titleColor = titleColor(for: .normal) else { return }
        setTitleColor(titleColor.darker(by: 30), for: .normal)
    }
    
    @objc func setupDimmingTitle() {
        addTarget(self, action: #selector(handleTouchDownTitleDimming), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUpTitleDimming), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
}
