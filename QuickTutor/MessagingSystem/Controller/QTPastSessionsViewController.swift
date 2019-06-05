//
//  QTPastSessionsViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import Lottie

class QTPastSessionsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var animationView: LOTAnimationView!
    
    var sessionUserInfos = [SessionUserInfo]()
    var sessionDates = [String]()
    var sessionGroup = [String: [SessionUserInfo]]()
    
    var timer: Timer?
    
    static var controller: QTPastSessionsViewController {
        return QTPastSessionsViewController(nibName: String(describing: QTPastSessionsViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        fetchSessions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    // MARK: - Actions
    @objc func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Functions
    func fetchSessions() {
        sessionUserInfos.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        
        Database.database().reference()
            .child("userSessions")
            .child(uid)
            .child(userTypeString)
            .observe(.value) { (snapshot) in
            
                guard let snap = snapshot.children.allObjects as? [DataSnapshot] else {
                    self.animationView.isHidden = true
                    return
                }
            
                let group = DispatchGroup()
                
                for child in snap {
                    group.enter()
                    DataService.shared.getSessionById(child.key, completion: { session in
                        if session.status.isEmpty || session.status == "cancelled" || session.status == "declined" {
                            group.leave()
                            return
                        }
                        
                        if session.startTime < Date().timeIntervalSince1970 || session.status == "completed" {
                            if !self.sessionUserInfos.contains(where: { $0.id == session.id }) {
                                if AccountService.shared.currentUserType == .learner {
                                    self.getTutor(tutorId: session.partnerId(), completion: { user in
                                        let sessionUserInfo = SessionUserInfo(session)
                                        if let userName = user?.formattedName.capitalized {
                                            sessionUserInfo.userName = userName
                                        }
                                        
                                        if let profilePicUrl = user?.profilePicUrl {
                                            sessionUserInfo.profilePicUrl = profilePicUrl
                                        }
                                        self.sessionUserInfos.insert(sessionUserInfo, at: 0)
                                        group.leave()
                                        return
                                    })
                                } else {
                                    self.getLearner(learnerId: session.partnerId(), completion: { user in
                                        let sessionUserInfo = SessionUserInfo(session)
                                        if let userName = user?.formattedName.capitalized {
                                            sessionUserInfo.userName = userName
                                        }
                                        
                                        if let profilePicUrl = user?.profilePicUrl {
                                            sessionUserInfo.profilePicUrl = profilePicUrl
                                        }
                                        self.sessionUserInfos.insert(sessionUserInfo, at: 0)
                                        group.leave()
                                        return
                                    })
                                }
                            } else {
                                group.leave()
                                return
                            }
                        } else {
                            group.leave()
                            return
                        }
                    })
                }
                
                group.notify(queue: .main, execute: {
                    self.attemptReloadOfTable()
                    self.animationView.isHidden = true
                })
        }
    }
    
    
    func getTutor(tutorId: String, completion: @escaping ((ZFTutor?) -> Void)) {
        UserFetchService.shared.getTutorWithId(tutorId) { tutor in
            return completion(tutor)
        }
    }
    
    func getLearner(learnerId: String, completion: @escaping ((ZFTutor?) -> Void)) {
        UserFetchService.shared.getStudentWithId(learnerId) { tutor in
            completion(tutor)
        }
    }
    
    func initControls() {
        
        animationView.animation = "loadingNew"
        animationView.loopAnimation = true
        animationView.play()
        
        tableView.register(QTPastSessionTableViewCell.nib,
                           forCellReuseIdentifier: QTPastSessionTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 32
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = "Past transactions"
    }
    
    func setupNavBar() {
        navigationItem.title = "Past transactions"
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    fileprivate func attemptReloadOfTable() {
        
        // Sort sessions based on startTime.
        sessionUserInfos.sort(by: {$0.startTime < $1.startTime})
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        
        sessionUserInfos.forEach { (session) in
            let date = Date(timeIntervalSince1970: session.date)
            let dateString = dateFormatter.string(from: date)
            if !self.sessionDates.contains(dateString) {
                self.sessionDates.append(dateString)
            }
            
            if self.sessionGroup[dateString] == nil {
                self.sessionGroup[dateString] = []
            }
            
            self.sessionGroup[dateString]?.append(session)
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadTable), userInfo: nil, repeats: false)
    }
}

extension QTPastSessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(sessionUserInfos[indexPath.row].partnerId(), isQuery: false, { tutor in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller
                controller.user = tutor
                controller.profileViewType = .tutor
                self.navigationController?.pushViewController(controller, animated: true)
            })
        } else {
            FirebaseData.manager.fetchLearner(sessionUserInfos[indexPath.row].partnerId()) { learner in
                guard let learner = learner else { return }
                let controller = QTProfileViewController.controller
                let tutor = AWTutor(dictionary: [:])
                controller.user = tutor.copy(learner: learner)
                controller.profileViewType = .learner
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension QTPastSessionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sessionDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionGroup[sessionDates[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = QTPastSessionSectionHeaderView.view
        headerView?.setData(date: sessionDates[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTPastSessionTableViewCell.reuseIdentifier, for: indexPath) as! QTPastSessionTableViewCell
        if let sessions = sessionGroup[sessionDates[indexPath.section]] {
            cell.setData(sessions[indexPath.row])
        }
        cell.selectionStyle = .none
        return cell
    }
}
