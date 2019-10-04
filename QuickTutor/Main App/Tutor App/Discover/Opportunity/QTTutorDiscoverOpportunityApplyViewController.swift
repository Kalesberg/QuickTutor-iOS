//
//  QTTutorDiscoverOpportunityApplyViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverOpportunityApplyViewController: QTQuickRequestSubmitViewController {

    // MARK: - Properties
    var quickRequest: QTQuickRequestModel!
    var realPrice: Int!
    var minPrice: Double!
    var maxPrice: Double!
    
    static var applyController: QTTutorDiscoverOpportunityApplyViewController {
        return QTTutorDiscoverOpportunityApplyViewController(nibName: String(describing: QTQuickRequestSubmitViewController.self), bundle: nil)
    }
        
    // MARK: - Functions
    override func configureViews() {
        title = "Submit Application"
        
        // Set subject
        subjectTitleLabel.text = "Subject"
        deleteSubjectButton.isHidden = true
        subjectLabel.text = quickRequest.subject
        selectedSubjectView.isHidden = false
        searchSubjectView.isHidden = true
        
        // Set date & time
        requestDateView.titleLabel.text = "Time & Date"
        requestDateView.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        // Set the start time.
        if Date().timeIntervalSince1970 > quickRequest.startTime {
            if let minimunDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) {
                requestDateView.datePicker.minimumDate = minimunDate
                requestDateView.datePicker.date = minimunDate
            }
        } else {
            if let minimunDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) {
                requestDateView.datePicker.minimumDate = minimunDate
            }
            requestDateView.datePicker.date = Date(timeIntervalSince1970: quickRequest.startTime)
        }
        // Set deadline
        requestDateView.datePicker.maximumDate = Date(timeIntervalSince1970: quickRequest.endTime - Double(quickRequest.duration))
        requestDateView.delegate = self
        
        // Set duration
        sessionDurationView.titleLabel.text = "Amount of time needed"
        sessionDurationView.selectionView.layer.borderColor = Colors.purple.cgColor
        sessionDurationView.setDuration(duration: quickRequest.duration / 60)
        sessionDurationView.isUserInteractionEnabled = false
        
        // Set price
        minPrice = quickRequest.minPrice
        maxPrice = quickRequest.maxPrice
        
        var price = (maxPrice - minPrice) / 2
        price = (maxPrice - price) / 2
        realPrice = Int(maxPrice - price)
        
        tutorSuggestedPriceLabel.text = String(format: "%0.2d", realPrice)
        tutorRealPriceLabel.text = String(format: "%0.2d", realPrice - 5)
        
        // Set price type
        tutorPriceView.isHidden = false
        sessionPriceRangeView.isHidden = true
        
        // Set session type
        sessionType = quickRequest.type
        onlineTypeView.isUserInteractionEnabled = false
        inPersonTypeView.isUserInteractionEnabled = false
        if quickRequest.type == .inPerson {
            inPersonTypeView.isHidden = false
            onlineTypeView.isHidden = true
        } else {
            inPersonTypeView.isHidden = true
            onlineTypeView.isHidden = false
        }
        
        nextButton.setTitle("Submit Application", for: .normal)
    }
    
    // MARK: - Actions
    override func OnNextButtonClicked(_ sender: Any) {
        
        quickRequest.paymentType = .hour
        quickRequest.price = Double(realPrice)
        
        QTQuickRequestService.shared.applyOpportunity(request: quickRequest)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func handlePerSessionTypeViewTapped() {
        paymentType = .session
    }
    
    @objc
    func handlePerHourTypeViewTapped() {
        paymentType = .hour
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        setupObservers()
        setupTargets()
    }
    
    // MARK: - SessionRequestDateViewDelegate
    override func sessionRequestDateView(_ dateView: SessionRequestDateView, didSelect date: Date) {
        quickRequest.startTime = date.timeIntervalSince1970
    }
}
