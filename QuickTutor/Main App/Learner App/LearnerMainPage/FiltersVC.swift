//
//  FiltersVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/15/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

struct SearchFilter {
    let minHourlyRate: Int?
    let maxHourlyRate: Int?
    let minDistance: Int?
    let maxDistance: Int?
    let sessionType: Int?
    let ratingType: Int?
}

class FiltersVC: UIViewController {
    
    var searchFilter: SearchFilter?
    
    let contentView: FiltersVCView = {
        let view = FiltersVCView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        setupNavigationBar()
        contentView.resetFilters()
        if let filter = searchFilter {
            contentView.setFilters(filter)
        }
        contentView.accessoryView.nextButton.addTarget(self, action: #selector(pop), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        postFilers()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Filters"
        let resetButton = UIBarButtonItem(image: UIImage(named: "resetFiltersIcon"), style: .plain, target: self, action: #selector(resetFilters))
        navigationItem.rightBarButtonItem = resetButton
    }
    
    override func loadView() {
        view = contentView
    }
    
    @objc func resetFilters() {
        contentView.resetFilters()
    }
    
    func postFilers() {
        let maxHourlyRate = Int(contentView.hourlyRateSliderView.slider.value)
        let maxDistance = Int(contentView.distanceSliderView.slider.value)
        let sessionType = contentView.selectedSessionTypeIndex
        let ratingType = contentView.selectedRatingIndex
        let filter = SearchFilter(minHourlyRate: 0, maxHourlyRate: maxHourlyRate, minDistance: 0, maxDistance: maxDistance, sessionType: sessionType, ratingType: ratingType)
        let userInfo: [AnyHashable: Any] = ["filter": filter]
        NotificationCenter.default.post(name: NotificationNames.QuickSearch.updatedFilters, object: nil, userInfo: userInfo)
    }

    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
}
