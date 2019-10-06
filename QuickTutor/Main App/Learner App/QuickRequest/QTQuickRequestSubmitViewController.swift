//
//  QTQuickRequestSubmitViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/21/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import RangeSeekSlider

class QTQuickRequestSubmitViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var searchSubjectView: QTCustomView!
    @IBOutlet weak var selectedSubjectView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var subjectTitleLabel: UILabel!
    @IBOutlet weak var deleteSubjectButton: UIButton!
    @IBOutlet weak var requestDateView: SessionRequestDateView!
    @IBOutlet weak var sessionDurationView: SessionRequestDurationView!
    @IBOutlet weak var sessionPriceRangeView: UIView!
    @IBOutlet weak var sessionPriceRangeSeekSlider: RangeSeekSlider!
    @IBOutlet weak var priceClassView: QTCustomView!
    @IBOutlet weak var advancedPriceLabel: UILabel!
    @IBOutlet weak var proPriceLabel: UILabel!
    @IBOutlet weak var expertPriceLabel: UILabel!
    @IBOutlet weak var tutorPriceView: UIView!
    @IBOutlet weak var tutorSuggestedPriceLabel: UILabel!
    @IBOutlet weak var tutorRealPriceLabel: UILabel!
    @IBOutlet weak var sessionTypeLabel: UILabel!
    @IBOutlet weak var onlineTypeView: QTCustomView!
    @IBOutlet weak var inPersonTypeView: QTCustomView!
    @IBOutlet weak var onlineTypeViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var inPersonTypeViewWdithAnchor: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: QTCustomButton!
    
    static var controller: QTQuickRequestSubmitViewController {
        return QTQuickRequestSubmitViewController(nibName: String(describing: QTQuickRequestSubmitViewController.self), bundle: nil)
    }
    
    var subject: String? {
        didSet {
            if let subject = subject {
                subjectLabel.text = subject
                selectedSubjectView.isHidden = false
                searchSubjectView.isHidden = true
                
                // Find category with subject and set price class.
                if let categoryName = SubjectStore.shared.findCategoryBy(subject: subject), let categoryInfo = QTGlobalData.shared.categories[categoryName] {
                    
                    if let price = categoryInfo.priceClass {
                        self.advancedPriceLabel.text = "$\(price[0])"
                        self.proPriceLabel.text = "$\(price[1])"
                        self.expertPriceLabel.text = "$\(price[2])"
                        
                        self.sessionPriceRangeSeekSlider.minValue = CGFloat(price[0])
                        self.sessionPriceRangeSeekSlider.selectedMinValue = CGFloat(price[0])
                        self.sessionPriceRangeSeekSlider.maxValue = CGFloat(price[2])
                        self.sessionPriceRangeSeekSlider.selectedMaxValue = CGFloat(price[2])
                    }
                }
                
            } else {
                subjectLabel.text = nil
                selectedSubjectView.isHidden = true
                searchSubjectView.isHidden = false
                
                self.advancedPriceLabel.text = "$0"
                self.proPriceLabel.text = "$10"
                self.expertPriceLabel.text = "$20"
                
                self.sessionPriceRangeSeekSlider.minValue = 0
                self.sessionPriceRangeSeekSlider.selectedMinValue = 0
                self.sessionPriceRangeSeekSlider.maxValue = 20
                self.sessionPriceRangeSeekSlider.selectedMaxValue = 20
            }
            
            QTQuickRequestService.shared.subject = self.subject
            QTQuickRequestService.shared.minPrice = Double(Int(self.sessionPriceRangeSeekSlider.selectedMinValue))
            QTQuickRequestService.shared.maxPrice = Double(Int(self.sessionPriceRangeSeekSlider.selectedMaxValue))
        }
    }
    var sessionType: QTSessionType? {
        didSet {
            if let sessionType = sessionType {
                QTQuickRequestService.shared.sessionType = sessionType
                changeSessionTypeViews()
            }
        }
    }
    var paymentType = QTSessionPaymentType.hour
    var helpAlert: QTQuickRequestAlertModal?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        subject = nil
        configureViews()
        setupObservers()
        setupTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func OnNextButtonClicked(_ sender: Any) {
        if subject == nil {
            showError(error: "Please select a subject")
            return
        }
        
        // Save a quickrequest data to server.
        displayLoadingOverlay()
        QTQuickRequestService.shared.sendQuickRequest { (success, error) in
            self.dismissOverlay()
            if let error = error {
                AlertController.genericErrorAlert(self, message: error)
                return
            }
            
            // Reset the used data
            QTQuickRequestService.shared.reset()
            
            // Push the done screen.
            self.navigationController?.pushViewController(QTQuickRequestDoneViewController(), animated: true)
        }
    }
    
    @IBAction func OnDeleteSubjectButtonClicked(_ sender: Any) {
        subject = nil
    }
    
    @IBAction func OnBudgetInfoButtonClicked(_ sender: Any) {
        helpAlert = QTQuickRequestAlertModal(frame: .zero)
        helpAlert?.set("Budget Information",
                       "Based on your subject selection we’ve complied \naverage industry prices for you so you can know what a reasonable budget looks like.")
        helpAlert?.show()
    }
    
    @objc
    func handleSearchSubject() {
        let vc = QTLearnerAddInterestsViewController()
        vc.isViewing = true
        vc.isForQuickRequest = true
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func onReceiveLearnerDidSelectQuickRequestSubject(_ notification: Notification) {
        
        if let _ = navigationController?.viewControllers.firstIndex(of: self) {
            navigationController?.popToViewController(self, animated: true)
        }
        
        if let userInfo = notification.userInfo, let subject = userInfo["quickRequestSubject"] as? String {
            self.subject = subject
        }
    }
    
    @objc
    func handleOnlineTypeViewTapped() {
        QTQuickRequestService.shared.sessionType = .online
        changeSessionTypeViews()
    }
    
    @objc
    func handleInPersonTypeViewTapped() {
        QTQuickRequestService.shared.sessionType = .inPerson
        changeSessionTypeViews()
    }
    
    // MARK: - Functions
    func configureViews() {
        title = "QuickRequest"
        
        requestDateView.titleLabel.text = "When do you need help?"
        requestDateView.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        requestDateView.delegate = self
        
        sessionDurationView.titleLabel.text = "How long do you need?"
        sessionDurationView.delegate = self
        
        sessionPriceRangeSeekSlider.delegate = self
        sessionPriceRangeSeekSlider.step = 1
        sessionPriceRangeSeekSlider.numberFormatter.allowsFloats = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.sessionDurationView.collectionView.scrollToItem(at: IndexPath(item: 6, section: 0), at: .centeredHorizontally, animated: false)
        }
        
        tutorPriceView.isHidden = true
        
        let sessionTypeWidth = (UIScreen.main.bounds.width - 55) / 2
        onlineTypeViewWidthAnchor.constant = sessionTypeWidth
        inPersonTypeViewWdithAnchor.constant = sessionTypeWidth
        
        sessionType = QTQuickRequestService.shared.sessionType
        
        // Set gradient price class.
        let gradientLayer = CAGradientLayer()
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        gradientLayer.frame = priceClassView.bounds
        gradientLayer.colors = [Colors.purple,
                                Colors.purple.withAlphaComponent(0.3)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        priceClassView.layer.insertSublayer(gradientLayer, at: 0)
        priceClassView.layer.cornerRadius = 5
        priceClassView.clipsToBounds = true
        
        // Add gestures.
        searchSubjectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSearchSubject)))
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceiveLearnerDidSelectQuickRequestSubject(_:)),
                                               name: Notifications.learnerDidSelectQuickRequestSubject.name,
                                               object: nil)
    }
    
    func setupTargets() {
        
        onlineTypeView.isUserInteractionEnabled = true
        onlineTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOnlineTypeViewTapped)))
        
        inPersonTypeView.isUserInteractionEnabled = true
        inPersonTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInPersonTypeViewTapped)))
    }
    
    func changeSessionTypeViews() {
        
        switch QTQuickRequestService.shared.sessionType {
        case .online:
            onlineTypeView.borderColor = Colors.purple
            onlineTypeView.borderWidth = 1
            onlineTypeView.backgroundColor = Colors.newScreenBackground
            
            inPersonTypeView.borderWidth = 0
            inPersonTypeView.backgroundColor = .black
        case .inPerson:
            onlineTypeView.borderWidth = 0
            onlineTypeView.backgroundColor = .black
            
            inPersonTypeView.borderColor = Colors.purple
            inPersonTypeView.borderWidth = 1
            inPersonTypeView.backgroundColor = Colors.newScreenBackground
        default:
            break
        }
    }
    
    func showError(error: String) {
        errorLabel.text = error
        errorLabel.shake()
        errorLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.errorLabel.isHidden = true
        }
    }
    
    // MARK: - SessionRequestDateViewDelegate
    func sessionRequestDateView(_ dateView: SessionRequestDateView, didSelect date: Date) {
        QTQuickRequestService.shared.startTime = date
    }
}

// MARK: - SessionRequestDateViewDelegate
extension QTQuickRequestSubmitViewController: SessionRequestDateViewDelegate {
    
}

// MARK: - SessionRequestDurationViewDelegate
extension QTQuickRequestSubmitViewController: SessionRequestDurationViewDelegate {
    func sessionRequestDurationView(_ durationView: SessionRequestDurationView, didSelect duration: Int) {
        QTQuickRequestService.shared.duration = duration
        // TODO: Update the total price based on the price when tutor apply a quickrequest
    }
    
}

extension QTQuickRequestSubmitViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        return "$\(Int(slider.selectedMaxValue))"
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        return "$\(Int(slider.selectedMinValue))"
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        QTQuickRequestService.shared.minPrice = Double(Int(minValue))
        QTQuickRequestService.shared.maxPrice = Double(Int(maxValue))
    }
}
