//
//  FileReport.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import FirebaseUI
import SDWebImage
import SnapKit
import UIKit

enum FileReportTutor: String {
    case LearnerCancelled = "My Learner Cancelled"
    case LearnerLate = "My Learner Was Late"
    case Harassment
    case Other
    case LearnerRude = "My Learner Was Rude"
    case LearnerUnsafe = "My Learner Made Me Feel Unsafe"
    case DidNotMatch = "My Learner Did Not Match His Profile"
    case LearnerTips = "My Learner Asked For A Tip"
    case LearnerDidNotHelp = "My Learner Did Not Help"
}

enum FileReportLearner: String {
    case TutorCancelled = "My Tutor Cancelled"
    case TutorLate = "My Tutor Was Late"
    case Harassment
    case Other
    case TutorRude = "My Tutor Was Rude"
    case TutorUnsafe = "My Tutor Made Me Feel Unsafe"
    case DidNotMatch = "My Tutor Did Not Match His Profile"
    case TutorTips = "My Tutor Asked For A Tip"
    case TutorDidNotHelp = "My Tutor Did Not Help"
}

class LearnerFileReportView: UIView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.backgroundDark
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    func configureView() {
        addSubview(tableView)
        applyConstraints()
    }

    func applyConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FileReportSessionView: BaseView {
    let monthLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(20)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    var dayLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(25)
        label.textColor = .white
        label.textAlignment = .center

        return label
    }()

    var profilePic: UIImageView = {
        let imageView = UIImageView()

        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.scaleImage()

        return imageView
    }()

    var subjectLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(14)
        label.textColor = .white

        return label
    }()

    var nameLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(13)
        label.textColor = .white

        return label
    }()

    var sessionInfoLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(13)
        label.textColor = .white

        return label
    }()

    override func configureView() {
        addSubview(monthLabel)
        addSubview(dayLabel)
        addSubview(profilePic)
        addSubview(subjectLabel)
        addSubview(nameLabel)
        addSubview(sessionInfoLabel)
        super.configureView()

        applyConstraints()
    }

    override func applyConstraints() {
        profilePic.snp.makeConstraints { make in
            make.left.equalTo(monthLabel.snp.right).inset(-5)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(60)
        }

        dayLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(profilePic.snp.centerY)
            make.width.equalTo(40)
        }

        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom)
            make.left.equalTo(dayLabel)
            make.width.equalTo(dayLabel)
        }

        subjectLabel.snp.makeConstraints { make in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.bottom.equalTo(nameLabel.snp.top)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(subjectLabel)
        }

        sessionInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(subjectLabel)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profilePic.layer.cornerRadius = profilePic.frame.height / 2
    }
}

class CheckboxItem: InteractableView {
    var label = UILabel()
    var checkbox = RegistrationCheckbox()

    override func configureView() {
        addSubview(label)
        addSubview(checkbox)
        super.configureView()

        label.textColor = .white
        label.font = Fonts.createSize(16)

        checkbox.isSelected = false

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        checkbox.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(60)
        }
    }

    func constrainSelf(top: ConstraintItem) {
        snp.makeConstraints { make in
            make.top.equalTo(top)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }
    }
}

class FileReportCheckboxLayout: MainLayoutHeader {
    var textBody = SectionBody()
    var cb1 = CheckboxItem()
    var cb2 = CheckboxItem()
    var cb3 = CheckboxItem()
    var submitButton = SubmitButton()

    override func configureView() {
        addSubview(textBody)
        addSubview(cb1)
        addSubview(cb2)
        addSubview(cb3)
        addSubview(submitButton)
        super.configureView()

    }

    override func applyConstraints() {
        super.applyConstraints()

        textBody.constrainSelf(top: header.snp.bottom)

        cb1.constrainSelf(top: textBody.snp.bottom)
        cb2.constrainSelf(top: cb1.snp.bottom)
        cb3.constrainSelf(top: cb2.snp.bottom)

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(250)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(15)
            } else {
                make.bottom.equalToSuperview().inset(15)
            }
            make.centerX.equalToSuperview()
        }
    }
}

class FileReportSubmissionLayout: MainLayoutHeader, Keyboardable {
    var keyboardComponent = ViewComponent()
    var textBody = SectionBody()
    var textView = EditBioTextView()
    var characterCount = LeftTextLabel()
    var submitButton = SubmitButton()
    let errorLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createItalicSize(17)
        label.textColor = .red
        label.isHidden = true
        label.text = "Report must be at least 20 characters."
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    override func configureView() {
        addSubview(textBody)
        addSubview(textView)
        textView.addSubview(errorLabel)
        textView.addSubview(characterCount)
        addKeyboardView()
        addSubview(submitButton)

        super.configureView()

        keyboardView.isUserInteractionEnabled = false

        textView.textView.text = ""
        textView.textView.autocorrectionType = .yes
        textView.textView.returnKeyType = .default
        textView.backgroundColor = Colors.newScreenBackground
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10
        textView.textView.tintColor = Colors.purple
        textView.textView.font = Fonts.createSize(18)
        textView.textView.delegate = self

        characterCount.label.textColor = .white
        characterCount.label.font = Fonts.createSize(14)
        characterCount.label.text = "250"
        characterCount.label.numberOfLines = 1
        characterCount.label.sizeToFit()
    }

