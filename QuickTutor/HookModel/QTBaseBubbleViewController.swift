//
//  QTBaseBubbleViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/6/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTBaseBubbleViewController: UIViewController {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var magneticView: MagneticView! {
        didSet {
            magnetic.magneticDelegate = self
        }
    }
    @IBOutlet weak var lblSelectedCount: UILabel!
    
    var magnetic: Magnetic {
        return magneticView.magnetic
    }
    
    var selectedNodes: [Node] = []
    
    var maxSelectCount = 4
    var minSelectCount = 2
    var bubbleRadius: CGFloat = 54
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        collectionView.register(QTSelectedNodeCollectionViewCell.nib, forCellWithReuseIdentifier: QTSelectedNodeCollectionViewCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        onUpdatedSelectedNodes()
    }
    
    private func onUpdatedSelectedNodes() {
        // update selected categories
        lblSelectedCount.isHidden = selectedNodes.isEmpty
        lblDescription.superview?.isHidden = !selectedNodes.isEmpty
        collectionView.isHidden = selectedNodes.isEmpty
        
        lblSelectedCount.text = "\(selectedNodes.count)/\(maxSelectCount)"
        if minSelectCount > selectedNodes.count {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(onClickItemNext))
        }
        if maxSelectCount == selectedNodes.count {
            onClickItemNext()
        }
    }
    
    @objc func onClickItemNext() {
        
    }
    
}

extension QTBaseBubbleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedNodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTSelectedNodeCollectionViewCell.reuseIdentifier, for: indexPath) as! QTSelectedNodeCollectionViewCell
        cell.setView(selectedNodes[indexPath.item])
        
        return cell
    }
}

extension QTBaseBubbleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let node = selectedNodes[indexPath.item].clone
        if let cell = collectionView.cellForItem(at: indexPath) {
            node.position = CGPoint(x: cell.frame.midX, y: magnetic.frame.height + node.frame.height)
        }
        magnetic.addNode(node)
        
        selectedNodes.remove(at: indexPath.item)
        onUpdatedSelectedNodes()
        
        collectionView.deleteItems(at: [indexPath])
    }
}

extension QTBaseBubbleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let node = selectedNodes[indexPath.item]
        let titleLength = node.text?.estimateFrameForFontSize(14, extendedWidth: true).width ?? 60
        
        return CGSize(width: titleLength + 55, height: 36)
    }
}

extension QTBaseBubbleViewController: MagneticDelegate {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        // add node to stack view
        magnetic.removeChild(node: node) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.selectedNodes.insert(node, at: 0)
                self.onUpdatedSelectedNodes()
                self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }           
        }
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        
    }
}

