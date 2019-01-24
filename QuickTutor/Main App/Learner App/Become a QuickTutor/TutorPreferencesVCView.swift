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
        label.text = "Individual sessions can be negotiable. "
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
    
    let accessoryView: RegistrationAccessoryView = {
        let view = RegistrationAccessoryView()
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        setupHourSliderView()
        setupHourInfoLabel()
        setupAvailabilityLabel()
        setupCollectionView()
        setupDistanceSliderView()
        setupDistanceInfoLabel()
        setupAccessoryView()
    }
    
    func setupHourSliderView() {
        addSubview(hourSliderView)
        hourSliderView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 60)
        hourSliderView.delegate = self
    }
    
    func setupHourInfoLabel() {
        addSubview(hourInfoLabel)
        hourInfoLabel.anchor(top: hourSliderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 22)
    }
    
    func setupAvailabilityLabel() {
        addSubview(availabilityLabel)
        availabilityLabel.anchor(top: hourInfoLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 40, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 18)
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: availabilityLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 40)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupDistanceSliderView() {
        addSubview(distanceSliderView)
        distanceSliderView.anchor(top: collectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 40, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 60)
        distanceSliderView.delegate = self
    }
    
    func setupDistanceInfoLabel() {
        addSubview(distanceInfoLabel)
        distanceInfoLabel.anchor(top: distanceSliderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 22)
    }
    
    func setupAccessoryView() {
        addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
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
        } else {
            distanceSliderView.amountLabel.text = "\(String(format: "%.0f", slider.value)) miles"
        }
    }
}
