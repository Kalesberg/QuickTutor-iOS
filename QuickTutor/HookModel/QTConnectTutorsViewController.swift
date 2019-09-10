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
    private var aryConnectedTutorIds: [String] = []
    private var aryRequestedTutorIds: [String] = []
    
    private var shouldLoadMore = false
    private var _observing = false
    
    private let minTutorCount = 5
    private let limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.newScreenBackground
        
        navigationItem.hidesBackButton = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        tableView.register(QTConnectTutorTableViewCell.nib, forCellReuseIdentifier: QTConnectTutorTableViewCell.reuseIdentifier)
        tableView.register(QTLoadMoreTableViewCell.nib, forCellReuseIdentifier: QTLoadMoreTableViewCell.reuseIdentifier)
        tableView.isUserInteractionEnabled = false
        tableView.showAnimatedSkeleton(usingColor: Colors.gray)
        
        btnContinue.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: -2), radius: 2)
        
        onUpdateConnectStatus()
        loadConnectedTutors() {
            self.loadLearnerRelativeTutorIds() {
                self.loadTutors()
            }
        }
    }
    
    private func loadConnectedTutors(completion: @escaping () -> Void) {
        if 0 == CurrentUser.shared.learner.connectedTutorsCount {
            completion()
            return
        }
        
        FirebaseData.manager.fetchLearnerConnections(uid: CurrentUser.shared.learner.uid) { aryConnectedTutorIds in
            if let aryConnectedTutorIds = aryConnectedTutorIds {
                self.aryConnectedTutorIds = aryConnectedTutorIds
            }
            completion()
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
                guard let tutorIds = tutorIds else {
                    interestsGroup.leave()
                    return
                }
                tutorIds.forEach { tutorId in
                    if CurrentUser.shared.learner.uid != tutorId,
                        !self.aryConnectedTutorIds.contains(tutorId),
                        !self.aryTutorIds.contains(tutorId) {
                        self.aryTutorIds.append(tutorId)
                    }
                }
                interestsGroup.leave()
            }
        }
        
        interestsGroup.notify(queue: .main) {
            // load same category tutors
            let categoriesGroup = DispatchGroup()
            for category in categories {
                categoriesGroup.enter()
                TutorSearchService.shared.getTutorIdsByCategory(category) { tutorIds in
                    guard let tutorIds = tutorIds else {
                        categoriesGroup.leave()
                        return
                    }
                    tutorIds.forEach { tutorId in
                        if CurrentUser.shared.learner.uid != tutorId,
                            !self.aryConnectedTutorIds.contains(tutorId),
                            !self.aryTutorIds.contains(tutorId) {
                            self.aryTutorIds.append(tutorId)
                        }
                    }
                    categoriesGroup.leave()
                }
            }
            categoriesGroup.notify(queue: .main) {
                completion()
            }
        }
        
    }
    
    private func loadTutors() {
        _observing = true        
        let tutorsGroup = DispatchGroup()
        var tutors: [AWTutor] = []
        for index in 0 ..< limit {
            let realIndex = aryTutors.count + index
            if realIndex >= aryTutorIds.count { break }
            
            tutorsGroup.enter()
            FirebaseData.manager.fetchTutor(aryTutorIds[realIndex], isQuery: false) { tutor in
                guard let tutor = tutor else {
                    tutorsGroup.leave()
                    return
                }
                tutors.append(tutor)
                tutorsGroup.leave()
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
            self.shouldLoadMore = self.limit + self.aryTutors.count < self.aryTutorIds.count
            let beforeTutorsCount = self.aryTutors.count
            self.aryTutors.append(contentsOf: tutors)
            self.tableView.reloadData()
            if 0 < beforeTutorsCount {
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: beforeTutorsCount - 1, section: 0), at: .bottom, animated: false)
                }
            }
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
        
        btnContinue.isEnabled = aryRequestedTutorIds.count >= minTutorCount
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return aryTutors.count
        } else {
            return shouldLoadMore ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 1 == indexPath.section {
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

extension QTConnectTutorsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
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
