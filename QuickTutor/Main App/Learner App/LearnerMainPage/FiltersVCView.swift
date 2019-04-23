//
//  FiltersVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class FiltersVCView: UIView {
    
    let ratingCellTitles = ["5 stars", "4 stars and up", "All"]
    let sessionTypeCellTitles = ["Online", "In-Person", "Both"]
    var selectedRatingIndex = 2
    var selectedSessionTypeIndex = 2
    
    
    let hourlyRateSliderView: RangeSliderView = {
        let view = RangeSliderView()
        view.titleLabel.text = "Hourly Rate"
        return view
    }()
    
    let hourlyRateSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundDark
        return view
    }()
    
    let distanceSliderView: RangeSliderView = {
        let view = RangeSliderView()
        view.titleLabel.text = "Distance"
        return view
    }()
    
    let distanceSliderCover: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    let distanceSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundDark
        return view
    }()
    
    let ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Rating"
        label.font = Fonts.createBoldSize(16)
        return label
    }()
    
    let ratingCollectionView: SubjectsCollectionView = {
        let cv = SubjectsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    let ratingSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundDark
        return view
    }()
    
    let sessionTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Session Type"
        label.font = Fonts.createBoldSize(16)
        return label
    }()
    
    let sessionTypeCollectionView: SubjectsCollectionView = {
        let cv = SubjectsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    let accessoryView: RegistrationAccessoryView = {
        let view = RegistrationAccessoryView()
        view.nextButton.setTitle("VIEW", for: .normal)
        return view
    }()
    
    func setupViews() {
        backgroundColor = Colors.darkBackground
        setupHourlyRateSliderView()
        setupHourlyRateSeparator()
        setupDistanceSliderView()
        setupDistanceSeparator()
        setupRatingTitleLabel()
        setupRatingCollectionView()
        setupRatingSeparator()
        setupSessionTypeTitleLabel()
        setupSessionTypeCollectionView()
        setupAccessoryView()
    }
    
    func setupHourlyRateSliderView() {
        addSubview(hourlyRateSliderView)
        hourlyRateSliderView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 87)
        hourlyRateSliderView.rangeSlider.addTarget(self, action: #selector(hourlyRateSliderValueChanged(_:)), for: .valueChanged)
    }
    
    func setupHourlyRateSeparator() {
        addSubview(hourlyRateSeparator)
        hourlyRateSeparator.anchor(top: hourlyRateSliderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 25, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 1)
    }
    
    func setupDistanceSliderView() {
        addSubview(distanceSliderView)
        distanceSliderView.anchor(top: hourlyRateSeparator.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 87)
        distanceSliderView.rangeSlider.addTarget(self, action: #selector(distanceSliderValueChanged(_:)), for: .valueChanged)
    }
    
    func setupDistanceSeparator() {
        addSubview(distanceSeparator)
        distanceSeparator.anchor(top: distanceSliderView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 25, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 1)
    }
    
    func setupRatingTitleLabel() {
        addSubview(ratingTitleLabel)
        ratingTitleLabel.anchor(top: distanceSeparator.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 17)
    }
    
    func setupRatingCollectionView() {
        addSubview(ratingCollectionView)
        ratingCollectionView.anchor(top: ratingTitleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        ratingCollectionView.delegate = self
        ratingCollectionView.dataSource = self
    }
    
    func setupRatingSeparator() {
        addSubview(ratingSeparator)
        ratingSeparator.anchor(top: ratingCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 1)
    }
    
    func setupSessionTypeTitleLabel() {
        addSubview(sessionTypeTitleLabel)
        sessionTypeTitleLabel.anchor(top: ratingSeparator.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 17)
    }
    
    func setupSessionTypeCollectionView() {
        addSubview(sessionTypeCollectionView)
        sessionTypeCollectionView.anchor(top: sessionTypeTitleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 200)
        sessionTypeCollectionView.delegate = self
        sessionTypeCollectionView.dataSource = self
    }
    
    func setupAccessoryView() {
        addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 84)
        accessoryView.nextButtonWidthAnchor?.constant = 168
        accessoryView.layoutIfNeeded()
    }
    
    @objc func hourlyRateSliderValueChanged(_ sender: RangeSlider) {
        hourlyRateSliderView.lowerLimitLabel.text = "$\(String(format: "%.0f", sender.lowerValue.rounded()))/hr"
        hourlyRateSliderView.upperLimitLabel.text = "$\(String(format: "%.0f", sender.upperValue.rounded()))/hr"
    }
    
    @objc func distanceSliderValueChanged(_ sender: RangeSlider) {
        distanceSliderView.lowerLimitLabel.text = "\(String(format: "%.0f", sender.lowerValue.rounded())) mi"
        distanceSliderView.upperLimitLabel.text = "\(String(format: "%.0f", sender.upperValue.rounded())) mi"
    }
    
    func resetFilters() {
        distanceSliderView.rangeSlider.lowerValue = distanceSliderView.rangeSlider.minimumValue
        distanceSliderView.rangeSlider.upperValue = distanceSliderView.rangeSlider.maximumValue
        hourlyRateSliderView.rangeSlider.lowerValue = hourlyRateSliderView.rangeSlider.minimumValue
        hourlyRateSliderView.rangeSlider.upperValue = hourlyRateSliderView.rangeSlider.maximumValue
        ratingCollectionView.selectItem(at: IndexPath(item: 2, section: 0), animated: false, scrollPosition: .top)
        sessionTypeCollectionView.selectItem(at: IndexPath(item: 2, section: 0), animated: false, scrollPosition: .top)
        hourlyRateSliderValueChanged(hourlyRateSliderView.rangeSlider)
        distanceSliderValueChanged(distanceSliderView.rangeSlider)
    }
    
    func setFilters(_ filter: SearchFilter) {
        hourlyRateSliderView.rangeSlider.lowerValue = CGFloat(filter.minHourlyRate ?? 0)
        hourlyRateSliderView.rangeSlider.upperValue = CGFloat(filter.maxHourlyRate ?? 150)
        distanceSliderView.rangeSlider.lowerValue = CGFloat(filter.minDistance ?? 0)
        distanceSliderView.rangeSlider.upperValue = CGFloat(filter.maxDistance ?? 150)
        let ratingIndex = IndexPath(item: filter.ratingType ?? 2, section: 0)
        ratingCollectionView.selectItem(at: ratingIndex, animated: false, scrollPosition: .top)
        let sessionTypeIndex = IndexPath(item: filter.sessionType ?? 2, section: 0)
        sessionTypeCollectionView.selectItem(at: sessionTypeIndex, animated: false, scrollPosition: .top)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FiltersVCView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PillCollectionViewCell
        let titlesArray = collectionView == ratingCollectionView ? ratingCellTitles : sessionTypeCellTitles
        cell.titleLabel.text = titlesArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 95
        let titlesArray = collectionView == ratingCollectionView ? ratingCellTitles : sessionTypeCellTitles
        width = titlesArray[indexPath.item].estimateFrameForFontSize(14).width
        width += 40
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == ratingCollectionView {
            selectedRatingIndex = indexPath.item
        } else {
            selectedSessionTypeIndex = indexPath.item
        }
    }
}
