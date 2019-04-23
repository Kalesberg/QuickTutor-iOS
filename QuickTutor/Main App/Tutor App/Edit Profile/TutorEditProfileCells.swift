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
