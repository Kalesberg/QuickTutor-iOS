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
    var price: Double!
    var realPrice: Double!
    var minPrice: Double!
    var maxPrice: Double!
    
    static var applyController: QTTutorDiscoverOpportunityApplyViewController {
        return QTTutorDiscoverOpportunityApplyViewController(nibName: String(describing: QTQuickRequestSubmitViewController.self), bundle: nil)
    }
    
    override var paymentType: QTSessionPaymentType {
        didSet {
            updatePaymentTypeViews()
            updatePriceViews()
        }
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
        sessionDurationView.titleLabel.text = "Duration"
        sessionDurationView.setDuration(duration: quickRequest.duration / 60)
        sessionDurationView.isUserInteractionEnabled = false
        
        // Set price
        price = quickRequest.maxPrice
        minPrice = quickRequest.minPrice
        maxPrice = quickRequest.maxPrice
        
        tutorPriceTextField.text = String(format: "%0.2f", quickRequest.maxPrice)
        tutorPriceTextField.keyboardType = .decimalPad
        tutorPriceTextField.keyboardAppearance = .dark
        
        let pricePlaceholder = String(format: "%0.2f ~ %0.2f", minPrice, maxPrice)
        tutorPriceTextField.attributedPlaceholder = NSAttributedString(string: pricePlaceholder, attributes: [.foregroundColor: Colors.gray])
        tutorPriceTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Set price type
        tutorPriceView.isHidden = false
        sessionPriceRangeView.isHidden = true
        
        // Set the type of payment as per hour
        paymentType = .hour
        
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
        
        nextButton.setTitle("SUBMIT", for: .normal)
    }
    
    override func setupObservers() {
        
    }
    
    override func setupTargets() {
        tutorPerSessionTypeView.isUserInteractionEnabled = true
        tutorPerSessionTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePerSessionTypeViewTapped)))
        
        tutorPerHourTypeView.isUserInteractionEnabled = true
        tutorPerHourTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePerHourTypeViewTapped)))
    }
    
    func updatePaymentTypeViews() {
        switch paymentType {
        case .hour:
            tutorPerHourTypeView.borderColor = Colors.purple
            tutorPerHourTypeView.borderWidth = 1
            tutorPerHourTypeView.backgroundColor = Colors.newScreenBackground
            
            tutorPerSessionTypeView.borderWidth = 0
            tutorPerSessionTypeView.backgroundColor = .black
        case .session:
            
            tutorPerHourTypeView.borderWidth = 0
            tutorPerHourTypeView.backgroundColor = .black
            
            tutorPerSessionTypeView.borderColor = Colors.purple
            tutorPerSessionTypeView.borderWidth = 1
            tutorPerSessionTypeView.backgroundColor = Colors.newScreenBackground
        }
    }
    
    func updatePriceViews() {
        switch paymentType {
        case .hour:
            minPrice = quickRequest.minPrice
            maxPrice = quickRequest.maxPrice
            realPrice = calculatePrice(price, duration: quickRequest.duration / 60)
        case .session:
            realPrice = price
            minPrice = calculatePrice(quickRequest.minPrice, duration: quickRequest.duration / 60)
            maxPrice = calculatePrice(quickRequest.maxPrice, duration: quickRequest.duration / 60)
        }
        
        let pricePlaceholder = String(format: "%0.2f ~ %0.2f", minPrice, maxPrice)
        tutorPriceTextField.attributedPlaceholder = NSAttributedString(string: pricePlaceholder, attributes: [.foregroundColor: Colors.gray])
        tutorTotalPriceLabel.text = String(format: "$ %0.2f", realPrice)
    }
    
    func calculatePrice(_ price: Double, duration: Int) -> Double {
        let minutesPerHours = 60.0
        return Double(duration) / minutesPerHours * price
    }
    
    // MARK: - Actions
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else {
            tutorPriceTextField.text = String(format: "%0.2f", quickRequest.maxPrice)
            price = quickRequest.maxPrice
            updatePriceViews()
            return
        }
        
        guard let price = Double(text) else { return }
        
        // Price should be set directly in between learner budget (min & max)
        if price < minPrice || price > maxPrice {
            showError(error: String(format: "You can set the price in between %0.2f ~ %0.2f", minPrice, maxPrice))
            tutorPriceTextField.text = String(format: "%0.2f", quickRequest.maxPrice)
            self.price = maxPrice
            updatePriceViews()
            return
        }
        
        self.price = price
        updatePriceViews()
    }
    
    override func OnNextButtonClicked(_ sender: Any) {
        
        quickRequest.paymentType = paymentType
        quickRequest.price = realPrice
        
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