    override func applyConstraints() {
        super.applyConstraints()

        textBody.constrainSelf(top: header.snp.bottom)

        if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
            textView.snp.makeConstraints { make in
                make.top.equalTo(textBody.snp.bottom).inset(-15)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
                make.height.equalTo(110)
            }
        } else {
            textView.snp.makeConstraints { make in
                make.top.equalTo(textBody.snp.bottom).inset(-15)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(keyboardView.snp.top).inset(-50)
            }
        }

        characterCount.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(250)
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            } else {
                make.bottom.equalToSuperview().inset(20)
            }
        }

        errorLabel.snp.makeConstraints { make in
            make.left.equalTo(characterCount.snp.right).inset(-10)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    func keyboardWillAppear() {
        textBody.fadeOut(withDuration: 0.2)

        textView.snp.removeConstraints()

        textView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalTo(header.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }

        needsUpdateConstraints()

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    func keyboardDidDisappear() {
        textView.snp.removeConstraints()

        textView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalTo(textBody.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }

        needsUpdateConstraints()

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }

        textBody.fadeIn(withDuration: 0.2, alpha: 1.0)
    }
}

class SubmissionViewControllerVC: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "File Report"
    }
    override func viewWillAppear(_: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillAppear() {
        if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
            (view as! FileReportSubmissionLayout).keyboardWillAppear()
        }
    }

    @objc func keyboardDidDisappear() {
        if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
            (view as! FileReportSubmissionLayout).keyboardDidDisappear()
        }
    }

    override func viewWillDisappear(_: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    func checkReport() {
        let view = (self.view as! FileReportSubmissionLayout)
        if view.textView.textView.text!.count < 20 {
            view.errorLabel.isHidden = false
        } else {
            view.errorLabel.isHidden = true
        }
    }
}

extension FileReportSubmissionLayout: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let maxCharacters = 250

        let characters = textView.text.count
        let charactersFromMax = maxCharacters - characters

        if characters <= maxCharacters {
            characterCount.label.textColor = .white
            characterCount.label.text = String(charactersFromMax)

        } else {
            characterCount.label.textColor = UIColor.red
            characterCount.label.text = String(charactersFromMax)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

class FileReportYesNoLayout: MainLayoutHeader {
    var textBody = SectionBody()
    var label = UILabel()
    var yesButton = SubmitButton()
    var noButton = SubmitButton()

    override func configureView() {
        addSubview(textBody)
        addSubview(label)
        addSubview(yesButton)
        addSubview(noButton)
        super.configureView()

        label.font = Fonts.createSize(22)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Did this help?"

        yesButton.label.label.text = "YES"
        noButton.label.label.text = "NO"
    }

    override func applyConstraints() {
        super.applyConstraints()

        textBody.constrainSelf(top: header.snp.bottom)

        label.snp.makeConstraints { make in
            make.top.equalTo(textBody.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        noButton.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).inset(-20)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
            make.width.equalTo(100)
        }

        yesButton.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).inset(-20)
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.height.equalTo(44)
            make.width.equalTo(100)
        }
    }
}

class LearnerFileReportVC: BaseViewController {
    override var contentView: LearnerFileReportView {
        return view as! LearnerFileReportView
    }

    let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    var localTimeZoneAbbreviation: String {
        return TimeZone.current.abbreviation() ?? ""
    }

