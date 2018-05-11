//
//  Help.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


import SnapKit
import UIKit
import Foundation


class LearnerHelpView : MainLayoutTitleOneButton {
    
    var subtitle = LeftTextLabel()
    var tableView = UITableView()
    var header = UIView()
	
	var backButton = NavbarButtonBack()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonBack
		}
	}
    override func configureView() {
        addSubview(subtitle)
        addSubview(tableView)
        addSubview(header)
        super.configureView()
        
        title.label.text = "Help"
        
        subtitle.label.text = "Choose an option"
        subtitle.label.font = Fonts.createSize(22)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
        
        header.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        subtitle.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
        
        subtitle.label.snp.remakeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(subtitle.snp.bottom).inset(-20)
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        header.snp.makeConstraints { (make) in
            make.width.equalTo(tableView.snp.width)
            make.top.equalTo(tableView.snp.top)
            make.left.equalTo(tableView.snp.left)
            make.height.equalTo(1)
        }
    }
}

class HelpHeaderScroll : MainLayoutTitleBackButton {
    
    var scrollView = BaseScrollView()
    var header = LeftTextLabel()
    
    override func configureView() {
        addSubview(scrollView)
        scrollView.addSubview(header)
        super.configureView()
        
        header.label.font = Fonts.createSize(22)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        scrollView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.centerX.equalToSuperview()
        }
        
        header.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
        
        header.label.snp.remakeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
        }
    }
}

class HelpSubmitButton : InteractableView, Interactable {
    
    var label = CenterTextLabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        backgroundColor = Colors.learnerPurple
        layer.cornerRadius = 20
        
        label.label.text = "SUBMIT"
        label.label.font = Fonts.createBoldSize(16)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


class SectionTitle : LeftTextLabel {
    
    override func configureView() {
        super.configureView()
        
        label.font = Fonts.createBoldSize(17)
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }
    }
    
    func constrainSelf(top: ConstraintItem) {
        self.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(top)
        }
    }
}

class SectionSubTitle : LeftTextLabel {
    
    override func configureView() {
        super.configureView()
        
        label.font = Fonts.createBoldSize(16)
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func constrainSelf(top: ConstraintItem) {
        self.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(top)
        }
    }
}


public class SectionBody: UILabel, BaseViewProtocol {
    public required init() {
        super.init(frame: .zero)
        configureView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() {
        font = Fonts.createSize(15)
        textColor = Colors.grayText
        numberOfLines = 0
        sizeToFit()
    }
    func applyConstraints() { }
    
    func constrainSelf(top: ConstraintItem) {
        self.snp.makeConstraints { (make) in
            make.top.equalTo(top)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
    }
}



class LearnerHelp : BaseViewController {
    
    override var contentView: LearnerHelpView {
        return view as! LearnerHelpView
    }
    
    var options = ["Account & Payments","QuickTutor Guide","Learner Handbook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomHelpTableViewCell.self, forCellReuseIdentifier: "helpCell" )
    }
    
    override func loadView() {
        view = LearnerHelpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	override func handleNavigation() {
		if touchStartView is NavbarButtonX {
			navigationController?.popViewController(animated: true)
		}
	}
}

extension LearnerHelp : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomHelpTableViewCell = tableView.dequeueReusableCell(withIdentifier: "helpCell") as! CustomHelpTableViewCell
        insertBorder(cell: cell)
        
        cell.textLabel?.text = options[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(AccountPayments(), animated: true)
        case 1:
            self.navigationController?.pushViewController(QTGuide(), animated: true)
        case 2:
            self.navigationController?.pushViewController(LearnerHandook(), animated: true)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame:CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}

class CustomHelpTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTableViewCell() {
        
        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor.black
        selectedBackgroundView = cellBackground
        
        backgroundColor = Colors.registrationDark
        
        textLabel?.textColor = UIColor.white
        textLabel?.font = Fonts.createSize(17.0)
        
        accessoryType = .disclosureIndicator
    }
}
