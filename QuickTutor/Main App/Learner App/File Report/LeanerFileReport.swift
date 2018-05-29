//
//  FileReport.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

enum FileReportClass : String {
	
	case TutorCancelled = "tutor_cancelled"
	case TutorLate = "tutor_late"
	case Harassment = "harassment"
	case Other = "other"
	case TutorRude = "tutor_rude"
	case TutorUnsafe = "tutor_unsafe"
	case DidNotMatch = "tutor_did_not_match"
	case TutorTips = "tutor_tips"
	case TutorDidNotHelp = "tutor_did_not_help"
	
}

class LearnerFileReportView : MainLayoutHeader {
    
	let tableView : UITableView = {
		let tableView = UITableView.init(frame: .zero, style: .grouped)
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tableView.estimatedSectionHeaderHeight = 85
		
		return tableView
	}()


	override func configureView() {
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "File Report"
        header.text = "Your Past Sessions"
        
        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
		
		applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
		}
	}
}

class FileReportSessionView : BaseView {
    
	let monthLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(20)
		label.textColor = .white
		label.text = "Dec"
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	var dayLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(25)
		label.textColor = .white
		label.text = "28"
		label.textAlignment = .center
		
		return label
	}()
	
	var profilePic : UIImageView = {
		let imageView = UIImageView()
		imageView.scaleImage()
		
		return imageView
	}()
	
	var subjectLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(14)
		label.textColor = .white
		label.text = "Mathematics"
		
		return label
	}()
	
	var nameLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(13)
		label.textColor = .white
		label.text = "with Alex Zoltowski"
		
		return label
	}()
	var sessionInfoLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(13)
		label.textColor = .white
		label.text = "3:00-6:00, $18.50"
		
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
        profilePic.snp.makeConstraints { (make) in
            make.left.equalTo(monthLabel.snp.right)
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(85)
        }
        
        dayLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(profilePic.snp.centerY)
            make.width.equalTo(40)
        }
        
        monthLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dayLabel.snp.bottom)
            make.left.equalTo(dayLabel)
            make.width.equalTo(dayLabel)
        }
        
        subjectLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profilePic.snp.right)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(subjectLabel.snp.bottom)
            make.left.equalTo(subjectLabel)
        }
        
        sessionInfoLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(subjectLabel.snp.top)
            make.left.equalTo(subjectLabel)
        }
    }
}

class CheckboxItem : InteractableView {
    
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
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        checkbox.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(60)
        }
    }
    
    func constrainSelf(top: ConstraintItem) {
        self.snp.makeConstraints { (make) in
            make.top.equalTo(top)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }
    }
}

class FileReportCheckboxLayout : MainLayoutHeader {
    
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
        
        title.label.text = "File Report"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        textBody.constrainSelf(top: header.snp.bottom)
        
        cb1.constrainSelf(top: textBody.snp.bottom)
        cb2.constrainSelf(top: cb1.snp.bottom)
        cb3.constrainSelf(top: cb2.snp.bottom)
        
        submitButton.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.width.equalTo(250)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(15)
            make.centerX.equalToSuperview()
        }
    }
}

class FileReportSubmissionLayout : MainLayoutHeader, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    var textBody = SectionBody()
    var textView = EditBioTextView()
	var characterCount = LeftTextLabel()
    var submitButton = SubmitButton()
    let errorLabel : UILabel = {
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
        
        title.label.text = "File Report"
        keyboardView.isUserInteractionEnabled = false
		
        textView.textView.text = ""
		textView.textView.autocorrectionType = .yes
		textView.textView.returnKeyType = .default
		textView.backgroundColor = Colors.registrationDark
		textView.layer.borderWidth = 1.0
		textView.layer.cornerRadius = 10
		textView.textView.tintColor = Colors.learnerPurple
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
        
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            textView.snp.makeConstraints { (make) in
                make.top.equalTo(textBody.snp.bottom).inset(-15)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
                make.height.equalTo(110)
            }
        } else {
            textView.snp.makeConstraints { (make) in
                make.top.equalTo(textBody.snp.bottom).inset(-15)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(keyboardView.snp.top).inset(-50)
            }
        }
        
        characterCount.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
		
        submitButton.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.width.equalTo(250)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(characterCount.snp.right).inset(-10)
            make.bottom.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(5)
        }
    }
    
    func keyboardWillAppear() {
        textBody.fadeOut(withDuration: 0.2)
        
        textView.snp.removeConstraints()
        
        textView.snp.makeConstraints { (make) in
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
        
        textView.snp.makeConstraints { (make) in
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

class SubmissionViewController : BaseViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: Notification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillAppear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            (self.view as! FileReportSubmissionLayout).keyboardWillAppear()
        }
    }
    
    @objc func keyboardDidDisappear() {
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            (self.view as! FileReportSubmissionLayout).keyboardDidDisappear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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

extension FileReportSubmissionLayout : UITextViewDelegate {
	
	func textViewDidChange(_ textView: UITextView) {
		let maxCharacters = 250
		
		let characters = textView.text.count
		let charactersFromMax = maxCharacters - characters

		if (characters <= maxCharacters) {
			characterCount.label.textColor = .white
			characterCount.label.text = String(charactersFromMax)
			
		} else {
			characterCount.label.textColor = UIColor.red
			characterCount.label.text = String(charactersFromMax)
		}
	}
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
}

class FileReportYesNoLayout : MainLayoutHeader {
    
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
        
        title.label.text = "File Report"
        
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
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(textBody.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        yesButton.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).inset(-20)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
            make.width.equalTo(100)
        }
        
        noButton.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).inset(-20)
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.height.equalTo(44)
            make.width.equalTo(100)
        }
    }
}
struct UserSession {
	