    var datasource = [UserSession]() {
        didSet {
            if datasource.count == 0 {
                let view = TutorCardCollectionViewBackground()
                view.label.attributedText = NSMutableAttributedString().bold("No recent sessions!", 22, .white)
                view.label.textAlignment = .center
                view.label.numberOfLines = 0
                contentView.tableView.backgroundView = view
            } else {
                contentView.tableView.backgroundView = nil
            }
            contentView.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseData.manager.fetchUserSessions(uid: CurrentUser.shared.learner.uid, type: "learner") { sessions in
            if let sessions = sessions {
                self.datasource = sessions.sorted(by: { $0.endTime > $1.endTime })
            } else {
                self.datasource = []
            }
        }

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(SessionHistoryCell.self, forCellReuseIdentifier: "sessionHistoryCell")
        navigationItem.title = "Past Sessions"
    }

    override func loadView() {
        view = LearnerFileReportView()
    }

    private func getFormattedTime(unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }

    private func getFormattedDate(unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
        dateFormatter.dateFormat = "d-MMM"
        return dateFormatter.string(from: date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LearnerFileReportVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return datasource.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 85
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionHistoryCell", for: indexPath) as! SessionHistoryCell
        let startTime = getFormattedTime(unixTime: TimeInterval(datasource[indexPath.row].startTime))
        let endTime = getFormattedTime(unixTime: TimeInterval(datasource[indexPath.row].endTime))
        let date = getFormattedDate(unixTime: TimeInterval(datasource[indexPath.row].startTime)).split(separator: "-")
        insertBorder(cell: cell)
        if datasource[indexPath.row].name == "" {
            cell.nameLabel.text = "User no longer exists."
        } else {
            let name = datasource[indexPath.row].name.split(separator: " ")
            if name.count == 2 {
                cell.nameLabel.text = "with \(String(name[0]).capitalized) \(String(name[1]).capitalized.prefix(1))."
            } else {
                cell.nameLabel.text = "with \(String(name[0]).capitalized)"
            }
        }

        cell.profilePic.sd_setImage(with: storageRef.child("student-info").child(datasource[indexPath.row].otherId).child("student-profile-pic1"), placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        cell.subjectLabel.text = datasource[indexPath.row].subject
        cell.monthLabel.text = String(date[1])
        cell.dayLabel.text = String(date[0])
        cell.sessionInfoLabel.text = "\(startTime) - \(endTime)"

        let sessionCost = String(format: "$%.2f", (datasource[indexPath.row].cost))
        cell.sessionInfoLabel.text = "\(startTime) - \(endTime) \(sessionCost)"

        return cell
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let endTime = Double(datasource[indexPath.row].endTime)
        if endTime < Date().timeIntervalSince1970 - 604_800 {
            return false
        }
        return true
    }

    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let fileReport = UITableViewRowAction(style: .default, title: "File Report") { _, indexPath in
            let next = SessionDetailsVC()
            next.datasource = self.datasource[indexPath.row]
            self.navigationController?.pushViewController(next, animated: true)
        }
        return [fileReport]
    }

    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = Colors.backgroundDark
        cell.contentView.addSubview(border)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayLoadingOverlay()
        tableView.allowsSelection = false
        FirebaseData.manager.fetchTutor(datasource[indexPath.row].otherId, isQuery: false) { tutor in
            if let tutor = tutor {
                DispatchQueue.main.async {
                    let controller = QTProfileViewController.controller
                    controller.user = tutor
                    controller.profileViewType = .tutor
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            
            DispatchQueue.main.async {
                tableView.allowsSelection = true
                self.dismissOverlay()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class SessionHistoryCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    let monthLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(20)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    var dayLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(25)
        label.textColor = .white
        label.textAlignment = .center

        return label
    }()

    var profilePic: UIImageView = {
        let imageView = UIImageView()

        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.scaleImage()

        return imageView
    }()

    var subjectLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(14)
        label.textColor = .white

        return label
    }()

    var nameLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(13)
        label.textColor = .white

        return label
    }()

    var sessionInfoLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(13)
        label.textColor = .white

        return label
    }()

    let dateContainer = UIView()

    func configureTableViewCell() {
        addSubview(dateContainer)
        dateContainer.addSubview(monthLabel)
        dateContainer.addSubview(dayLabel)
        addSubview(profilePic)
        addSubview(subjectLabel)
        addSubview(nameLabel)
        addSubview(sessionInfoLabel)

        backgroundColor = Colors.newScreenBackground

        applyConstraints()
    }

    func applyConstraints() {
        dateContainer.snp.makeConstraints { make in
            make.left.height.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        dayLabel.snp.makeConstraints { make in
            make.bottom.equalTo(dateContainer.snp.centerY).inset(5)
            make.width.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(dateContainer.snp.centerY).inset(5)
            make.width.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        profilePic.snp.makeConstraints { make in
            make.left.equalTo(dateContainer.snp.right)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(60)
        }

        subjectLabel.snp.makeConstraints { make in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.bottom.equalTo(nameLabel.snp.top)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(subjectLabel)
        }

        sessionInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(subjectLabel)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profilePic.layer.cornerRadius = profilePic.frame.height / 2
    }
}

class CustomFileReportTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTableViewCell() {
        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor(red: 0.08, green: 0.05, blue: 0.08, alpha: 1)
        selectedBackgroundView = cellBackground

        textLabel?.font = Fonts.createSize(14)
        textLabel?.textColor = Colors.grayText
        textLabel?.adjustsFontSizeToFitWidth = true

        backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)

        accessoryType = .disclosureIndicator
    }
}
