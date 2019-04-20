//
//  TutorEditProfileCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

protocol TutorPreferenceChange {
    func inPersonPressed()
    func inVideoPressed()
}

class EditProfileImageCell: UICollectionViewCell {
    
    let backgrounImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "addPhotoButtonBackground")
        return iv
    }()
    
    let foregroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    func setupViews() {
        setupMainView()
        setupBackgroundImageView()
        setupForegroundImageView()
    }
    
    func setupMainView() {
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
    func setupBackgroundImageView() {
        addSubview(backgrounImageView)
        backgrounImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupForegroundImageView() {
        addSubview(foregroundImageView)
        foregroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol EditProfileImagesCellDelegate: class {
    func editProfileImageCell( _ imagesCell: EditProfileImagesCell, didSelect index: Int)
}

class EditProfileImagesCell: UITableViewCell {
    
    var profilePicReferences = [URL?]()
    weak var delegate: EditProfileImagesCellDelegate?

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(EditProfileImageCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = Colors.darkBackground 
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.isScrollEnabled = false
        return cv
    }()
    
    func setupViews() {
        backgroundColor = Colors.darkBackground
        setupCollectionView()
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func loadImages() {
        let databaseRef = Database.database().reference().child("student-info").child(CurrentUser.shared.learner.uid!).child("img")
        databaseRef.observe(.childAdded) { (snapshot) in
            guard let urlString = snapshot.value as? String, let url = URL(string: urlString) else {
                self.profilePicReferences.append(nil)
                return
            }
            self.profilePicReferences.append(url)
            self.collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        loadImages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditProfileImagesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profilePicReferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! EditProfileImageCell
        guard let url = profilePicReferences[indexPath.item] else {
            return cell
        }
        cell.backgrounImageView.sd_setImage(with: url, placeholderImage: nil, options: []) { (image, error, cacheType, url) in
            if image == nil {
                cell.backgrounImageView.image = UIImage(named: "addPhotoButtonBackground")
            } else {
                cell.foregroundImageView.image = UIImage(named:"deletePhotoIcon")
                if indexPath.item  == 0 {
                    cell.foregroundImageView.image = UIImage(named: "uploadImageIcon")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.editProfileImageCell(self, didSelect: indexPath.item)
    }

}

class EditProfileItemTableViewCell: BaseTableViewCell {
    var infoLabel = LeftTextLabel()
    var textField = NoPasteTextField()
    var sideLabel = RightTextLabel()
    var divider = BaseView()
    var spacer = BaseView()

    override func configureView() {
        contentView.addSubview(infoLabel)
        contentView.addSubview(textField)
        textField.addSubview(sideLabel)
        contentView.addSubview(divider)
        contentView.addSubview(spacer)

        backgroundColor = .clear
        selectionStyle = .none

        textField.delegate = self

        divider.backgroundColor = Colors.divider
        infoLabel.label.font = Fonts.createBoldSize(14)
        textField.font = Fonts.createSize(16)
        textField.textColor = Colors.gray

        applyConstraints()
    }

    override func applyConstraints() {
        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }

        spacer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }

        divider.snp.makeConstraints { make in
            make.top.equalTo(spacer.snp.top)
            make.height.equalTo(1)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }

        textField.snp.makeConstraints { make in
            make.bottom.equalTo(divider.snp.top)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }

        sideLabel.snp.makeConstraints { make in
            make.right.equalTo(infoLabel)
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(15)
        }
    }
}

extension EditProfileItemTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789@#$%^&*()_=+<>?,.[]{};'~! ").inverted // Add any extra characters here..
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        if textField.text!.count <= 24 {
            if string == "" {
                return true
            }
            return !(string == filtered)
        } else {
            if string == "" {
                return true
            }
            return false
        }
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }
}

class EditProfileDotItemTableViewCell: EditProfileItemTableViewCell {
    override func configureView() {
        super.configureView()

        sideLabel.label.font = Fonts.createSize(16)
        textField.textColor = Colors.grayText
        sideLabel.label.text = "•"
    }
}

class EditProfileArrowItemTableViewCell: EditProfileItemTableViewCell {
    override func setSelected(_ selected: Bool, animated _: Bool) {
        if selected {
            // navigation
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated _: Bool) {
        if highlighted {
            UIView.animate(withDuration: 0.2) {
                self.divider.backgroundColor = .white
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.divider.backgroundColor = Colors.divider
            }
        }
    }

    override func configureView() {
        super.configureView()

        textField.isUserInteractionEnabled = false
        sideLabel.label.font = Fonts.createBoldSize(25)
        sideLabel.label.text = "›"
    }
}

class EditProfilePolicyTableViewCell: EditProfileDotItemTableViewCell {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(13)
        label.textColor = Colors.grayText
        label.sizeToFit()
        label.numberOfLines = 0

        return label
    }()

    override func configureView() {
        contentView.addSubview(label)
        super.configureView()
    }

    override func applyConstraints() {
        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).inset(4)
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).inset(-6)
            make.height.equalTo(30)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }

        sideLabel.snp.makeConstraints { make in
            make.right.equalTo(infoLabel)
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(15)
        }

        divider.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).inset(-5)
            make.height.equalTo(1)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}

class EditProfileHeaderTableViewCell: BaseTableViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.sizeToFit()
        return label
    }()

    override func configureView() {
        contentView.addSubview(label)
        selectionStyle = .none
        backgroundColor = .clear
        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class EditProfilePreferencesTableViewCell: BaseTableViewCell {
    let header: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = Fonts.createBoldSize(15)
        label.sizeToFit()
        label.text = "Preferences"

        return label
    }()

    let inSessionLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.sizeToFit()
        label.text = "Tutoring In-Person Sessions"

        return label
    }()

    override func configureView() {
        contentView.addSubview(header)
        contentView.addSubview(inSessionLabel)

        backgroundColor = .black

        applyConstraints()
    }

    override func applyConstraints() {
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.height.equalTo(20)
        }

        inSessionLabel.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.equalTo(header)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
}

