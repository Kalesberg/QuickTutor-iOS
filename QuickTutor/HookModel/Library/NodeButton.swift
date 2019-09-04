//
//  NodeButton.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class NodeButton: UIButton {
    
    var node: Node!
    
    override func layoutSubviews() {
        super.layoutSubviews()        
        layer.cornerRadius = frame.size.height / 2
    }
    
    public convenience init(icon: UIImage?, text: String?, color: UIColor?, node: Node) {
        self.init(type: .custom)
        
        setImage(icon, for: .normal)
        setTitle(text, for: .normal)
        
        self.node = node
        backgroundColor = Colors.newNavigationBarBackground
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 15)
        
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = color?.cgColor
    }
    
}
