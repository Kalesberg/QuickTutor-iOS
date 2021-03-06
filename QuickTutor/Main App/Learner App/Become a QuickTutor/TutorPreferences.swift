//
//  TutorPreferences.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorPreferencesNextButton: InteractableView, Interactable {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(18)
        label.textColor = .white
        label.text = "Next"

        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()

        backgroundColor = Colors.tutorBlue

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func touchStart() {
        backgroundColor = Colors.lightBlue
    }

    func didDragOff() {
        backgroundColor = Colors.tutorBlue
    }
}

class TutorPreferencesLayout: MainLayoutTitleBackButton {
    let progressBar = ProgressBar()
    let nextButton = TutorPreferencesNextButton()

    override func configureView() {
        addSubview(progressBar)
        addSubview(nextButton)
        super.configureView()
    }

    override func applyConstraints() {
        super.applyConstraints()

        progressBar.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.height.equalTo(8)
        }
    }
}

class TutorPreferencesView: TutorPreferencesLayout {
    let tableView: UITableView = {
        let tableView = UITableView()

        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        return tableView
    }()

    override func configureView() {
        addSubview(tableView)
        super.configureView()

        title.label.text = "Set Your Preferences"

        addSubview(progressBar)
        progressBar.progress = 0.5
        progressBar.applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).inset(-8)
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(50)
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            if UIScreen.main.bounds.height == 812 {
                make.height.equalTo(80)
            } else {
                make.height.equalTo(60)
            }
        }
    }
}

class TutorPreferences: BaseViewController {
    override var contentView: TutorPreferencesView {
        return view as! TutorPreferencesView
    }

    var price: Int = 5
    var distance: Int = 5

    var inPerson: Bool = true
    var video: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self

        contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
        contentView.tableView.register(EditProfileCheckboxTableViewCell.self, forCellReuseIdentifier: "editProfileCheckboxTableViewCell")
    }

    override func loadView() {
        view = TutorPreferencesView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc
    private func rateSliderValueDidChange(_: UISlider!) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)

        cell.valueLabel.text = "$" + String(Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))

        price = Int(cell.slider.value.rounded(FloatingPointRoundingRule.up))
    }

    @objc
    private func distanceSliderValueDidChange(_: UISlider!) {
        let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! EditProfileSliderTableViewCell)

        let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))

        distance = Int(cell.slider.value.rounded(FloatingPointRoundingRule.up))

        if value % 5 == 0 {
            cell.valueLabel.text = String(value) + " mi"
        }
    }

    private func getUserPreferences() {
        TutorRegistration.price = price
        TutorRegistration.distance = distance

        if inPerson && video {
            TutorRegistration.sessionPreference = 3
        } else if inPerson && !video {
            TutorRegistration.sessionPreference = 2
        } else if !inPerson && video {
            TutorRegistration.sessionPreference = 1
        } else {
            TutorRegistration.sessionPreference = 0
        }
    }

    override func handleNavigation() {
        if touchStartView is TutorPreferencesNextButton {
            getUserPreferences()
            navigationController?.pushViewController(TutorBio(), animated: true)
        }
    }
}

extension TutorPreferences: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 6
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 100
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return 55
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            return 40
        case 5:
            return 40
        default:
            break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none

            let label = UILabel()
            label.font = Fonts.createSize(14)
            label.textColor = Colors.grayText
            label.numberOfLines = 0
            label.text = "Please set your general hourly rate.\n\nAlthough you have a set rate, individual sessions can be negotiable."

            cell.addSubview(label)

            label.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell

            cell.slider.addTarget(self, action: #selector(rateSliderValueDidChange), for: .valueChanged)

            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 100

            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Hourly Rate  ", 15, .white)
                .regular("  [$5-$100]", 15, Colors.grayText)

            cell.header.attributedText = formattedString

            cell.valueLabel.text = "$0"

            return cell
        case 2:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none

            let label = UILabel()
            label.font = Fonts.createSize(14)
            label.textColor = Colors.grayText
            label.numberOfLines = 0
            label.text = "Please set the maximum number of miles you are willing to travel for a tutoring session."

            cell.addSubview(label)

            label.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell

            cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)

            cell.slider.minimumValue = 0
            cell.slider.maximumValue = 150

            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Travel Distance  ", 15, .white)
                .regular("  [0-150 mi]", 15, Colors.grayText)

            cell.header.attributedText = formattedString

            cell.valueLabel.text = "0 mi"

            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell

            cell.label.text = "Tutoring In-Person Sessions?"

            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell

            cell.label.text = "Tutoring Online (Video Call) Sessions?"

            return cell
        default:
            break
        }

        return UITableViewCell()
    }
}
