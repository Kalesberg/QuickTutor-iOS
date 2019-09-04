//
//  QTSelectCategoriesViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SpriteKit

class QTSelectCategoriesViewController: UIViewController {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var magneticView: MagneticView! {
        didSet {
            magnetic.magneticDelegate = self
        }
    }
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblSelectedCount: UILabel!
    
    private var magnetic: Magnetic {
        return magneticView.magnetic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        hideTabBar(hidden: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Category.categories.forEach { category in
            let radius = fmax(category.mainPageData.displayName.estimateFrameForFontSize(14).width + 30, 100)
            var image: UIImage?
            if let index = Category.categories.firstIndex(of: category) {
                image = categoryIcons[index]
            }
            let node = Node(text: category.mainPageData.displayName,
                            image: image,
                            color: category.color,
                            radius: radius / 2)
            magnetic.addChild(node)
        }
    }
    
    private func onUpdatedSelectedNodes() {
        let selectedNodes = magnetic.selectedChildren
        
        // update selected categories
        lblDescription.superview?.isHidden = !selectedNodes.isEmpty
        stackView.superview?.superview?.isHidden = selectedNodes.isEmpty
        
        lblSelectedCount.text = "\(selectedNodes.count)/4"
        btnNext.isHidden = 2 > selectedNodes.count
        if 4 == selectedNodes.count {
            onClickBtnNext(btnNext!)
        }
    }

    @IBAction func onClickBtnNext(_ sender: Any) {
        magnetic.removeAllChilds() {
            let selectSubcategoriesVC = QTSelectSubcategoriesViewController(nibName: String(describing: QTSelectSubcategoriesViewController.self), bundle: nil)
            var selectedCategories: [Category] = []
            for node in self.magnetic.selectedChildren {
                guard let index = self.magnetic.children.compactMap({ $0 as? Node }).firstIndex(of: node) else { continue }
                let category = Category.categories[index]
                selectedCategories.append(category)
            }
            selectSubcategoriesVC.selectedCategories = selectedCategories
            self.navigationController?.pushViewController(selectSubcategoriesVC, animated: true)
        }
    }

}

extension QTSelectCategoriesViewController: MagneticDelegate {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        onUpdatedSelectedNodes()
        
        // add node to stack view        
        let btnNode = NodeButton(icon: node.icon, text: node.text, color: node.strokeColor, node: node)
        var frame = btnNode.frame
        frame.size.height = stackView.frame.size.height
        btnNode.frame = frame
        stackView.addArrangedSubview(btnNode)
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        onUpdatedSelectedNodes()
        
        // remove node from stack view
        stackView.arrangedSubviews.forEach { view in
            if let btnNode = view as? NodeButton,
                btnNode.node == node {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
    }
}
