//
//  BaseView.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.


import UIKit
import SnapKit

protocol BaseViewProtocol {
    func configureView()
    func applyConstraints()
}

public class BaseView: UIView, BaseViewProtocol {
    public required init() {
        super.init(frame: .zero)
        configureView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() { isUserInteractionEnabled = false }
    func applyConstraints() {
        print(self)
        fatalError("Override this method")
    }
}


class BaseLayoutView: UIView, BaseViewProtocol {
    public required init() {
        super.init(frame: UIScreen.main.bounds)
        configureView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() { isExclusiveTouch = true }
    func applyConstraints() {}
}
