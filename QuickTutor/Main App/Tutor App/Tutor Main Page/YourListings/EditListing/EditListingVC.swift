//
//  EditListing.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class EditListingVC: BaseViewController {
    override var contentView: EditListingView {
        return view as! EditListingView
    }

    override func loadView() {
        view = EditListingView()
    }

    var tutor: AWTutor! {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var price: Int?
    var subject: String?
    var image: UIImage?
    var category: String!
    var delegate: UpdateListingCallBack?

    var selectedIndexPath: IndexPath?
    let listingPicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        tutor = CurrentUser.shared.tutor
        configureDelegates()

        guard let tutorSubjects = tutor.subjects else { return }
        guard let subject = subject, let index = tutorSubjects.index(of: subject) else { return }
        selectedIndexPath = IndexPath(item: index, section: 0)
    }

    override func viewWillAppear(_: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    override func viewWillDisappear(_: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureDelegates() {
        listingPicker.delegate = self
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(EditListingsSubjectsTableViewCell.self, forCellReuseIdentifier: "editListingsSubjectsTableViewCell")
        contentView.tableView.register(EditListingPhotoTableViewCell.self, forCellReuseIdentifier: "editListingPhotoTableViewCell")
        contentView.tableView.register(EditProfileHourlyRateTableViewCell.self, forCellReuseIdentifier: "editProfileHourlyRateTableViewCell")
    }

    private func handleListingErrorsAndSave() {
        guard let subject = self.subject else {
            AlertController.genericErrorAlertWithoutCancel(self, title: "Please Fill Out All Fields", message: "Add a subject you would like to post on this listing.")
            return ()
        }
        guard let cell = contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditProfileHourlyRateTableViewCell else { return }

        guard let price = Int(cell.amount), price >= 5 else {
            AlertController.genericErrorAlertWithoutCancel(self, title: "Please Fill Out All Fields", message: "Add a price to this listing. Your listing price must be between $5 - $1000.")
            return
        }
        guard let image = self.image else {
            AlertController.genericErrorAlertWithoutCancel(self, title: "Please Fill Out All Fields", message: "Add an image to this listing.")
            return
        }
        view.endEditing(true)
        saveListingToFirebase(subject: subject, price: price, image: image)
    }

    private func saveListingToFirebase(subject: String, price: Int, image: UIImage) {
        displayLoadingOverlay()
        FirebaseData.manager.updateListing(tutor: tutor, category: category, image: image, price: price, subject: subject) { success in
            if success {
                AlertController.genericSavedAlert(self, title: "Your listing has been saved!", message: nil)
                self.delegate?.updateListingCallBack(price: price, subject: subject, image: image)
            } else {
                AlertController.genericErrorAlertWithoutCancel(self, title: "Error uploading listing", message: "Something went wrong, please try again.")
            }
            self.dismissOverlay()
        }
    }

    @objc private func handleAddButton() {
        AlertController.cropImageAlert(self, imagePicker: listingPicker, allowsEditing: false)
    }

    @objc private func keyboardWillAppear(_: NSNotification) {
        if UIScreen.main.nativeBounds.height == 1136 {
            contentView.tableView.setContentOffset(CGPoint(x: 0, y: 310), animated: true)
        } else {
            contentView.tableView.setContentOffset(CGPoint(x: 0, y: 210), animated: true)
        }
    }

    private func subcategoriesForCategory() -> [String]? {
        guard let subcategories = Category.category(for: self.category)?.subcategory.subcategories else { return nil }
        return subcategories.map { $0.lowercased() }
    }

    private func getSubjectsForCategory() -> [String]? {
        guard let subcategories = subcategoriesForCategory() else { return nil }
        var subjectsToDisplay = [String]()
        for subject in tutor.selected {
            if subcategories.contains(subject.path.lowercased()) {
                subjectsToDisplay.append(subject.subject)
            }
        }
        return subjectsToDisplay
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonSave {
            handleListingErrorsAndSave()
        }
    }
}

protocol AmountTextFieldDidChange {
    func amountTextFieldDidChange(amount: Int)
}

extension EditListingVC: AmountTextFieldDidChange {
    func amountTextFieldDidChange(amount: Int) {
        price = amount
    }
}

extension EditListingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 3
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 275
        case 1:
            return 90
        case 2:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editListingPhotoTableViewCell", for: indexPath) as! EditListingPhotoTableViewCell
            if image != nil {
                cell.listingImage.image = image
            }

            cell.addButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editListingsSubjectsTableViewCell", for: indexPath) as! EditListingsSubjectsTableViewCell

            cell.label.text = "Choose featured subject:"
            cell.label.textColor = .white
            cell.label.font = Fonts.createBoldSize(18)
			cell.backgroundColor = Colors.backgroundDark
            cell.selectedSubject = subject
            cell.delegate = self
            guard let subjectsToDisplay = getSubjectsForCategory() else { return cell }
            cell.datasource = subjectsToDisplay

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHourlyRateTableViewCell", for: indexPath) as! EditProfileHourlyRateTableViewCell

            cell.header.attributedText = NSMutableAttributedString()
                .regular("\n", 12, .white)
                .bold("Choose hourly rate:", 18, .white)
                .regular("\n", 5, .white)
                .regular("\nHourly Rate  ", 15, Colors.grayText)
                .regular("  [$5-$1000]\n", 15, Colors.grayText)
                .regular("\n", 8, .white)
                .regular("Please select a rate for this listing.\n\nThis rate will be displayed on your listing.", 14, Colors.grayText)

            cell.textFieldObserver = self
            cell.textField.text = (price != nil) ? "$\(price!)" : "$5"
            cell.currentPrice = (price != nil) ? price! : 5
            cell.amount = (price != nil) ? "\(price!)" : "5"
            cell.header.sizeToFit()
            return cell
        default:
            return UITableViewCell()
        }
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        view.endEditing(true)
    }
}

