//
//  QTConnectTutorsViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/6/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTConnectTutorsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var lblConnectedCount: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    private var aryTutorIds: [String] = []
    private var aryTutors: [AWTutor] = []
    private var aryRequestedTutorIds: [String] = []
    
    private var shouldLoadMore = false
    private var _observing = false
    
    private let minTutorCount = 5
    private let limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        tableView.register(QTConnectTutorTableViewCell.nib, forCellReuseIdentifier: QTConnectTutorTableViewCell.reuseIdentifier)
        tableView.register(QTLoadMoreTableViewCell.nib, forCellReuseIdentifier: QTLoadMoreTableViewCell.reuseIdentifier)
        tableView.isUserInteractionEnabled = false
        tableView.showAnimatedSkeleton(usingColor: Colors.gray)
        
        onUpdateConnectStatus()
        loadLearnerRelativeTutorIds() {
            self.loadTutors()
        }
    }
    
    private func loadLearnerRelativeTutorIds(completion: @escaping () -> Void) {
        guard let interests = CurrentUser.shared.learner.interests else { return }
        
        // load same subjects tutors
        var categories: [String] = []
        let interestsGroup = DispatchGroup()
        for interest in interests {
            if let category = SubjectStore.shared.findCategoryBy(subject: interest),
                !categories.contains(category) {
                categories.append(category)
            }
            interestsGroup.enter()
            TutorSearchService.shared.getTutorIdsBySubject(interest) { tutorIds in
                interestsGroup.leave()
                guard let tutorIds = tutorIds else { return }
                tutorIds.forEach { tutorId in
                    if CurrentUser.shared.learner.uid != tutorId,
                        !self.aryTutorIds.contains(tutorId) {
                        self.aryTutorIds.append(tutorId)
                    }
                }
            }
        }
        interestsGroup.notify(queue: .main) {
            // load same category tutors
            let categoriesGroup = DispatchGroup()
            for category in categories {
                categoriesGroup.enter()
                TutorSearchService.shared.getTutorIdsByCategory(category) { tutorIds in
                    categoriesGroup.leave()
                    guard let tutorIds = tutorIds else { return }
                    tutorIds.forEach { tutorId in
                        if CurrentUser.shared.learner.uid != tutorId,
                            !self.aryTutorIds.contains(tutorId) {
                            self.aryTutorIds.append(tutorId)
                        }
                    }
                }
            }
            categoriesGroup.notify(queue: .main) {
                completion()
            }
        }
        
    }
    
    private func loadTutors() {
        _observing = true        
        shouldLoadMore = limit + aryTutors.count < aryTutorIds.count
        let tutorsGroup = DispatchGroup()
        for index in 0 ..< limit {
            let realIndex = aryTutors.count + index
            if realIndex >= aryTutorIds.count { break }
            
            tutorsGroup.enter()
            FirebaseData.manager.fetchTutor(aryTutorIds[realIndex], isQuery: false) { tutor in
                tutorsGroup.leave()
                guard let tutor = tutor else { return }
                self.aryTutors.append(tutor)
            }
        }
        tutorsGroup.notify(queue: .main) {
            self._observing = false
            if self.tableView.isSkeletonActive {
                self.tableView.hideSkeleton()
                self.tableView.isUserInteractionEnabled = true
                
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.estimatedRowHeight = 80
            }
            self.tableView.reloadData()
        }
    }
    
    private func onUpdateConnectStatus() {
        if aryRequestedTutorIds.count > minTutorCount {
            progressView.isHidden = true
            lblConnectedCount.isHidden = true
        } else {
            progressView.isHidden = false
            lblConnectedCount.isHidden = false
            lblConnectedCount.text = "\(aryRequestedTutorIds.count)/\(minTutorCount) Connected"
            progressView.setProgress(Double(aryRequestedTutorIds.count) / Double(minTutorCount))
        }
        
        btnContinue.isEnabled = aryRequestedTutorIds.count == minTutorCount
        btnContinue.backgroundColor = btnContinue.isEnabled ? Colors.purple : Colors.gray
    }

    @IBAction func onClickBtnContinue(_ sender: Any) {
        guard let hookModelNC = navigationController as? QTHookModelNavigationController else { return }
        hookModelNC.hookModelDelegate?.didFinishHookModel(hookModelNC)
    }

}

extension QTConnectTutorsViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return QTConnectTutorTableViewCell.reuseIdentifier
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldLoadMore {
            return aryTutors.count + 1
        } else {
            return aryTutors.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if aryTutors.count == indexPath.row {
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLoadMoreTableViewCell.reuseIdentifier, for: indexPath) as! QTLoadMoreTableViewCell
            cell.activityIndicator.startAnimating()
            if shouldLoadMore, !_observing {
                loadTutors()
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: QTConnectTutorTableViewCell.reuseIdentifier, for: indexPath) as! QTConnectTutorTableViewCell
            let objTutor = aryTutors[indexPath.row]
            cell.setView(objTutor)
            cell.delegate = self
            
            if aryRequestedTutorIds.contains(objTutor.uid) {
                cell.btnConnect.isEnabled = false
                cell.btnConnect.backgroundColor = Colors.gray
            } else {
                cell.btnConnect.isEnabled = true
                cell.btnConnect.backgroundColor = Colors.purple
            }
            
            return cell
        }
    }
}

extension QTConnectTutorsViewController: QTConnectTutorTableViewCellDelegate {
    func onClickBtnConnect(_ cell: UITableViewCell, connect tutor: AWTutor) {
        MessageService.shared.sendConnectionRequestToId(text: "Hi, I would like to connect with you.", tutor.uid)
        aryRequestedTutorIds.append(tutor.uid)
        onUpdateConnectStatus()
        
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