	let date : Double
	let endTime : Int
	let expiration : Double
	let price : Int
	var otherId : String
	let startTime : Int
	let status : String
	let subject : String
	let type : String
	
	var name : String = ""
	var imageURl : String = ""
	
	init(dictionary: [String: Any]) {
		date = dictionary["date"] as? Double ?? 0.0
		endTime = dictionary["endTime"] as? Int ?? 0
		expiration = dictionary["expiration"] as? Double ?? 0.0
		price = dictionary["price"] as? Int ?? 0
		startTime = dictionary["startTime"] as? Int ?? 0
		status = dictionary["status"] as? String ?? ""
		subject = dictionary["subject"] as? String ?? ""
		type = dictionary["type"] as? String ?? ""
		otherId = (AccountService.shared.currentUserType == .learner) ? dictionary["receiverId"] as? String ?? "" : dictionary["senderId"] as? String ?? ""
	}
	
}

class LearnerFileReport : BaseViewController {
    
    override var contentView: LearnerFileReportView {
        return view as! LearnerFileReportView
    }
	
	var datasource = [UserSession]() {
		didSet {
			contentView.tableView.reloadData()
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		
		FirebaseData.manager.getUserSessions(uid: CurrentUser.shared.learner.uid) { (sessions) in
			self.datasource = sessions
		}
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(CustomFileReportTableViewCell.self, forCellReuseIdentifier: "fileReportCell")
		
		contentView.tableView.reloadData()
    }
	
    override func loadView() {
        view = LearnerFileReportView()
    }
	
	private func getStartTime(unixTime: TimeInterval) -> String {
		let date = Date(timeIntervalSince1970: unixTime)
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "hh:mm a"
		
		return dateFormatter.string(from: date)
	}
	
	private func getDateAndEndTime(unixTime: TimeInterval) -> (String, String, String) {
		let date = Date(timeIntervalSince1970: unixTime)
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "d-MMM-hh:mm a"
		let dateString = dateFormatter.string(from: date).split(separator: "-")
		return (String(dateString[0]), String(dateString[1]), String(dateString[2]))
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}
extension LearnerFileReport : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : CustomFileReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileReportCell", for: indexPath) as! CustomFileReportTableViewCell

		cell.textLabel?.text = "File a report with this session"
		return cell
	}
	
    func numberOfSections(in tableView: UITableView) -> Int {
		return datasource.count
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = FileReportSessionView()
		view.applyGradient(firstColor: Colors.learnerPurple.cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 110, frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 85))
		
		let endTimeString = getDateAndEndTime(unixTime: TimeInterval(datasource[section].endTime))
		
		view.nameLabel.text = "with \(datasource[section].name)"
		view.profilePic.loadUserImages(by: datasource[section].imageURl)
		view.subjectLabel.text = datasource[section].subject
		view.monthLabel.text = endTimeString.1
		view.dayLabel.text = endTimeString.0
		
		let startTime = getStartTime(unixTime: TimeInterval(datasource[section].startTime))
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		if let amount = formatter.string(from: datasource[section].price as NSNumber) {
			view.sessionInfoLabel.text = "\(startTime) - \(endTimeString.2) \(amount)"
		}
		
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return tableView.estimatedSectionHeaderHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let next = SessionDetails()
		next.datasource = datasource[indexPath.section]
		self.navigationController?.pushViewController(next, animated: true)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}


class CustomFileReportTableViewCell : UITableViewCell {

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
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
