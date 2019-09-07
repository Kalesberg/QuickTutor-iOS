//
//  QTSelectCategoriesViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SpriteKit

class QTSelectCategoriesViewController: QTBaseBubbleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        minSelectCount = 2
        maxSelectCount = 4
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Category.categories.forEach { category in
            var image: UIImage?
            if let index = Category.categories.firstIndex(of: category) {
                image = categoryIcons[index]
            }
            let words = category.mainPageData.displayName.split(separator: " ")
            var maxRadius = bubbleRadius
            for word in words {
                let width = String(word).estimateFrameForFontSize(14, extendedWidth: true).width
                maxRadius = max(maxRadius, (width + 18) / 2)
            }
            let node = Node(text: category.mainPageData.displayName,
                            image: image,
                            color: category.color,
                            radius: maxRadius,
                            userInfo: category)
            magnetic.addChild(node)
        }
    }
    
    override func onClickItemNext() {
        super.onClickItemNext()
        
        magnetic.removeAllChilds() {
            let selectSubcategoriesVC = QTSelectSubcategoriesViewController(nibName: String(describing: QTSelectSubcategoriesViewController.self), bundle: nil)
            var selectedCategories: [Category] = []
            for node in self.selectedNodes {
                guard let category = node.userInfo as? Category else { continue }
                selectedCategories.append(category)
            }
            selectSubcategoriesVC.selectedCategories = selectedCategories
            self.navigationController?.pushViewController(selectSubcategoriesVC, animated: true)
        }
    }
}
