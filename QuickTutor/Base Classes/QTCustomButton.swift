//
//  CustomButton.swift
//
//  Created by JH Lee on 11/15/16.
//  Copyright © 2016 developer. All rights reserved.
//

import UIKit

@IBDesignable class QTCustomButton: DimmableButton {
    
    var startLoading = false {
        didSet {
            if startLoading {
                isEnabled = false
                // update activity color
                idcLoading.color = titleColor(for: state)
                
                // save storage
                aryControlStates.forEach { state in
                    if let title = title(for: state) {
                        storageTitle[state.rawValue] = title
                    }
                    if let image = image(for: state) {
                        storageImage[state.rawValue] = image
                    }
                }
                
                bringSubviewToFront(viewOverlay)
                aryControlStates.forEach { state in
                    setTitle(nil, for: state)
                    setImage(nil, for: state)
                }
                viewOverlay.isHidden = false
                idcLoading.startAnimating()
            } else {
                isEnabled = true
                sendSubviewToBack(viewOverlay)
                aryControlStates.forEach { state in
                    setTitle(storageTitle[state.rawValue], for: state)
                    if let image = storageImage[state.rawValue] {
                        setImage(image.withRenderingMode(image.renderingMode), for: state)
                    }
                }
                viewOverlay.isHidden = true
                idcLoading.stopAnimating()
            }
        }
    }
    
    private var viewOverlay: UIView!
    private var idcLoading: UIActivityIndicatorView!
   
    private let aryControlStates: [UIControl.State] = [.normal, .highlighted, .disabled, .selected]
    private var storageTitle: [UIControl.State.RawValue: String] = [:]
    private var storageImage: [UIControl.State.RawValue: UIImage] = [:]
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            setLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            setLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setLayout()
        }
    }
    
    @IBInspectable var verticalAlign: Bool = false {
        didSet {
            setLayout()
        }
    }
    
    @IBInspectable var verticalSpace: CGFloat = 6 {
        didSet {
            setLayout()
        }
    }
    
    @IBInspectable var titleLines: Int = 1 {
        didSet {
            titleLabel?.numberOfLines = titleLines
            switch contentHorizontalAlignment {
            case .fill:
                titleLabel?.textAlignment = .justified
            case .left:
                titleLabel?.textAlignment = .left
            case .right:
                titleLabel?.textAlignment = .right
            case .center:
                titleLabel?.textAlignment = .center
            default:
                titleLabel?.textAlignment = .natural
            }
            setLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        
        if nil == viewOverlay {
            viewOverlay = UIView(frame: .zero)
            viewOverlay.isHidden = true
            viewOverlay.backgroundColor = .clear
            addSubview(viewOverlay)
            viewOverlay.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(NSLayoutConstraint(item: viewOverlay!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: viewOverlay!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: viewOverlay!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: viewOverlay!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
        }
        
        if nil == idcLoading {
            idcLoading = UIActivityIndicatorView()
            idcLoading.style = .white
            idcLoading.hidesWhenStopped = true
            idcLoading.isUserInteractionEnabled = false
            viewOverlay.addSubview(idcLoading)
            idcLoading.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(NSLayoutConstraint(item: idcLoading!, attribute: .centerY, relatedBy: .equal, toItem: viewOverlay, attribute: .centerY, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: idcLoading!, attribute: .centerX, relatedBy: .equal, toItem: viewOverlay, attribute: .centerX, multiplier: 1, constant: 0))
        }
    }
    
    private func setLayout() {
        guard verticalAlign,
            let imageSize = imageView?.frame.size,
            let titleSize = titleLabel?.frame.size else { return }
        
        let totalHeight = (imageSize.height + titleSize.height + verticalSpace);
        
        imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height),
                                       left: 0,
                                       bottom: 0,
                                       right: -titleSize.width)
        
        titleEdgeInsets = UIEdgeInsets(top: 0,
                                       left: -imageSize.width,
                                       bottom: -(totalHeight - titleSize.height),
                                       right: 0)
    }
}
