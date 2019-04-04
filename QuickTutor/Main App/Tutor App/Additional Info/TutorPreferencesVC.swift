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

    let contentView: TutorPreferencesView = {
        let view = TutorPreferencesView()
        return view
    }()

    var price: Int = 0
    var distance: Int = 0
    var inPerson: Bool = true
    var inVideo: Bool = true
    var inRegistrationMode = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        loadPrefences()
        progressView.setProgress(1/6)
    }

    override func loadView() {
        view = contentView
    }

    func setupTargets() {
        contentView.accessoryView.nextButton.addTarget(self, action: #selector(savePreferences), for: .touchUpInside)
    }
    
    func loadPrefences() {
        guard let uid = Auth.auth().currentUser?.uid, !inRegistrationMode else { return }
        FirebaseData.manager.fetchTutorSessionPreferences(uid: uid) { (preferenceData) in
            guard let preferenceData = preferenceData else { return }
            let price = preferenceData["price"] as? Int
            self.contentView.hourSliderView.slider.value = Float(price ?? 25)
            self.contentView.hourSliderView.amountLabel.text = "$\(price!)/hr"
            let distance = preferenceData["distance"] as? Int
            self.contentView.distanceSliderView.slider.value = Float(distance ?? 10)
            self.contentView.distanceSliderView.amountLabel.text = "\(distance!) miles"
            let preference = preferenceData["preference"] as? Int ?? 3
            self.contentView.collectionView.selectItem(at: IndexPath(item: preference, section: 0), animated: false, scrollPosition: .top)
        }
        if inRegistrationMode {
             self.contentView.collectionView.selectItem(at: IndexPath(item: 3, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    @objc func savePreferences() {
        if inRegistrationMode {
            TutorRegistration.price = Int(contentView.hourSliderView.slider.value)
            TutorRegistration.distance = Int(contentView.distanceSliderView.slider.value)
            guard let index = contentView.collectionView.indexPathsForSelectedItems?[0].item else {
                TutorRegistration.sessionPreference = 0
                return
            }
            if index == 0 {
                TutorRegistration.sessionPreference = 1
            } else if index == 1 {
                TutorRegistration.sessionPreference = 2
            } else {
                TutorRegistration.sessionPreference = 3
            }
            let next = TutorBioVC()
            navigationController?.pushViewController(next, animated: true)
        } else {
            guard let uid = Auth.auth().currentUser?.uid, let index = contentView.collectionView.indexPathsForSelectedItems?[0].item else { return }
            var preferenceData = [String: Any]()
            preferenceData["prf"] = index
            preferenceData["dst"] = Int(contentView.distanceSliderView.slider.value)
            preferenceData["p"] = Int(contentView.hourSliderView.slider.value)
            Database.database().reference().child("tutor-info").child(uid).updateChildValues(preferenceData)
            displaySavedAlertController()
            navigationController?.popViewController(animated: true)
        }
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
