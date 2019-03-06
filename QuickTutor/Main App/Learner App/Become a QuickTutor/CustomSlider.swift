//
//  CustomSlider.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    
    func setupViews() {
        thumbTintColor = Colors.purple
        minimumTrackTintColor = Colors.purple
        maximumTrackTintColor = Colors.gray
        setThumbImage(UIImage(named: "Oval"), for: .normal)
        setThumbImage(UIImage(named: "Oval"), for: .highlighted)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = 4
        return result
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
