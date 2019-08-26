//
//  QTViewRecommendationsViewController.swift
//  QuickTutor
//
//  Created by JH Lee on 8/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

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
            aryRecommendations = recommendations
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideTabBar(hidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideTabBar(hidden: false)
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
