//
//  QTQuickSearchViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import TYPagerController

class QTQuickSearchViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var searchBarContainer: CustomSearchBarContainer!
    
    static var controller: QTQuickSearchViewController {
        return QTQuickSearchViewController(nibName: String(describing: QTQuickSearchViewController.self), bundle: nil)
    }
    
    let tabBar = TYTabPagerBar()
    let pagerController = TYPagerController()
    lazy var tabBarTitles = ["All", "Subject", "People"]
    let allSearchVC = QTAllSearchViewController.controller
    let subjectSearchVC = QTSubjectSearchViewController.controller
    let tutorSearchVC = QTTutorSearchViewController.controller
    
    enum QTQuickSearchViewType: Int {
        case all = 0
        case subjects = 1
        case people = 2
    }
    
    var searchFilter: SearchFilter? {
        didSet {
            allSearchVC.searchFilter = searchFilter
            subjectSearchVC.searchFilter = searchFilter
            updateFiltersIcon()
        }
    }
    let tabBarCount = 3
    
    var searchViewType: QTQuickSearchViewType = .all
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        configureViews()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        hideTabBar(hidden: true)
        
        setupPagerController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBarContainer.searchBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabBar(hidden: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    // MARK: - Actions
    @objc
    func handleTextChange() {
        guard let text = searchBarContainer.searchBar.text, !text.isEmpty else {
            searchBarContainer.showSearchClearButton(false)
            searchBarContainer.filtersButton.isHidden = false
            
            NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchAll), object: nil, userInfo: [QTNotificationName.quickSearchAll : ""])
            NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchSubjects), object: nil, userInfo: [QTNotificationName.quickSearchSubjects : ""])
            NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchPeople), object: nil, userInfo: [QTNotificationName.quickSearchPeople : ""])
            return
        }
        
        searchBarContainer.showSearchClearButton()
        searchBarContainer.filtersButton.isHidden = true
        
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchAll), object: nil, userInfo: [QTNotificationName.quickSearchAll : text])
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchSubjects), object: nil, userInfo: [QTNotificationName.quickSearchSubjects : text])
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchPeople), object: nil, userInfo: [QTNotificationName.quickSearchPeople : text])
    }
    
    // MARK: - Functions
    func configureViews() {
        searchBarContainer.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 3), radius: 4)
    }
    
    func setupPagerController() {
        
        self.tabBar.delegate = self
        self.tabBar.dataSource = self
        self.tabBar.register(TYTabPagerBarCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(TYTabPagerBarCell.classForCoder()))
        self.view.addSubview(self.tabBar)
        
        self.pagerController.dataSource = self
        self.pagerController.delegate = self
        self.addChild(self.pagerController)
        self.view.addSubview(self.pagerController.view)
        
        self.tabBar.translatesAutoresizingMaskIntoConstraints = false
        var guide = self.view.layoutMarginsGuide
        if #available(iOS 11.0, *) {
            guide = self.view.safeAreaLayoutGuide
        }
        tabBar.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 15).isActive = true
        tabBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        tabBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
        tabBar.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        tabBar.layout.sectionInset = UIEdgeInsets.zero
        tabBar.layout.barStyle = .progressView
        tabBar.layout.cellWidth = (UIScreen.main.bounds.width - 40) / CGFloat(tabBarCount) 
        tabBar.layout.cellSpacing = 0
        tabBar.layout.cellEdging = 0
        tabBar.layout.progressWidth = tabBar.layout.cellWidth
        tabBar.layout.progressHorEdging = 0
        tabBar.layout.progressColor = Colors.purple
        tabBar.layout.normalTextFont = Fonts.createSize(14)
        tabBar.layout.normalTextColor = .white
        tabBar.layout.selectedTextFont = Fonts.createBoldSize(14)
        tabBar.layout.selectedTextColor = Colors.newTextHighlightColor
        tabBar.collectionView?.isScrollEnabled = false
        
        let separatorView = UIView()
        tabBar.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 0.5).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.backgroundColor = Colors.gray
        tabBar.bringSubviewToFront(separatorView)
        
        self.pagerController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pagerController.view.topAnchor.constraint(equalTo: tabBar.bottomAnchor).isActive = true
        self.pagerController.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        self.pagerController.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.pagerController.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        self.pagerController.scrollView?.alwaysBounceHorizontal = false
        self.pagerController.scrollView?.backgroundColor = Colors.newNavigationBarBackground
        
        tabBar.reloadData()
        pagerController.reloadData()
    }
    
    func setupDelegates() {
        searchBarContainer.delegate = self
        searchBarContainer.searchBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func updateFiltersIcon() {
        if searchFilter != nil {
            searchBarContainer.filtersButton.setImage(UIImage(named:"filtersAppliedIcon"), for: .normal)
        } else {
            searchBarContainer.filtersButton.setImage(UIImage(named:"filterIcon"), for: .normal)
        }
    }
    
    func removeChild(popViewController: Bool) {
        guard popViewController else { return }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TYTabPagerBarDelegate
extension QTQuickSearchViewController: TYTabPagerBarDelegate {
    
}

// MARK: - TYTabPagerBarDataSource
extension QTQuickSearchViewController: TYTabPagerBarDataSource {
    func numberOfItemsInPagerTabBar() -> Int {
        return tabBarCount
    }
    
    func pagerTabBar(_ pagerTabBar: TYTabPagerBar, cellForItemAt index: Int) -> UICollectionViewCell & TYTabPagerBarCellProtocol {
        let cell = pagerTabBar.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TYTabPagerBarCell.classForCoder()), for: index)
        cell.titleLabel.text = self.tabBarTitles[index]
        cell.backgroundColor = Colors.newNavigationBarBackground
        return cell
    }
    
    func pagerTabBar(_ pagerTabBar: TYTabPagerBar, didSelectItemAt index: Int) {
        self.pagerController.scrollToController(at: index, animate: true)
    }
    
    func pagerTabBar(_ pagerTabBar: TYTabPagerBar, widthForItemAt index: Int) -> CGFloat {
        let title = self.tabBarTitles[index]
        return tabBar.cellWidth(forTitle: title)
    }
}

