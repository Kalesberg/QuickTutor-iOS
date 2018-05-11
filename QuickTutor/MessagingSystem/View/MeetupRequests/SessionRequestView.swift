//
//  SessionRequestView.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/3/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

protocol SessionRequestViewDelegate {
    func didDismiss()
}

class SessionRequestView: UIView {
    
    var chatPartnerId: String!
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    }
    
    private func setupMainView() {
        backgroundColor = UIColor(hex: "1E1E26")
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
    }
    
    private func setupConfirmButton() {
        addSubview(confirmButton)
        confirmButton.anchor(top: inPersonToggle.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 40, width: 40, height: 40)
        confirmButton.addTitleBelow(text: "Confirm")
        confirmButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
    }
    
    func setupBackgroundBlurView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.insertSubview(backgroundBlurView, belowSubview: self)
        backgroundBlurView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dismissTap.numberOfTapsRequired = 1
        backgroundBlurView.addGestureRecognizer(dismissTap)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SessionTableCell
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            view.anchor(top: self.resetButton.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
            self.accessoryView.alpha = 1
        }
        
        animator.startAnimation()
    }
    
    @objc func sendRequest() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        sessionData["status"] = "pending"
        sessionData["type"] = onlineToggle.selectionButton.isSelected ? "online" : "in-person"
        sessionData["expiration"] = getExpiration()
        sessionData["senderId"] = uid
        sessionData["receiverId"] = chatPartnerId
        
//        do {
//            let encodedData = try JSONEncoder().encode(<#T##value: Encodable##Encodable#>)
//        }
        
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
    
}

// MARK: Subject -
extension SessionRequestView: SubjectPickerDelegate {
    func didSelectSubject(title: String) {
        titles[0] = title
        let indexPath = IndexPath(row: 0, section: 0)
        inputTable.reloadRows(at: [indexPath], with: .automatic)
        sessionData["subject"] = title
    }
}

// MARK: Date -
extension SessionRequestView: CustomDatePickerDelegate {
    func didSelectDate(_ date: Double) {
        setDateTo(Date(timeIntervalSince1970: date))
    }
    
    func setDateTo(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let formattedDate = formatter.string(from: date)
        titles[1] = formattedDate
        let dateTitleIndex = IndexPath(row: 1, section: 0)
        inputTable.reloadRows(at: [dateTitleIndex], with: .automatic)
        sessionData["date"] = date.timeIntervalSince1970
        self.datePicker.date = date
    }
}

// MARK: Start & End Time -
extension SessionRequestView {
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        if sender.tag == 0 {
            setStartTime()
        } else {
            setEndTime()
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
        endTimePicker.minimumDate = startTimePicker.date
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
    func priceDidChange(_ price: Double) {
        sessionData["price"] = price
    }
}
