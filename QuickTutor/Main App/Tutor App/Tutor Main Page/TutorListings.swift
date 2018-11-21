//
//  TutorListings.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorListingsView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(22)
        label.text = "Hitting the front page"
        return label
    }()

    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "orange-gradient-person")
        return view
    }()

    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "dark-pattern").alpha(0.6)
        view.contentMode = .scaleAspectFill
        return view
    }()

    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = .white
        label.numberOfLines = 0
        label.sizeToFit()
        label.text = "The QuickTutor marketplace is currently structured to ensure learners can find the best tutors and that active tutors receive learner leads with a high connection rate.\n\nBeing on the front page of the learner side of the app will highly increase your chances of receiving connection requests and earning money for tutoring.\n\nYour listings enables you to customize how learners view your listing/tutor card on the main page. You can customize your listing photo, price, and subject you tutor so that it differentiates from your actual profile. So, if you'd like to get featured on the main feed -- create a listing and make sure you're tutoring subjects you have experience in."
        return label
    }()

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()

    func configureView() {
        addSubview(scrollView)
        addSubview(backgroundImageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(imageView)
        scrollView.addSubview(bodyLabel)
        insertSubview(backgroundImageView, at: 0)
        backgroundColor = Colors.darkBackground
    }

    func applyConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview().inset(25)
            make.centerX.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).inset(-20)
        }

        bodyLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-25)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TutorListings: BaseViewController {
    override var contentView: TutorListingsView {
        return view as! TutorListingsView
    }

    override func loadView() {
        view = TutorListingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layoutIfNeeded()
        contentView.scrollView.contentSize = CGSize(width: 280, height: contentView.bodyLabel.frame.maxY)
        navigationItem.title = "Getting Featured"
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonX {
            contentView.backgroundImageView.isHidden = true
            navigationController?.popViewController(animated: true)
        }
    }
}
