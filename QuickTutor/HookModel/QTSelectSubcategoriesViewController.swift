//
//  QTSelectSubcategoriesViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SpriteKit

class QTSelectSubcategoriesViewController: QTBaseBubbleViewController {

    var selectedCategories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        minSelectCount = 2
        maxSelectCount = 4
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for index in 0 ..< selectedCategories.count {
            let category = selectedCategories[index]
            
            category.subcategory.subcategories.forEach { subcategory in
                let words = subcategory.title.split(separator: " ")
                var maxRadius = bubbleRadius
                for word in words {
                    let width = String(word).estimateFrameForFontSize(14, extendedWidth: true).width
                    maxRadius = max(maxRadius, (width + 18) / 2)
                }
                let node = Node(text: subcategory.title,
                                image: subcategory.icon,
                                color: category.color,
                                radius: maxRadius,
                                userInfo: subcategory)
                
                var x = -node.frame.width * CGFloat(index) // left
                if index % 2 == 0 {
                    x = magnetic.frame.width + node.frame.width * CGFloat(index) // right
                }
                let y = CGFloat.random(node.frame.height, magnetic.frame.height - node.frame.height)
                node.position = CGPoint(x: x, y: y)
                
                magnetic.addChild(node)
            }
        }
    }
    
    override func onClickItemNext() {
        super.onClickItemNext()
        
        magnetic.removeAllChilds() {
            let selectInterestsVC = QTSelectInterestsViewController(nibName: String(describing: QTSelectInterestsViewController.self), bundle: nil)
            var selectedSubcategories: [(title: String, icon: UIImage?)] = []
            for node in self.selectedNodes {
                guard let subcategory = node.userInfo as? (title: String, icon: UIImage?) else { continue }
                selectedSubcategories.append(subcategory)
            }
            selectInterestsVC.selectedSubcategories = selectedSubcategories
            self.navigationController?.pushViewController(selectInterestsVC, animated: true)
        }
    }

}
