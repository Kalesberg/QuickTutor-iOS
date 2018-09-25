//
//  SessionRequestView.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/3/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import UIKit

protocol SessionRequestViewDelegate {
    func didDismiss()
}

class SessionRequestView: UIView {
    var chatPartnerId: String! {
        didSet {
            loadSubjectsForUserWithId(chatPartnerId) {}
        }
    }

    var delegate: SessionRequestViewDelegate?
    var subject: String?
    var date: Date?
    var startTime: Date?
    var endTime: Date?
    var price: Double?
    var sessionData = [String: Any]()
    var titles = ["Mathematics", "3/20/17", "3:05pm", "5:05pm", "Price"]

    let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.sentMessage
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Request Session"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

    let titleViewSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.darkBackground
        return view
    }()

    let inputTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = Colors.darkBackground
        table.separatorColor = Colors.sentMessage
        table.allowsMultipleSelection = false
        table.isScrollEnabled = false
        table.register(SessionTableCell.self, forCellReuseIdentifier: "cellId")
        return table
    }()

    let inPersonToggle: SessionTypeCell = {
        let toggle = SessionTypeCell()
        toggle.titleLabel.text = "In-Person"
        return toggle
    }()

    let onlineToggle: SessionTypeCell = {
        let toggle = SessionTypeCell()
        toggle.titleLabel.text = "Video Call"
        return toggle
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cancelButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()

    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "resetButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()

    let confirmButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "confirmButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()

    var accessoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let backgroundBlurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var subjectPicker: SubjectPicker = {
        let picker = SubjectPicker()
        picker.subjectDelegate = self
        return picker
    }()

    lazy var datePicker: CustomDatePicker = {
        let picker = CustomDatePicker()
        picker.customDelegate = self
        return picker
    }()

    lazy var startTimePicker: SessionTimePicker = {
        let picker = SessionTimePicker()
        picker.tag = 0
        return picker
    }()

    lazy var endTimePicker: SessionTimePicker = {
        let picker = SessionTimePicker()
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePickerValueChanged(picker)
        picker.tag = 1
        return picker
    }()

    lazy var priceInput: PriceInputView = {
        let input = PriceInputView()
        return input
    }()

    let sessionLengthLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.border
        label.textAlignment = .center
        label.text = "The earliest you can schedule a session is 15 minutes in advance. However, you can attempt to manually start any session early."
        label.numberOfLines = 0
        label.font = Fonts.createItalicSize(12)
        //        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = Colors.navBarColor
        label.isHidden = true
        return label
    }()

    var backgroundHeightAnchor: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setInitialTitles()
        setHeightTo(600, animated: false)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        setupMainView()
        setupTitleView()
        setupInputTable()
        setupSessionTypeStackView()
        setupCanceButton()
        setupResetButton()
        setupConfirmButton()
        setupBackgroundBlurView()
        setupSubjectPicker()
        setupDatePicker()
        setupStartTimePicker()
        setupEndTimePicker()
        setupPriceInput()
        setupSessionLengthLabel()
    }

    private func setupMainView() {
        backgroundColor = Colors.navBarColor
        layer.cornerRadius = 8
        clipsToBounds = true
        switchAccessoryViewTo(subjectPicker)
        subjectPicker.subjectDelegate = self
    }

    private func setupTitleView() {
        addSubview(titleView)
        titleView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 65)

        titleView.addSubview(titleLabel)
        titleLabel.anchor(top: titleView.topAnchor, left: titleView.leftAnchor, bottom: titleView.bottomAnchor, right: titleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        titleView.addSubview(titleViewSeparator)
        titleViewSeparator.anchor(top: nil, left: titleView.leftAnchor, bottom: titleView.bottomAnchor, right: titleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1.5)
    }

    private func setupInputTable() {
        inputTable.delegate = self
        inputTable.dataSource = self
        addSubview(inputTable)
        inputTable.anchor(top: titleView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 250)
    }

    private func setupSessionTypeStackView() {
        addSubview(inPersonToggle)
        inPersonToggle.anchor(top: inputTable.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 150, height: 60)
        addConstraint(NSLayoutConstraint(item: inPersonToggle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -85))
        inPersonToggle.delegate = self

        addSubview(onlineToggle)
        onlineToggle.anchor(top: inputTable.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 150, height: 60)
        onlineToggle.delegate = self
        onlineToggle.setSelected()
    }

    private func setupCanceButton() {
        addSubview(cancelButton)
        cancelButton.anchor(top: inPersonToggle.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        cancelButton.addTitleBelow(text: "Cancel")
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }

    private func setupResetButton() {
        addSubview(resetButton)
        resetButton.anchor(top: inPersonToggle.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        addConstraint(NSLayoutConstraint(item: resetButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        resetButton.addTitleBelow(text: "Reset")
        resetButton.addTarget(self, action: #selector(resetTitles), for: .touchUpInside)
    }

    private func setupConfirmButton() {
        addSubview(confirmButton)
        confirmButton.anchor(top: inPersonToggle.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 40, width: 40, height: 40)
        confirmButton.addTitleBelow(text: "Confirm")
        confirmButton.addTarget(self, action: #selector(confirmRow), for: .touchUpInside)
    }

    private func setupBackgroundBlurView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.insertSubview(backgroundBlurView, belowSubview: self)
        backgroundBlurView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dismissTap.numberOfTapsRequired = 1
        backgroundBlurView.addGestureRecognizer(dismissTap)
    }

    private func setupSessionLengthLabel() {
        addSubview(sessionLengthLabel)
        sessionLengthLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 35)
    }

    @objc func dismiss() {
        delegate?.didDismiss()
        backgroundBlurView.removeFromSuperview()
        removeFromSuperview()
    }

    private func setupSubjectPicker() {
        sessionData["subject"] = "Mathematics"
        subjectPicker.subjectDelegate = self
    }

    private func setupDatePicker() {
        datePicker.customDelegate = self
        datePicker.date = Date()
        sessionData["date"] = Date().timeIntervalSince1970
        setDateTo(Date())
    }

    private func setupStartTimePicker() {
        startTimePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        setStartTime()
        startTimePicker.date = startTimePicker.minimumDate ?? Date()
        reloadTitleForStartTime()
    }

    private func setupEndTimePicker() {
        endTimePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        setEndTime()
        endTimePicker.date = endTimePicker.minimumDate ?? Date()
        reloadTitleForEndTime()
    }

    private func setupPriceInput() {
        priceInput.delegate = self
    }

    func setHeightTo(_ height: CGFloat, animated: Bool) {
        guard let window = UIApplication.shared.keyWindow else { return }
        if let anchor = backgroundHeightAnchor {
            removeConstraint(anchor)
        }
        backgroundHeightAnchor = heightAnchor.constraint(equalToConstant: height)
        backgroundHeightAnchor?.isActive = true
        if animated {
            UIView.animate(withDuration: 0.25) {
                window.layoutIfNeeded()
            }
        } else {
            window.layoutIfNeeded()
        }
    }
}

extension UIButton {
    func addTitleBelow(text: String) {
        let label = UILabel()
        label.textColor = UIColor(hex: "89898D")
        label.textAlignment = .center
        label.text = text
        label.font = Fonts.createBoldSize(10)
        addSubview(label)
        label.anchor(top: bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: -4, paddingBottom: 0, paddingRight: -4, width: 0, height: 15)
    }
}

extension SessionRequestView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 5
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SessionTableCell
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 3 {
            setHeightTo(600, animated: true)
            sessionLengthLabel.isHidden = true
        }
        switch indexPath.row {
        case 0:
            switchAccessoryViewTo(subjectPicker)
        case 1:
            switchAccessoryViewTo(datePicker)
        case 2:
            switchAccessoryViewTo(startTimePicker)
        case 3:
            switchAccessoryViewTo(endTimePicker)
        default:
            switchAccessoryViewTo(priceInput)
        }
    }

    func switchAccessoryViewTo(_ view: UIView) {
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.accessoryView.alpha = 0
        }

        animator.addCompletion { _ in
            self.accessoryView.removeFromSuperview()
            self.accessoryView = view
            self.addSubview(view)
            view.anchor(top: self.resetButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 129)
            self.accessoryView.alpha = 1
        }

        animator.startAnimation()
    }

    @objc func confirmRow() {
        guard let rowIndex = inputTable.indexPathForSelectedRow?.item else { return }
        setTitleGreen(index: rowIndex)

        switch rowIndex {
        case 0:
            let title = subjectPicker.subjects[subjectPicker.selectedRow(inComponent: 0)]
            titles[0] = title
            let indexPath = IndexPath(row: 0, section: 0)
            inputTable.reloadRows(at: [indexPath], with: .automatic)
            sessionData["subject"] = title
            setTitleGreen(index: 0)
        case 1:
            guard let date = datePicker.date?.timeIntervalSince1970 else { return }
            setDateTo(Date(timeIntervalSince1970: date))
            setTitleGreen(index: 1)
        case 2:
            setStartTime()
            setTitleGreen(index: 2)
        case 3:
            setEndTime()
            setTitleGreen(index: 3)
        case 4:
            let price = priceInput.currentPrice
            sessionData["price"] = price
            let priceString = String(format: "%.2f", price)
            titles[4] = "$\(priceString)"
            inputTable.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
            setTitleGreen(index: 4)
        default:
            break
        }
    }

    @objc func sendRequest() {
        var sessionData = [String: Any]()

        //        guard let type = RequestSessionData.isOnline else { print("Please choose a session Type."); return }
        //        guard let subject = RequestSessionData.subject else { print("Please choose a subject"); return }
        //        guard let startTime = RequestSessionData.startTime else { print("Please choose a start time"); return }
        //        guard let endTime = RequestSessionData.endTime else { print("Please choose an end time"); return }
        //        guard let price = RequestSessionData.price else { print("Please choose a hourly rate."); return }
        //
        //        sessionData["status"] = "pending"
        //        sessionData["type"] = type ? "online" : "in-person"
        //        sessionData["expiration"] = getExpiration()
        //        sessionData["senderId"] = CurrentUser.shared.learner.uid
        //        sessionData["receiverId"] = chatPartnerId
        //        sessionData["subject"] = subject
        //        sessionData

        guard let _ = sessionData["subject"], let _ = sessionData["date"], let _ = sessionData["startTime"], let _ = sessionData["endTime"], let _ = sessionData["status"], let _ = sessionData["type"], let _ = sessionData["price"] else {
            return
        }

        let sessionRequest = SessionRequest(data: sessionData)
        DataService.shared.sendSessionRequestToId(sessionRequest: sessionRequest, chatPartnerId)
        dismiss()
    }

    func getExpiration() -> TimeInterval {
        let difference = (endTimePicker.date.timeIntervalSince1970 - Date().timeIntervalSince1970) / 2
        let expirationDate = Date().addingTimeInterval(difference)
        return expirationDate.timeIntervalSince1970
    }

    func setInitialTitles() {
        titles = ["Select Subject", "Select Date", "Select Start Time", "Select End Time", "Select Price"]
    }

    @objc func resetTitles() {
        setInitialTitles()
        setAllTitlesWhite()
        inputTable.reloadData()
    }

    func setTitleGreen(index: Int) {
        guard let cell = inputTable.cellForRow(at: IndexPath(row: index, section: 0)) as? SessionTableCell else { return }
        cell.textLabel?.textColor = Colors.green
    }

    func setTitleBlue(index: Int) {
        guard let cell = inputTable.cellForRow(at: IndexPath(row: index, section: 0)) as? SessionTableCell else { return }
        cell.textLabel?.textColor = Colors.tutorBlue
    }

    func setAllTitlesWhite() {
        for index in 0 ... titles.count {
            guard let cell = inputTable.cellForRow(at: IndexPath(row: index, section: 0)) as? SessionTableCell else { return }
            cell.textLabel?.textColor = .white
        }
    }

    func loadSubjectsForUserWithId(_ id: String, completion _: @escaping () -> Void) {
        Database.database().reference().child("subject").child(id).observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for child in children {
                guard let value = child.value as? [String: Any] else { continue }
                if let subjectList = value["sbj"] as? String {
                    let subjects = subjectList.split(separator: "$")
                    var finalSubjects = [String]()
                    for subject in subjects {
                        print(subject, "\n")
                        finalSubjects.append(String(subject))
                        self.subjectPicker.subjects = finalSubjects
                        self.subjectPicker.reloadAllComponents()
                    }
                }
            }
        }
    }
}

