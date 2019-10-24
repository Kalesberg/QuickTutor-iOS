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
    var dateTimeInfoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_info_rect"), for: .normal)
        return button
    }()
    
    var quickRequest: QTQuickRequestModel!
    var realPrice: Double!
    var minPrice: Double!
    var maxPrice: Double!
    
    static var applyController: QTTutorDiscoverOpportunityApplyViewController {
        return QTTutorDiscoverOpportunityApplyViewController(nibName: String(describing: QTQuickRequestSubmitViewController.self), bundle: nil)
    }
        
    // MARK: - Functions
    func setupDateTimeInfoButton() {
        requestDateView.addSubview(dateTimeInfoButton)
        dateTimeInfoButton.anchor(top: nil, left: requestDateView.titleLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        dateTimeInfoButton.centerYAnchor.constraint(equalTo: requestDateView.titleLabel.centerYAnchor).isActive = true
    }
    
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
        realPrice = maxPrice - price // Tutor budget
        
        let serviceFee = realPrice * 0.1 + 2 // QuickTutor Fee
        let tutoringCost = realPrice - serviceFee // Real cost to be received
        tutorSuggestedPriceLabel.text = String(format: "$%0.2f", realPrice)
        tutorServiceFeeLabel.text = String(format: "$%0.2f", serviceFee)
        tutorRealPriceLabel.text = String(format: "$%0.2f", tutoringCost)
        
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
    
    override func setupTargets() {
        super.setupTargets()
        
        dateTimeInfoButton.isUserInteractionEnabled = true
        dateTimeInfoButton.addTarget(self, action: #selector(handleDateTimeInfoButtonClicked), for: .touchUpInside)
    }
    
    // MARK: - Actions
    override func OnNextButtonClicked(_ sender: Any) {
        
        quickRequest.paymentType = .session
        quickRequest.price = Double(realPrice)
        
        QTQuickRequestService.shared.applyOpportunity(request: quickRequest)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func handlePerSessionTypeViewTapped() {
        paymentType = .session
    }
    
    @objc
    func handleDateTimeInfoButtonClicked() {
        helpAlert = QTQuickRequestAlertModal(frame: .zero)
        helpAlert?.set("Time & Date",
                       "The time & date of the opportunity are editable up until its deadline.")
        helpAlert?.show()
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDateTimeInfoButton()
        configureViews()
        setupObservers()
        setupTargets()
    }
    
    // MARK: - SessionRequestDateViewDelegate
    override func sessionRequestDateView(_ dateView: SessionRequestDateView, didSelect date: Date) {
        quickRequest.startTime = date.timeIntervalSince1970
    }
}
