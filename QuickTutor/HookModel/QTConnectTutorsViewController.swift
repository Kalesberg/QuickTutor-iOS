//
//  QTConnectTutorsViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/6/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTTutorSubjectInterface {
    var tutorId: String!
    var subject: String!
    
    init(tutorId: String, subject: String) {
        self.tutorId = tutorId
        self.subject = subject
    }
}

extension QTTutorSubjectInterface: Equatable {
    static func == (lhs: QTTutorSubjectInterface, rhs: QTTutorSubjectInterface) -> Bool {
        return lhs.tutorId == rhs.tutorId
    }
}

class QTConnectTutorsViewController: UIViewController {

    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var lblConnectedCount: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    private var aryTutorIds: [QTTutorSubjectInterface] = []
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
        
        viewDescription.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 2), radius: 2)
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
        var subcategories: [String] = []
        let interestsGroup = DispatchGroup()
        for interest in interests {
            if let category = SubjectStore.shared.findCategoryBy(subject: interest),
                !categories.contains(category) {
                categories.append(category)
            }
            if let subcategory = SubjectStore.shared.findSubCategory(subject: interest),
                !subcategories.contains(subcategory) {
                subcategories.append(subcategory)
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
                        !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                        self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subject: interest))
                    }
                }
                interestsGroup.leave()
            }
        }
        
        interestsGroup.notify(queue: .main) {
            // load same subcategory tutors
            let subcategoriesGroup = DispatchGroup()
            for subcategory in subcategories {
                subcategoriesGroup.enter()
                TutorSearchService.shared.getTutorIdsBySubcategory(subcategory) { tutorIds in
                    guard let tutorIds = tutorIds else {
                        subcategoriesGroup.leave()
                        return
                    }
                    tutorIds.forEach { tutorId in
                        if CurrentUser.shared.learner.uid != tutorId,
                            !self.aryConnectedTutorIds.contains(tutorId),
                            !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                            // get any subject of this subcategory
                            if let subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategory) {
                                // get random subject
                                let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subjects.count))
                                self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subject: subjects[rndIndex]))
                            }
                        }
                    }
                    subcategoriesGroup.leave()
                }
            }
            subcategoriesGroup.notify(queue: .main) {
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
                                !self.aryTutorIds.contains(where: { $0.tutorId == tutorId }) {
                                
                                // get any subcategory of this category
                                if let category = Category.category(for: category) {
                                    let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(category.subcategory.subcategories.count))
                                    let rndSubcategoryName = category.subcategory.subcategories[rndIndex].title
                                    
                                    // get any subject of subcategory
                                    if let subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: rndSubcategoryName) {
                                        // get random subject
                                        let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subjects.count))
                                        self.aryTutorIds.append(QTTutorSubjectInterface(tutorId: tutorId, subject: subjects[rndIndex]))
                                    }
                                }
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
    }
    
    private func loadTutors() {
        _observing = true        
        let tutorsGroup = DispatchGroup()
        var tutors: [AWTutor] = []
        
        let realLimit = limit < aryTutorIds.count ? limit : aryTutorIds.count
        for index in 0 ..< realLimit {
            tutorsGroup.enter()
            FirebaseData.manager.fetchTutor(aryTutorIds[index].tutorId, isQuery: false) { tutor in
                guard let tutor = tutor else {
                    tutorsGroup.leave()
                    return
                }
                tutor.featuredSubject = self.aryTutorIds[index].subject
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
            self.aryTutorIds = Array(self.aryTutorIds.dropFirst(realLimit))
            self.shouldLoadMore = 0 < self.aryTutorIds.count
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
        lblConnectedCount.text = "\(aryRequestedTutorIds.count)/\(minTutorCount) Connected"
        progressView.setProgress(Double(aryRequestedTutorIds.count) / Double(minTutorCount))
        
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
        MessageService.shared.sendConnectionRequestToId(text: "Hi, I would like to connect with you.", tutor.uid, shouldMarkAsRead: true)
        aryRequestedTutorIds.append(tutor.uid)
        onUpdateConnectStatus()
        
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
