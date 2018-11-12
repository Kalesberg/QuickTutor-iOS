//
//  TutorMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import UIKit
import FirebaseUI

class TutorMainPageView: UIView {

    let menuLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(22)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Menu"
        return label
    }()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = 1
        tableView.sectionFooterHeight = 7
        tableView.backgroundColor = .clear
        tableView.rowHeight = 60
        return tableView
    }()

    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()

    var qtText: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "qt-small-text")
        return iv
    }()

    func configureView() {
        addSubview(menuLabel)
        addSubview(tableView)
        addSubview(collectionView)
        backgroundColor = Colors.newBackground
        applyConstraints()
    }

    func applyConstraints() {
        menuLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        collectionView.snp.makeConstraints { make in
            if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
                make.height.equalTo(175)
            } else {
                make.height.equalTo(195)
            }
            make.width.equalToSuperview()
            make.top.equalTo(menuLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.93)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(layoutMargins.bottom)
            }
            make.centerX.equalToSuperview()
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

class TutorLayoutView: MainLayoutTitleBackButton {

    var qtText: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "qt-small-text")
        return iv
    }()

    override func configureView() {
        navbar.addSubview(qtText)
        super.configureView()
    }

    override func applyConstraints() {
        super.applyConstraints()

        qtText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class TutorMainPage: UIViewController {
    var contentView: TutorMainPageView {
        return view as! TutorMainPageView
    }

    override func loadView() {
        view = TutorMainPageView()
    }

    var tutor: AWTutor!
    var account: ConnectAccount!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Home"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let tutor = CurrentUser.shared.tutor, let account = CurrentUser.shared.connectAccount else {
            navigationController?.popBackToMain()
            return
        }
        self.tutor = tutor
        self.account = account
    }

    private func configureDelegates() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(TutorMainPageTableViewCell.self, forCellReuseIdentifier: "mainPageTableViewCell")

        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(TutorMainPageCollectionViewCell.self, forCellWithReuseIdentifier: "mainPageCollectionViewCell")
    }
}

extension TutorMainPage: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func numberOfSections(in _: UITableView) -> Int {
        return TutorMainPageCellFactory.cells.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TutorMainPageTableViewCell
        cell.growSemiShrink {
			//HOTFIX: this is to get the dynamic link working for Tutor Profiles. Will have to update this architecture.
			if indexPath.section == 2 {
				DynamicLinkFactory.shared.createLink(userId: CurrentUser.shared.tutor.uid!, completion: { (url) in
					if let url = url {
						let title = CurrentUser.shared.tutor.username != nil ? "Add me on QuickTutor: \(String(CurrentUser.shared.tutor.username!))" : "Add me on QuickTutor"
						let shareAll: [Any] = [title, url]
						let activityController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
						activityController.isModalInPopover = true
						self.present(activityController, animated: true, completion: nil)
					}
				})
				return
			} else {
				let viewController = TutorMainPageCellFactory.cells[indexPath.section].viewController
				if viewController.isModalInPopover {
					self.present(viewController, animated: true, completion: nil)
				} else {
					self.navigationController?.pushViewController(viewController, animated: true)
				}
			}
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TutorMainPageTableViewCell
        cell.shrink()
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TutorMainPageTableViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainPageTableViewCell", for: indexPath) as! TutorMainPageTableViewCell
        cell.title.text = TutorMainPageCellFactory.cells[indexPath.section].mainPageCell.title
        cell.subtitle.text = TutorMainPageCellFactory.cells[indexPath.section].mainPageCell.subtitle

        return cell
    }
}

extension TutorMainPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return TutorMainPageButtonFactory.buttons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainPageCollectionViewCell", for: indexPath) as! TutorMainPageCollectionViewCell

        cell.imageView.image = TutorMainPageButtonFactory.buttons[indexPath.item].mainPageButton.icon
        cell.label.text = TutorMainPageButtonFactory.buttons[indexPath.item].mainPageButton.label
        cell.label.textColor = .white

        // TODO: Crashes when push notification is clicked
//        guard let _ = tutor else { return cell }
//        if indexPath.item == 3 && (tutor.secondsTaught ?? 16 < 15 || tutor.tRating ?? 5 < 4.5) {
//            let lockView = UnlockCellView()
//            lockView.frame.size.height = cell.bounds.height - 30
//            lockView.frame.size.width = cell.bounds.width
//            cell.addSubview(lockView)
//        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorMainPageCollectionViewCell

        cell.growSemiShrink {
//            if indexPath.item == 3 && (self.tutor.secondsTaught < 15 || self.tutor.tRating! < 4.5) {
//                AlertController.genericErrorAlertWithoutCancel(self, title: "This Feature is locked", message: "\'Your Listings\' will be unlocked after you have completed 15 hours of tutoring while maintaining at least a 4.5 rating.")
//            } else {
                let viewController = TutorMainPageButtonFactory.buttons[indexPath.item].viewController
                self.navigationController?.pushViewController(viewController, animated: true)
           // }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorMainPageCollectionViewCell
        cell.shrink()
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorMainPageCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let width = (screenWidth / 3) - 15
        return CGSize(width: width, height: collectionView.frame.height - 10)
    }
}

class UnlockCellView: BaseView {
    let lockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "bigLock")
        return imageView
    }()

    override func configureView() {
        addSubview(lockImageView)
        super.configureView()

        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        applyConstraints()
    }

    override func applyConstraints() {
        lockImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class TutorHeaderLayoutView: TutorLayoutView {
    let headerLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = Fonts.createBoldSize(38)

        return label
    }()

    let subHeaderLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = Fonts.createSize(14)

        return label
    }()

    let imageView = UIImageView()
    let headerContainer = UIView()
    let infoContainer: UIView = {
        let view = UIView()

        view.backgroundColor = Colors.registrationDark
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.divider.cgColor

        return view
    }()

    override func configureView() {
        addSubview(headerContainer)
        headerContainer.addSubview(headerLabel)
        headerContainer.addSubview(imageView)
        addSubview(subHeaderLabel)
        addSubview(infoContainer)
        super.configureView()
    }

    override func applyConstraints() {
        super.applyConstraints()

        headerContainer.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).inset(-40)
            make.height.equalTo(50)
            make.left.equalTo(imageView)
            make.right.equalTo(headerLabel)
            make.centerX.equalToSuperview()
        }

        headerLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.right.equalTo(headerLabel.snp.left).inset(-15)
            make.centerY.equalToSuperview()
        }

        subHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
        }
    }
}
