//
//  QTSavedTutorsViewController.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/9/30.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase


class QTSavedTutorsViewController: UIViewController {
    
    let refreshControl = UIRefreshControl()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.register(QTSavedTutorCollectionViewCell.nib, forCellWithReuseIdentifier: QTSavedTutorCollectionViewCell.reuseIdentifier)
        cv.register(EmptySavedTutorsBackgroundCollectionViewCell.self, forCellWithReuseIdentifier: "EmptySavedTutorsBackgroundCollectionViewCell")
        return cv
    }()
    
    let btnFindTutor: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.setTitle("Find tutors", for: .normal)
        button.titleLabel?.font = Fonts.createSemiBoldSize(16)
        
        return button
    }()
    
    private var searchController = UISearchController(searchResultsController: nil)

    private var datasource = [AWTutor]()
    private var filteredTutors = [AWTutor] ()
    
    private var setTopLayout = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        view.setNeedsLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 13.0, *) {
            // Extend the view to the top of screen.
            self.edgesForExtendedLayout = UIRectEdge.top
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if #available(iOS 13.0, *) {
            // Extend the view to the top of screen.
            self.edgesForExtendedLayout = []
        }
    }
    
    // MARK: - Event Handlers
    @objc
    private func onClickSearch () {
        DispatchQueue.main.async {
            if #available(iOS 11.0, *) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.navigationItem.hidesSearchBarWhenScrolling = false
                    self.navigationItem.largeTitleDisplayMode = .always
                    if !self.datasource.isEmpty {
                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                    }
                    self.view.setNeedsLayout()
                }) { finished in
                    if finished {
                        self.navigationItem.hidesSearchBarWhenScrolling = true
                        self.navigationItem.largeTitleDisplayMode = .automatic
                    }
                }
            }
        }
    }
    
    @objc
    private func onRefreshSavedTutors () {
        getSavedTutors()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc
    private func onClickBtnFindTutor() {
        let controller = QTQuickSearchViewController.controller
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: false)
    }
    

    // MARK: - Initialize Handlers
    private func setupViews() {
        setupMainView()
        setupCollectionView()
        setupSearchController()
        setupFindTutorView()
        getSavedTutors()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getSavedTutors), name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }

    private func setupMainView() {
        view.backgroundColor = Colors.newScreenBackground
        navigationItem.title = "Saved"
        
        /*if #available(iOS 11.0, *) {
            // Extend the view to the top of screen.
            self.edgesForExtendedLayout = UIRectEdge.top
            self.extendedLayoutIncludesOpaqueBars = true
            self.navigationController?.navigationBar.isTranslucent = false
        }*/
        
        navigationController?.view.backgroundColor = Colors.newNavigationBarBackground
        navigationController?.navigationBar.barTintColor = Colors.newNavigationBarBackground
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onClickSearch))
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 65, paddingRight: 20, width: 0, height: 0)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = Colors.purple
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onRefreshSavedTutors), for: .valueChanged)
    }
    
    private func setupSearchController() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            searchController.searchBar.autocorrectionType = .yes
            searchController.definesPresentationContext = true
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.tintColor = .white
            searchController.searchResultsUpdater = self
        }
    }
    
    private func setupFindTutorView() {
        view.addSubview(btnFindTutor)
        btnFindTutor.translatesAutoresizingMaskIntoConstraints = false
        btnFindTutor.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 65)
        
        btnFindTutor.addTarget(self, action: #selector(onClickBtnFindTutor), for: .touchUpInside)
    }

    
    // MARK: - Get Saved Tutors Handlers
    @objc
    private func getSavedTutors() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let myGroup = DispatchGroup()
        var tutors = [AWTutor]()
        
        Database.database().reference().child("saved-tutors").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let tutorIds = snapshot.value as? [String: Any] else {
                self.datasource.removeAll()
                self.collectionView.reloadData()
                return }
            tutorIds.forEach({ uid, _ in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        return
                    }
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutors.append(tutor)
                    }
                    myGroup.leave()
                })
            })
            myGroup.notify(queue: .main, execute: {
                tutors.sort(by: { (a1: AWTutor, a2: AWTutor) -> Bool in
                    a1.username.lexicographicallyPrecedes(a2.username)
                })
                
                self.datasource.removeAll()
                self.datasource = tutors
                self.collectionView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if #available(iOS 11.0, *) {
                        if !self.setTopLayout {
                            // Extend the view to the top of screen.
                            self.edgesForExtendedLayout = UIRectEdge.top
                            self.extendedLayoutIncludesOpaqueBars = true
                            self.navigationController?.navigationBar.isTranslucent = false
                            self.setTopLayout = true
                            
                            self.setupRefreshControl()
                        }
                    }
                }
            })
        }
    }
    
    
    // MARK: - Search Handlers
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func inSearchMode() -> Bool {
        return !searchBarIsEmpty()
    }
    
    private func filterTutorsForSearchText(_ searchText: String, scope: String = "All") {
        filteredTutors = datasource.filter {
            $0.formattedName.lowercased().contains(searchText.lowercased()) == true
                || $0.subjects?.contains(where: { $0.lowercased().contains(searchText.lowercased())}) == true
        }
    }
}

extension QTSavedTutorsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        let tutors = inSearchMode() ? filteredTutors : datasource
        return tutors.isEmpty ? 1 : tutors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tutors = inSearchMode() ? filteredTutors : datasource
        if tutors.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EmptySavedTutorsBackgroundCollectionViewCell.self), for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTSavedTutorCollectionViewCell.reuseIdentifier, for: indexPath) as! QTSavedTutorCollectionViewCell
        cell.setTutor(tutors[indexPath.item])
        return cell
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        
        let tutors = inSearchMode() ? filteredTutors : datasource
        
        if tutors.isEmpty {
            let emptyString = "Maybe you’re not planning on learning today, but you can always start prepping for tomorrow. Tap the heart on your favorite tutors to save them here."
            let height = emptyString.height(withConstrainedWidth: screen.width - 120, font: Fonts.createSize(15))
            return CGSize(width: screen.width - 60, height: height)
        }
        return CGSize(width: (screen.width - 60) / 2, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let tutors = inSearchMode() ? filteredTutors : datasource
        if !tutors.isEmpty {
            let cell = collectionView.cellForItem(at: indexPath) as! QTSavedTutorCollectionViewCell//TutorCollectionViewCell
            cell.shrink()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let tutors = inSearchMode() ? filteredTutors : datasource
        if !tutors.isEmpty {
            let cell = collectionView.cellForItem(at: indexPath) as! QTSavedTutorCollectionViewCell//TutorCollectionViewCell
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tutors = inSearchMode() ? filteredTutors : datasource
        if tutors.isEmpty {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! QTSavedTutorCollectionViewCell//TutorCollectionViewCell
        cell.growSemiShrink {
            let featuredTutor = tutors[indexPath.item]
            let uid = featuredTutor.uid
            FirebaseData.manager.fetchTutor(uid!, isQuery: false, { (tutor) in
                guard let tutor = tutor else { return }
                DispatchQueue.main.async {
                    
                    let controller = QTProfileViewController.controller
                    controller.subject = featuredTutor.featuredSubject
                    controller.profileViewType = .tutor
                    controller.user = tutor
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension QTSavedTutorsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        filterTutorsForSearchText(query)
        collectionView.reloadData()
    }
}
