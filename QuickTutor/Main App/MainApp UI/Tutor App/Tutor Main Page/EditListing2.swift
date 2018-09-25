//
//  EditListing2.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class EditListing2View: MainLayoutTitleBackTwoButton {
    var saveButton = NavbarButtonSave()

    override var rightButton: NavbarButton {
        get {
            return saveButton
        } set {
            saveButton = newValue as! NavbarButtonSave
        }
    }

    let scrollView = UIScrollView()
    let editListingPhotoView = EditListing2PhotoView()

    let collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0

        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false

        return collectionView
    }()

    override func configureView() {
        addSubview(scrollView)
        scrollView.addSubview(editListingPhotoView)
        scrollView.addSubview(collectionView)
        super.configureView()

        title.label.text = "Edit Listing"
    }

    override func applyConstraints() {
        super.applyConstraints()

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom)
            make.width.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(layoutMargins.bottom)
            }
        }
        editListingPhotoView.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
            make.height.equalTo(250)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(editListingPhotoView.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(100)
        }
    }
}

class EditListing2PhotoView: BaseView {
    let container = UIView()

    let listingImage: UIImageView = {
        let view = UIImageView()

        view.image = #imageLiteral(resourceName: "registration-image-placeholder")
        view.backgroundColor = .white
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
        label.text = "Your listing picture"
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

        backgroundColor = .clear
        applyConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

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