class BaseSlider: UISlider {
    override func trackRect(forBounds _: CGRect) -> CGRect {
        var width: Int

        if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
            width = 230
        } else {
            width = 280
        }

        let rect: CGRect = CGRect(x: 0, y: 0, width: width, height: 20)

        return rect
    }

    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        var bounds: CGRect = self.bounds
        bounds = bounds.insetBy(dx: -20, dy: -20)
        return bounds.contains(point)
    }
}

class EditProfileSliderTableViewCell: BaseTableViewCell {
    let header: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0

        return label
    }()

    let slider: BaseSlider = {
        let slider = BaseSlider()

        slider.maximumTrackTintColor = Colors.registrationDark
        slider.minimumTrackTintColor = Colors.purple
        slider.isContinuous = true

        return slider
    }()

    let valueLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.textAlignment = .center

        return label
    }()

    override func configureView() {
        contentView.addSubview(header)
        contentView.addSubview(slider)
        contentView.addSubview(valueLabel)

        backgroundColor = .clear
        selectionStyle = .none

        applyConstraints()
    }

    override func applyConstraints() {
        var width: Int

        if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
            width = 230
        } else {
            width = 290
        }

        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(3)
        }

        valueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(slider).inset(-14)
            make.left.equalTo(slider.snp.right)
            make.right.equalToSuperview()
        }

        slider.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(4)
            make.top.equalTo(header.snp.bottom).inset(-25)
            make.width.equalTo(width)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
    }
}

protocol AmountTextFieldDidChange {
    func amountTextFieldDidChange(amount: Int)
}


class EditProfileHourlyRateTableViewCell: BaseTableViewCell {
    let header: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.registrationDark
        view.layer.cornerRadius = 6

        return view
    }()

    var textField: NoPasteTextField = {
        let textField = NoPasteTextField()

        textField.font = Fonts.createBoldSize(32)
        textField.textColor = .white
        textField.textAlignment = .left
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = .dark
        textField.tintColor = Colors.purple

        return textField
    }()

    let decreaseButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "decreaseButton"), for: .normal)
        return button
    }()

    let increaseButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "increaseButton"), for: .normal)
        return button
    }()

    let container = UIView()
    var increasePriceTimer: Timer?
    var decreasePriceTimer: Timer?

    var currentPrice = 5
    var amount: String = "5"
    var textFieldObserver: AmountTextFieldDidChange?

    override func configureView() {
        addSubview(header)
        addSubview(container)
        container.addSubview(textFieldContainer)
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(increaseButton)
        textFieldContainer.addSubview(decreaseButton)

        backgroundColor = Colors.backgroundDark
        selectionStyle = .none
        textField.delegate = self

        decreaseButton.addTarget(self, action: #selector(decreasePrice), for: .touchDown)
        decreaseButton.addTarget(self, action: #selector(endDecreasePrice), for: [.touchUpInside, .touchUpOutside])
        increaseButton.addTarget(self, action: #selector(increasePrice), for: .touchDown)
        increaseButton.addTarget(self, action: #selector(endIncreasePrice), for: [.touchUpInside, .touchUpOutside])

        applyConstraints()
    }

    override func applyConstraints() {
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(10)
            make.bottom.equalTo(container.snp.top)
        }

        container.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.height.equalTo(100)
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        textFieldContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.95)
            make.height.equalTo(70)
        }

        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(25)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.centerY.height.equalToSuperview()
        }

        increaseButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(17)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        decreaseButton.snp.makeConstraints { make in
            make.right.equalTo(increaseButton.snp.left).inset(-17)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }

    private func updateTextField(_ amount: String) {
        guard let this = Int(amount), let number = this as NSNumber? else { return }
        currentPrice = this
        textField.text = "$\(number)"
        textFieldObserver?.amountTextFieldDidChange(amount: this)
    }

    @objc func decreasePrice() {
        guard currentPrice > 0 else {
            amount = ""
            return
        }
        decreasePriceTimer = Timer.scheduledTimer(withTimeInterval: 0.085, repeats: true) { _ in
            guard self.currentPrice > 0 else {
                self.amount = String(self.currentPrice)
                return
            }
            self.currentPrice -= 1
            self.textField.text = "$\(self.currentPrice)"
            self.amount = String(self.currentPrice)
            self.textFieldObserver?.amountTextFieldDidChange(amount: self.currentPrice)
        }
        decreasePriceTimer?.fire()
    }

    @objc func endDecreasePrice() {
        decreasePriceTimer?.invalidate()
    }

    @objc func increasePrice() {
        guard currentPrice < 1000 else {
            amount = String(currentPrice)
            return
        }
        currentPrice += 1
        textField.text = "$\(currentPrice)"
        amount = String(currentPrice)
        textFieldObserver?.amountTextFieldDidChange(amount: currentPrice)
        increasePriceTimer = Timer.scheduledTimer(withTimeInterval: 0.085, repeats: true, block: { _ in
            guard self.currentPrice < 1000 else {
                self.amount = String(self.currentPrice)
                return
            }
            self.currentPrice += 1
            self.textField.text = "$\(self.currentPrice)"
            self.amount = String(self.currentPrice)
            self.textFieldObserver?.amountTextFieldDidChange(amount: self.currentPrice)
        })
    }

    @objc func endIncreasePrice() {
        increasePriceTimer?.invalidate()
    }
}

