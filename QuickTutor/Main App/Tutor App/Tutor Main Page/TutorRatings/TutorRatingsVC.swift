//
//  TutorRatingsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/1/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorRatingsVC: UIViewController {
    
    let sectionTitles = ["Tutor Rating", "Statistics", "Top Subcategory", "Learner Reviews"]
    let statisticTitles = ["Sessions", "5-Stars", "Hours"]
    
    var tutor: AWTutor! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var topSubject: (String, UIImage)? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var fiveStars = 0
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.backgroundDark
        cv.showsVerticalScrollIndicator = false
        cv.register(TutorRatingsHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        cv.register(TutorRatingsReviewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ratingsHeader")
        cv.register(TutorRatingsPrimaryCell.self, forCellWithReuseIdentifier: "primaryCell")
        cv.register(TutorRatingsStatisticsCell.self, forCellWithReuseIdentifier: "statisticsCell")
        cv.register(TutorRatingsTopSubjectCell.self, forCellWithReuseIdentifier: "topSubjectCell")
        cv.register(TutorRatingsReviewContainerCell.self, forCellWithReuseIdentifier: "ratingsContainerCell")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTutor()
        updateFiveStarStat()
        findTopSubjects()
    }
    
    func setupTutor() {
        guard let tutor = CurrentUser.shared.tutor else { return }
        self.tutor = tutor
    }
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        navigationItem.title = "Ratings"
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func handleLeftViewTapped() {
        navigationController?.popBackToMain()
    }
    
    func updateFiveStarStat() {
        FirebaseData.manager.fetchUserSessions(uid: tutor.uid, type: "tutor") { sessions in
            guard let sessions = sessions else { return }
            for session in sessions {
                if session.tutorRating == 5 {
                    self.fiveStars += 1
                }
                guard let last = sessions.last else { continue }
                if session.id == last.id {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func findTopSubjects() {
        func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
            return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
        }
        
        FirebaseData.manager.fetchSubjectsTaught(uid: tutor.uid) { subcategoryList in
            let avg = subcategoryList.map({ $0.rating / 5 }).average
            let topSubcategory = subcategoryList.sorted {
                return bayesianEstimate(C: avg, r: $0.rating / 5, v: Double($0.numSessions), m: 0) > bayesianEstimate(C: avg, r: $1.rating / 5, v: Double($1.numSessions), m: 10)
                }.first
            guard let subcategory = topSubcategory?.subcategory else {
                self.topSubject = nil
                return
            }
            self.topSubject = SubjectStore.findSubcategoryImage(subcategory: subcategory)
        }
    }
	
	func getFormattedTimeString(seconds: Int) -> (time: Int, unit: String) {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		let seconds = (seconds % 3600) % 60
		
		if hours > 0 {
			return (time: hours, unit: "Hours")
		} else if minutes > 0 {
			return (time: minutes, unit: "Minutes")
		} else {
			return (time: seconds, unit: "Seconds")
		}
	}
}

extension TutorRatingsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 3
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "primaryCell", for: indexPath) as! TutorRatingsPrimaryCell
            cell.ratingLabel.text = cell.ratingLabel.text?.replacingOccurrences(of: "4.71", with: "\((tutor.tRating)!)")
            cell.detailsLabel.text = cell.detailsLabel.text?.replacingOccurrences(of: "450", with: "\((tutor.tNumSessions)!)")
            return cell
        case 1:
            return getStatisticCell(collectionView: collectionView, indexPath: indexPath)
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topSubjectCell", for: indexPath) as! TutorRatingsTopSubjectCell
            cell.titleLabel.text = topSubject?.0
            cell.subjectIcon.image = topSubject?.1
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ratingsContainerCell", for: indexPath) as! TutorRatingsReviewContainerCell
            if let reviews = tutor.reviews {
                cell.reviews = reviews
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "primaryCell", for: indexPath) as! TutorRatingsPrimaryCell
            return cell
        }

    }
    
    func getStatisticCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statisticsCell", for: indexPath) as! TutorRatingsStatisticsCell
        cell.titleLabel.text = statisticTitles[indexPath.item]
        switch indexPath.item {
        case 0:
            cell.countLabel.text = "\((tutor.tNumSessions)!)"
        case 1:
            cell.countLabel.text = "\(fiveStars)"
        case 2:
			let formattedTimeString = getFormattedTimeString(seconds: tutor.secondsTaught)
            cell.countLabel.text = String(formattedTimeString.time)
			cell.titleLabel.text = formattedTimeString.unit
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: UIScreen.main.bounds.width, height: 100)
        case 1:
            return CGSize(width: (UIScreen.main.bounds.width - 80) / 3, height: 110)
        case 2:
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 150)
        default:
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 180)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard indexPath.section != 3 else {
            return getReviewHeader(indexPath)
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! TutorRatingsHeaderCell
        header.titleLabel.text = sectionTitles[indexPath.section]
        return header
    }
    
    func getReviewHeader(_ indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ratingsHeader", for: indexPath) as! TutorRatingsReviewHeaderCell
		header.parentViewController = self
        header.titleLabel.text = sectionTitles[indexPath.section]
        if let reviews = tutor.reviews {
            header.reviews = reviews
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
    }

}