// MARK: Subject -

extension SessionRequestView: SubjectPickerDelegate {
    func didSelectSubject(title _: String) {
        //        titles[0] = title
        //        let indexPath = IndexPath(row: 0, section: 0)
        //        inputTable.reloadRows(at: [indexPath], with: .automatic)
        //        sessionData["subject"] = title
        //        setTitleGreen(index: 0)
    }
}

// MARK: Date -

extension SessionRequestView: CustomDatePickerDelegate {
    func customDatePicker(_: CustomDatePicker, didSelect _: Double) {
        //        setDateTo(Date(timeIntervalSince1970: date))
        //        setTitleGreen(index: 1)
    }

    func setDateTo(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let formattedDate = formatter.string(from: date)
        titles[1] = formattedDate
        let dateTitleIndex = IndexPath(row: 1, section: 0)
        inputTable.reloadRows(at: [dateTitleIndex], with: .automatic)
        sessionData["date"] = date.timeIntervalSince1970
        datePicker.date = date
    }
}

// MARK: Start & End Time -

extension SessionRequestView {
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        if sender.tag == 0 {} else {
            if sender.date == sender.minimumDate! {
                setHeightTo(630, animated: true)
                sessionLengthLabel.isHidden = false
            } else {
                setHeightTo(600, animated: true)
                sessionLengthLabel.isHidden = true
            }
        }
    }

    func setStartTime() {
        if let date = datePicker.date, Calendar.current.isDateInToday(date) {
            startTimePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)
        }
        startTimePicker.minimumDate = nil
        reloadTitleForStartTime()
    }

    func reloadTitleForStartTime() {
        titles[2] = startTimePicker.date.formatRelativeString()
        inputTable.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        sessionData["startTime"] = startTimePicker.date.timeIntervalSince1970
    }

    func setEndTime() {
        endTimePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 15, to: startTimePicker.date)
        reloadTitleForEndTime()
    }

    func reloadTitleForEndTime() {
        titles[3] = endTimePicker.date.formatRelativeString()
        inputTable.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        sessionData["endTime"] = endTimePicker.date.timeIntervalSince1970
    }
}

// MARK: Session Type -

extension SessionRequestView: SessionTypeCellDelegate {
    func didSelect(option: String) {
        if option == "in-person" {
            inPersonToggle.setSelected()
            onlineToggle.setUnselected()
        } else {
            onlineToggle.setSelected()
            inPersonToggle.setUnselected()
        }
    }
}

// MARK: Price -

extension SessionRequestView: PriceInputViewDelegate {
    func priceDidChange(_: Double) {
        //        sessionData["price"] = price
        //        let priceString = String(format: "%.2f", price)
        //        titles[4] = "$\(priceString)"
        //        inputTable.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
        //        setTitleGreen(index: 4)
    }
}