// MARK: - TYPagerControllerDelegate
extension QTQuickSearchViewController: TYPagerControllerDelegate {
    func pagerController(_ pagerController: TYPagerController, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool) {
        self.tabBar.scrollToItem(from: fromIndex, to: toIndex, animate: animated)
    }
    
    func pagerController(_ pagerController: TYPagerController, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        self.tabBar.scrollToItem(from: fromIndex, to: toIndex, progress: progress)
    }
}

// MARK: - TYPagerControllerDataSource
extension QTQuickSearchViewController: TYPagerControllerDataSource {
    func numberOfControllersInPagerController() -> Int {
        return tabBarCount
    }
    
    func pagerController(_ pagerController: TYPagerController, controllerFor index: Int, prefetching: Bool) -> UIViewController {
        switch index {
        case 0:
            allSearchVC.view.backgroundColor = Colors.newNavigationBarBackground
            return allSearchVC
        case 1:
            subjectSearchVC.view.backgroundColor = Colors.newNavigationBarBackground
            return subjectSearchVC
        default:
            tutorSearchVC.view.backgroundColor = Colors.newNavigationBarBackground
            return tutorSearchVC
        }
    }
}

extension QTQuickSearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchBarContainer.shouldBeginEditing()
        searchBarContainer.searchBar.clearButtonTintColor = .white
        NotificationCenter.default.post(name: NSNotification.Name(QTNotificationName.quickSearchBegin), object: nil, userInfo: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBarContainer.searchBar.resignFirstResponder()
        return true
    }
}

extension QTQuickSearchViewController: CustomSearchBarDelegate {
    func customSearchBarDidTapLeftView(_ searchBar: PaddedTextField) {
        
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldBeginEditing: Bool) {
        
    }
    
    func customSearchBar(_ searchBar: PaddedTextField, shouldEndEditing: Bool) {
        removeChild(popViewController: true)
    }
    
    func customSearchBarDidTapFiltersButton(_ searchBar: PaddedTextField) {
        let vc = FiltersVC()
        vc.hidesBottomBarWhenPushed = true
        vc.searchFilter = searchFilter
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func customSearchBarDidTapCancelEditButton(_ searchBar: PaddedTextField) {
        removeChild(popViewController: true)
    }
    
    func customSearchBarDidTapClearButton(_ searchBar: PaddedTextField) {
        handleTextChange()
    }
}
