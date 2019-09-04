//
//  QTSelectSubcategoriesViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SpriteKit

class QTSelectSubcategoriesViewController: UIViewController {

    var selectedCategories: [Category] = []
    
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
        
        selectedCategories.forEach { category in
            category.subcategory.subcategories.forEach { subcategory in
                let radius = fmax(subcategory.title.estimateFrameForFontSize(14).width + 30, 100)
                let node = Node(text: subcategory.title,
                                image: subcategory.icon,
                                color: category.color,
                                radius: radius / 2)
                magnetic.addChild(node)
            }
        }
    }
    
    private func onUpdatedSelectedNodes() {
        let selectedNodes = magnetic.selectedChildren
        
        // update selected categories
        lblDescription.superview?.isHidden = !selectedNodes.isEmpty
        stackView.superview?.superview?.isHidden = selectedNodes.isEmpty
        
        lblSelectedCount.text = "\(selectedNodes.count)/12"
        btnNext.isHidden = 4 > selectedNodes.count
        if 12 == selectedNodes.count {
            onClickBtnNext(btnNext!)
        }
    }
    
    @IBAction func onClickBtnNext(_ sender: Any) {
        magnetic.removeAllChilds() {
            let selectInterestsVC = QTSelectInterestsViewController(nibName: String(describing: QTSelectInterestsViewController.self), bundle: nil)
            var selectedSubcategories: [(title: String, icon: UIImage?)] = []
            for node in self.magnetic.selectedChildren {
                guard let index = self.magnetic.children.compactMap({ $0 as? Node }).firstIndex(of: node) else { continue }
                let category = Category.categories[index / 6]
                let subcategory = category.subcategory.subcategories[index % 6]
                selectedSubcategories.append(subcategory)
            }
            selectInterestsVC.selectedSubcategories = selectedSubcategories
            self.navigationController?.pushViewController(selectInterestsVC, animated: true)
        }
    }

}

extension QTSelectSubcategoriesViewController: MagneticDelegate {
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
