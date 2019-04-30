//
//  TutorPreferences.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class TutorPreferencesVC: BaseRegistrationController {

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    let contentView: TutorPreferencesView = {
        let view = TutorPreferencesView()
        return view
    }()

    var price: Int = 0
    var distance: Int = 0
    var inPerson: Bool = true
    var inVideo: Bool = true
    var inRegistrationMode = true
    var initialPreferenceData: [String : Any]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTargets()
        loadPrefences()
        progressView.setProgress(1/6)
    }

    override func loadView() {
        view = scrollView
    }

    func setupViews() {
        scrollView.addSubview(contentView)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let contentViewHeightAnchor = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentViewHeightAnchor.priority = UILayoutPriority(rawValue: 250)
        contentViewHeightAnchor.isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    func setupTargets() {
        contentView.accessoryView.nextButton.addTarget(self, action: #selector(savePreferences), for: .touchUpInside)
    }
    
    func loadPrefences() {
        if let uid = Auth.auth().currentUser?.uid, !inRegistrationMode {
            FirebaseData.manager.fetchTutorSessionPreferences(uid: uid) {[weak self] (preferenceData) in
                guard let preferenceData = preferenceData else { return }
                self?.initialPreferenceData = preferenceData
                if let price = preferenceData["price"] as? Int {
                    self?.contentView.hourSliderView.setSliderValue(Float(price))
                }
                if let quickCallsPrice = preferenceData["quick_calls"] as? Int {
                    // If the price of quick calls is -1, the quick call switch will be off.
                    self?.contentView.quickCallsSwitchView.isOn = quickCallsPrice != -1
                    self?.contentView.quickCallsSliderView.slider.isEnabled = quickCallsPrice != -1
                    self?.contentView.quickCallsSliderView.setSliderValue(Float(quickCallsPrice))
                }
                if let distance = preferenceData["distance"] as? Int {
                    self?.contentView.distanceSliderView.setSliderValue(Float(distance))
                }
                
                let preference = preferenceData["preference"] as? Int ?? 3
                self?.selectIndex(index: preference)
            }
        }
        
        if inRegistrationMode {
            selectIndex(index: 2)
        }
    }
    
    func selectIndex(index: Int) {
        if index < contentView.cellTitles.count {
            self.contentView.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    func isContextDirty() -> Bool {
        guard let index = contentView.collectionView.indexPathsForSelectedItems?[0].item, let data = self.initialPreferenceData else {
            return false
        }
        
        let preference = data["preference"] as? Int
        let distance = data["distance"] as? Int
        let price = data["price"] as? Int
        let quickCallsPrice = data["quick_calls"] as? Int
        return preference != index
            || distance != roundedDistance()
            || price != roundedHour()
            || quickCallsPrice != roundedQuickCallsPrice()
    }
    
    @objc func backAction() {
        if isContextDirty() {
            displayUnSavedChangesAlertController()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func savePreferences() {
        if inRegistrationMode {
            TutorRegistration.price = roundedHour()
            TutorRegistration.distance = roundedDistance()
            TutorRegistration.quickCallsPrice = isEnableQuickCalls() ? roundedQuickCallsPrice() : -1
            
            guard let indexPath = contentView.collectionView.indexPathsForSelectedItems, !indexPath.isEmpty else {
                return
            }
            
            if let index = indexPath.first?.item {
                TutorRegistration.sessionPreference = index
            } else {
                TutorRegistration.sessionPreference = 3
            }
            
            let next = TutorBioVC()
            navigationController?.pushViewController(next, animated: true)
        } else {
            guard let uid = Auth.auth().currentUser?.uid, let index = contentView.collectionView.indexPathsForSelectedItems?[0].item else { return }
            var preferenceData = [String: Any]()
            preferenceData["prf"] = index
            preferenceData["dst"] = roundedDistance()
            preferenceData["p"] = roundedHour()
            preferenceData["quick_calls"] = isEnableQuickCalls() ? roundedQuickCallsPrice() : -1
            Database.database().reference().child("tutor-info").child(uid).updateChildValues(preferenceData)
            displaySavedAlertController()
            navigationController?.popViewController(animated: true)
        }
    }
    
    func roundedDistance() -> Int {
        return Int(round(contentView.distanceSliderView.slider.value))
    }
    
    func roundedHour() -> Int {
        return Int(round(contentView.hourSliderView.slider.value))
    }
    
    func roundedQuickCallsPrice() -> Int {
        return Int(round(contentView.quickCallsSliderView.slider.value))
    }
    
    func isEnableQuickCalls() -> Bool {
        return contentView.quickCallsSwitchView.isOn
    }
    
    func displayUnSavedChangesAlertController() {
        let alertController = UIAlertController(title: "Unsaved changes", message: "Would you like to save your changes?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            self.savePreferences()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your preference changes have been saved", preferredStyle: .alert)
        
        present(alertController, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
