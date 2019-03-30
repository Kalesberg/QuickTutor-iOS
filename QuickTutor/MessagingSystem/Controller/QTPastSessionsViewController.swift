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
    
    var pastSessions = [Session]()
    var timer: Timer?
    
    static var controller: QTPastSessionsViewController {
        return QTPastSessionsViewController(nibName: String(describing: QTPastSessionsViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        fetchSessions()
        setupNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Actions
    @objc func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Functions
    func fetchSessions() {
        pastSessions.removeAll()
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
                            if !self.pastSessions.contains(where: { $0.id == session.id }) {
                                self.pastSessions.insert(session, at: 0)
                            }
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
    
    func initControls() {
        
        animationView.animation = "loadingNew"
        animationView.loopAnimation = true
        animationView.play()
        
        tableView.register(QTPastSessionTableViewCell.nib, forCellReuseIdentifier: QTPastSessionTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 112
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = "Past sessions"
    }
    
    func setupNavBar() {
        navigationItem.title = "Past sessions"
        navigationController?.setNavigationBarHidden(false, animated: false)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    fileprivate func attemptReloadOfTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadTable), userInfo: nil, repeats: false)
    }
}

extension QTPastSessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if AccountService.shared.currentUserType == .learner {
            FirebaseData.manager.fetchTutor(pastSessions[indexPath.row].partnerId(), isQuery: false, { tutor in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller
                controller.user = tutor
                controller.profileViewType = .tutor
                self.navigationController?.pushViewController(controller, animated: true)
            })
        } else {
            FirebaseData.manager.fetchLearner(pastSessions[indexPath.row].partnerId()) { learner in
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTPastSessionTableViewCell.reuseIdentifier, for: indexPath) as! QTPastSessionTableViewCell
        cell.setData(session: pastSessions[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}