//
//  QTViewRecommendationsViewController.swift
//  QuickTutor
//
//  Created by JH Lee on 8/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class QTViewRecommendationsViewController: UIViewController {

    var objTutor: AWTutor!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var aryRecommendations: [QTTutorRecommendationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if objTutor.uid == CurrentUser.shared.tutor?.uid {
            title = "Your recommendations"
        } else {
            title = "\(objTutor.firstName ?? "")'s recommendations"
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorColor = Colors.gray
        tableView.register(QTRecommendationTableViewCell.nib, forCellReuseIdentifier: QTRecommendationTableViewCell.reuseIdentifier)
        
        if let recommendations = objTutor.recommendations {
            aryRecommendations = recommendations.sorted(by: { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        objTutor.recommendations = aryRecommendations
    }
    
}

extension QTViewRecommendationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryRecommendations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: QTRecommendationTableViewCell.reuseIdentifier), for: indexPath) as! QTRecommendationTableViewCell
        cell.setView(aryRecommendations[indexPath.row])
        if indexPath.row == aryRecommendations.count - 1 {
            let width = UIScreen.main.bounds.width
            cell.separatorInset = UIEdgeInsets(top: 0, left: width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        cell.delegate = self
        
        return cell
    }
}

extension QTViewRecommendationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension QTViewRecommendationsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let objRecommendation = aryRecommendations[indexPath.row]
        
        if orientation == .left
            || objTutor.uid != CurrentUser.shared.learner?.uid { return nil }
        
        guard let recommendationId = objRecommendation.uid else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            let alert = UIAlertController(title: "Remove a recommendation",
                                          message: "Are you sure you want to remove your recommendation?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                Database.database().reference().child("recommendations").child(self.objTutor.uid).child(recommendationId).removeValue()
                
                self.aryRecommendations.remove(at: indexPath.row)
                if self.aryRecommendations.isEmpty {
                    self.navigationController?.popViewController(animated: false)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        deleteAction.image = UIImage(named: "ic_payment_del")
        deleteAction.highlightedImage = UIImage(named: "ic_payment_del")?.alpha(0.2)
        deleteAction.font = Fonts.createSize(16)
        deleteAction.backgroundColor = Colors.newScreenBackground
        deleteAction.highlightedBackgroundColor = Colors.newScreenBackground
        deleteAction.hidesWhenSelected = true
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .drag
        return options
    }
}
