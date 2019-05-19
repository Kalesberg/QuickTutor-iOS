//
//  TutorPreferencesVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorPreferencesView: BaseRegistrationView {
    
    let cellTitles = ["Online", "In-Person", "Both"]
    
    let hourSliderView: CustomSliderView = {
        let view = CustomSliderView()
        view.titleLabel.text = "Hourly rate"
        view.slider.value = 45
        view.amountLabel.text = "$45/hr"
        return view
    }()
    
    let hourInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.registrationGray
        label.font = Fonts.createBoldSize(16)
        label.text = "Individual sessions can be negotiated. "
        return label
    }()
    
    let quickCallsSliderView: CustomSliderView = {
        let view = CustomSliderView()
        view.titleLabel.text = "Quick calls"
        view.slider.value = 10
        view.amountLabel.text = "$10/hr"
        return view
    }()

    let quickCallsInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.registrationGray
        label.font = Fonts.createBoldSize(16)
        label.text = "This is the price a learner must pay to call you. QuickCalls are billed on a minute-by-minute basis of your hourly rate."
        label.numberOfLines = 0
        return label
    }()

    let quickCallsSwitchView: CustomSwitchView = {
        let view = CustomSwitchView()
        view.isOn = false
        return view
    }()

    let quickCallsOptionalLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.grayText80
        label.text = "Optional"
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let availabilityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.text = "Availability"
        return label
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.register(PillCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = Colors.darkBackground
        return cv
    }()
    
    let distanceSliderView: CustomSliderView = {
        let view = CustomSliderView()
        view.titleLabel.text = "How far can you travel?"
        view.slider.maximumValue = 100
        view.slider.value = 10
        view.amountLabel.text = "10 miles"
        return view
    }()
    
    let distanceInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.registrationGray
        label.font = Fonts.createBoldSize(16)
        label.text = "Must not be longer than 15 characters."
        label.isHidden = true
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupHourSliderView()
        setupHourInfoLabel()
        setupQuickCallsSliderView()
        setupQuickCallsInfoLabel()
        setupQuickCallsSwitchView()
        setupQuickCallsOptionalLabel()
        setupAvailabilityLabel()
        setupCollectionView()
        setupDistanceSliderView()
        setupDistanceInfoLabel()
    }
    
    func setupHourSliderView() {
        addSubview(hourSliderView)
        hourSliderView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
        hourSliderView.delegate = self
    }
    
    func setupHourInfoLabel() {
        addSubview(hourInfoLabel)
        hourInfoLabel.anchor(top: hourSliderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 22)
    }
    
    func setupQuickCallsSliderView() {
        addSubview(quickCallsSliderView)
        quickCallsSliderView.anchor(top: hourInfoLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 27, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
        quickCallsSliderView.delegate = self
    }

    func setupQuickCallsInfoLabel() {
        addSubview(quickCallsInfoLabel)
        quickCallsInfoLabel.anchor(top: quickCallsSliderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
    }

    func setupQuickCallsSwitchView() {
        addSubview(quickCallsSwitchView)
        quickCallsSwitchView.delegate = self
        quickCallsSwitchView.anchor(top: hourInfoLabel.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 30, width: 62, height: 36)
    }

    func setupQuickCallsOptionalLabel() {
        addSubview(quickCallsOptionalLabel)
        quickCallsOptionalLabel.anchor(top: nil, left: nil, bottom: nil, right: quickCallsSwitchView.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        quickCallsOptionalLabel.centerYAnchor.constraint(equalTo: quickCallsSwitchView.centerYAnchor).isActive = true
    }
    
    func setupAvailabilityLabel() {
        addSubview(availabilityLabel)
        availabilityLabel.anchor(top: quickCallsInfoLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 40, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 18)
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: availabilityLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 40)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupDistanceSliderView() {
        addSubview(distanceSliderView)
        distanceSliderView.anchor(top: collectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 40, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
        distanceSliderView.delegate = self
    }
    
    func setupDistanceInfoLabel() {
        addSubview(distanceInfoLabel)
        distanceInfoLabel.anchor(top: distanceSliderView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 60, paddingRight: 30, width: 0, height: 0)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Set your preferences"
    }
}


extension TutorPreferencesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PillCollectionViewCell
        cell.titleLabel.text = cellTitles[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 40)
    }
    
}

extension TutorPreferencesView: CustomSliderViewDelegate {
    func customSlider(_ slider: CustomSlider, didChange value: Float) {
        if slider == hourSliderView.slider {
            hourSliderView.amountLabel.text = "$\(String(format: "%.0f", slider.value))/hr"
        } else if slider == distanceSliderView.slider {
            distanceSliderView.amountLabel.text = "\(String(format: "%.0f", slider.value)) miles"
        } else {
            quickCallsSliderView.amountLabel.text = "$\(String(format: "%.0f", slider.value))/hr"
        }
    }
}

extension TutorPreferencesView: CustomSwitchViewDelegate {
    func customSwitchValueChanged(_ isOn: Bool) {
        quickCallsSliderView.slider.isEnabled = isOn
    }
}