extension EditProfileHourlyRateTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")

        if string == "" && amount.count == 1 {
            textField.text = "$5"
            amount = ""
            currentPrice = 0
            return false
        }
        if string == "" && amount.count > 0 {
            amount.removeLast()
            updateTextField(amount)
        }

        if string == numberFiltered {
            let temp = (amount + string)
            guard let number = Int(temp), number < 1001 else {
                // showError
                return false
            }
            amount = temp
            updateTextField(amount)
        }
        return false
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }
}

class EditProfileCheckboxTableViewCell: BaseTableViewCell {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(15)
        label.textColor = .white

        return label
    }()

    var checkbox = RegistrationCheckbox() {
        didSet {
            print("changed")
        }
    }

    override func configureView() {
        addSubview(label)
        contentView.addSubview(checkbox)
        super.configureView()

        selectionStyle = .none
        backgroundColor = .clear

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        checkbox.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
    }
}

class EditProfileVideoCheckboxTableViewCell: BaseTableViewCell {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(15)
        label.textColor = .white

        return label
    }()

    var delegate: TutorPreferenceChange?

    let checkbox = RegistrationCheckbox()

    override func configureView() {
        addSubview(label)
        contentView.addSubview(checkbox)
        super.configureView()

        selectionStyle = .none
        backgroundColor = .clear

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        checkbox.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
    }

    override func handleNavigation() {
        if touchStartView is RegistrationCheckbox {
            delegate?.inVideoPressed()
        }
    }
}

class EditProfilePersonCheckboxTableViewCell: BaseTableViewCell {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(15)
        label.textColor = .white

        return label
    }()

    var delegate: TutorPreferenceChange?

    let checkbox = RegistrationCheckbox()

    override func configureView() {
        addSubview(label)
        contentView.addSubview(checkbox)
        super.configureView()

        selectionStyle = .none
        backgroundColor = .clear

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        checkbox.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
    }

    override func handleNavigation() {
        if touchStartView is RegistrationCheckbox {
            delegate?.inPersonPressed()
        }
    }
}

//extension LearnerFiltersVC: UIScrollViewDelegate {
//    func scrollViewWillBeginDragging(_: UIScrollView) {
//        view.endEditing(true)
//    }
//}


class EditProfileCell: UITableViewCell {
    
    let textField: RegistrationTextField = {
        let field = RegistrationTextField()
        return field
    }()
    
    func setupViews() {
        backgroundColor = Colors.darkBackground
        setupTextField()
    }
    
    func setupTextField() {
        addSubview(textField)
        textField.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    override func prepareForReuse() {
        textField.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EditProfileBioCell: UITableViewCell {
    
    let placeholder: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let textView: MessageTextView = {
        let field = MessageTextView()
        field.layer.borderColor = Colors.gray.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 4
        field.placeholderLabel.text = "Enter a bio..."
        field.tintColor = .white
        field.font = Fonts.createSize(14)
        field.textColor = .white
        field.keyboardAppearance = .dark
        return field
    }()
    
    func setupViews() {
        backgroundColor = Colors.darkBackground
        setupPlaceholder()
        setupTextView()
    }
    
    func setupPlaceholder() {
        addSubview(placeholder)
        placeholder.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
    }
    
    func setupTextView() {
        addSubview(textView)
        textView.anchor(top: placeholder.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 96)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