extension EditListingVC: ListingSubject {
    func listingSubjectPicked(subject: String?) {
        self.subject = subject
    }
}

extension EditListingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AACircleCropViewControllerDelegate {
    func circleCropDidCropImage(_ image: UIImage) {
        self.image = image
        contentView.tableView.reloadData()
    }

    func circleCropDidCancel() {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            let circleCropController = AACircleCropViewController()
            circleCropController.delegate = self
            circleCropController.image = image
            circleCropController.isListing = true
            circleCropController.selectTitle = NSLocalizedString("Done", comment: "select")

            listingPicker.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.present(circleCropController, animated: true, completion: nil)
            }
        }
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

protocol ListingSubject {
    func listingSubjectPicked(subject: String?)
}

class EditListingsSubjectsTableViewCell: SubjectsTableViewCell {
    var selectedIndexPath: IndexPath?
    var selectedSubject: String?
    var delegate: ListingSubject?
}

extension EditListingsSubjectsTableViewCell {
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datasource.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectSelectionCollectionViewCell", for: indexPath) as! SubjectSelectionCollectionViewCell

        cell.label.text = datasource[indexPath.row]
        cell.layer.borderColor = UIColor.clear.cgColor
        if let subject = selectedSubject {
            if cell.label.text == subject {
                cell.layer.borderColor = UIColor.white.cgColor
                selectedIndexPath = indexPath
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SubjectSelectionCollectionViewCell else { return }

        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
            cell.layer.borderColor = UIColor.clear.cgColor
            delegate?.listingSubjectPicked(subject: nil)
            selectedSubject = cell.label.text
        } else if selectedIndexPath == nil {
            selectedIndexPath = indexPath
            cell.layer.borderColor = UIColor.white.cgColor
            delegate?.listingSubjectPicked(subject: cell.label.text)
            selectedSubject = cell.label.text
        } else {
            collectionView.cellForItem(at: selectedIndexPath!)?.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderColor = UIColor.white.cgColor
            selectedIndexPath = indexPath
            delegate?.listingSubjectPicked(subject: cell.label.text)
            selectedSubject = cell.label.text
        }
    }
}

class EditListingPhotoView: BaseView {
    let container = UIView()

    let listingImage: UIImageView = {
        let view = UIImageView()

        view.image = #imageLiteral(resourceName: "registration-image-placeholder")
        view.layer.cornerRadius = 15

        return view
    }()

    let addButton: UIButton = {
        let button = UIButton()

        button.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        button.backgroundColor = Colors.green
        button.layer.cornerRadius = 17.5

        return button
    }()

    let listingLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(18)
        label.text = "Listing Picture"
        label.textColor = .white

        return label
    }()

    let labelContainer = UIView()

    override func configureView() {
        addSubview(container)
        container.addSubview(listingImage)
        addSubview(addButton)
        addSubview(labelContainer)
        labelContainer.addSubview(listingLabel)
        super.configureView()

        applyConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.applyGradient(firstColor: UIColor(hex: "456AA8").cgColor, secondColor: UIColor(hex: "5785D4").cgColor, angle: 0, frame: container.bounds)
        labelContainer.applyGradient(firstColor: UIColor(hex: "456AA8").cgColor, secondColor: UIColor(hex: "5785D4").cgColor, angle: 90, frame: labelContainer.bounds)
        listingImage.roundCorners([.topRight, .topLeft], radius: 6)
    }

    override func applyConstraints() {
        container.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(225)
        }

        listingImage.snp.makeConstraints { make in
            make.height.width.equalTo(150)
            make.center.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.right.bottom.equalTo(listingImage).inset(-15)
            make.height.width.equalTo(35)
        }

        labelContainer.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom).inset(-1)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(45)
        }

        listingLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class EditListingPhotoTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    let container = UIView()

    let listingImage: UIImageView = {
        let view = UIImageView()

        view.image = UIImage(named: "placeholder-square")
        view.layer.cornerRadius = 15

        return view
    }()

    let addButton: UIButton = {
        let button = UIButton()

        button.setImage(#imageLiteral(resourceName: "pencil"), for: .normal)
        button.backgroundColor = Colors.green
        button.layer.cornerRadius = 17.5

        return button
    }()

    let listingLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(18)
        label.text = "Your listing picture"
        label.textColor = .white

        return label
    }()

    let labelContainer = UIView()

    func configureView() {
        addSubview(container)
        container.addSubview(listingImage)
        addSubview(addButton)
        addSubview(labelContainer)
        labelContainer.addSubview(listingLabel)

        selectionStyle = .none
        backgroundColor = Colors.backgroundDark

        applyConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.backgroundColor = UIColor(hex: "484782")

        labelContainer.applyGradient(firstColor: UIColor(hex: "6562C9").cgColor, secondColor: UIColor(hex: "6562C9").cgColor, angle: 90, frame: labelContainer.bounds)

        listingImage.roundCorners(.allCorners, radius: 10)
    }

    func applyConstraints() {
        container.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(225)
        }

        listingImage.snp.makeConstraints { make in
            make.height.width.equalTo(175)
            make.center.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.right.bottom.equalTo(listingImage).inset(-12)
            make.height.width.equalTo(34)
        }

        labelContainer.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom).inset(-1)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(45)
        }

        listingLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
