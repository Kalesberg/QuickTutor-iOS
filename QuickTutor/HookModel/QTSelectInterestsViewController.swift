//
//  QTSelectInterestsViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTSelectInterestsViewController: QTBaseBubbleViewController {

    var selectedSubcategories: [(title: String, icon: UIImage?)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        minSelectCount = 4
        maxSelectCount = 12
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var subjects: [String] = []
        let subjectsCount = Int(72 / selectedSubcategories.count)
        for index in 0 ..< selectedSubcategories.count {
            let subcategory = selectedSubcategories[index]
            
            guard let categoryName = SubjectStore.shared.findCategoryBy(subcategory: subcategory.title),
                let category = Category.category(for: categoryName),
                let categorySubjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategory.title) else { continue }
            
            let count = min(categorySubjects.count, subjectsCount)
            for index in 0 ..< count {
                var rndIndex = categorySubjects.count > subjectsCount ? Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(categorySubjects.count)) : index
                if rndIndex >= categorySubjects.count {
                    rndIndex = categorySubjects.count - 1
                }
                let rndSubject = categorySubjects[rndIndex]
                
                if subjects.contains(rndSubject) { continue }
                subjects.append(rndSubject)
                
                let words = rndSubject.split(separator: " ")
                var maxRadius = bubbleRadius
                for word in words {
                    let width = String(word).estimateFrameForFontSize(14, extendedWidth: true).width
                    maxRadius = max(maxRadius, (width + 18) / 2)
                }
                let node = Node(text: rndSubject,
                                image: subcategory.icon,
                                color: category.color,
                                radius: maxRadius,
                                userInfo: rndSubject)
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
        magnetic.removeAllChilds(isFast: true) {
            let connectTutorsVC = QTConnectTutorsViewController(nibName: String(describing: QTConnectTutorsViewController.self), bundle: nil)
            
            for node in self.selectedNodes {
                guard let subject = node.userInfo as? String else { continue }
                
//                LearnerRegistrationService.shared.shouldSaveInterests = false
                LearnerRegistrationService.shared.addInterest(subject)
            }
            self.navigationController?.pushViewController(connectTutorsVC, animated: true)
        }
    }
    
}
