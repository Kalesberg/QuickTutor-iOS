//
//  ProgressView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    let backgroundLayer: CAShapeLayer = {
        let myLayer = CAShapeLayer()
        myLayer.strokeColor = Colors.purple.withAlphaComponent(0.5).cgColor
        myLayer.lineWidth = 4
        myLayer.fillColor = UIColor.clear.cgColor
        myLayer.lineCap = CAShapeLayerLineCap.round
        return myLayer
    }()
    
    let progressLayer: CAShapeLayer = {
        let myLayer = CAShapeLayer()
        myLayer.strokeColor = Colors.purple.cgColor
        myLayer.lineWidth = 4
        myLayer.fillColor = UIColor.clear.cgColor
        myLayer.lineCap = CAShapeLayerLineCap.round
        myLayer.strokeEnd = 1
        return myLayer
    }()
    
    func setupViews() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
    }
    
    func setupPaths() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 10, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        backgroundLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    func setProgress(_ progress: Double) {
        let progressFloat = CGFloat(progress)
        progressLayer.strokeEnd = progressFloat
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupPaths()
        backgroundLayer.frame = bounds
        progressLayer.frame = backgroundLayer.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
    }
}
