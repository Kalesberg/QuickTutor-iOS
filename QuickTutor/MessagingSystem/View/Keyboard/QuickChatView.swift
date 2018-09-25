//
//  QuickChatView.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/24/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class QuickChatView: UIView {
    let reccommendedMessages = ["Hello, I would like to connect with you.", "Hey! Let’s connect!", "Hey, I need your help"]

    var delegate: QuickChatViewDelegate?

    let chatCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(QuickChatCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()

    func setupViews() {
        setupMainView()
        setupChatCollection()
    }

    private func setupMainView() {
        backgroundColor = .clear
    }

    private func setupChatCollection() {
        chatCollection.delegate = self
        chatCollection.dataSource = self
        addSubview(chatCollection)
        chatCollection.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        frame = CGRect(x: 0, y: 0, width: 375, height: 50)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuickChatView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return reccommendedMessages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickChatCell
        cell.textLabel.text = reccommendedMessages[indexPath.item]
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: reccommendedMessages[indexPath.item].estimatedFrame().width + 20, height: 50)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let messageText = reccommendedMessages[indexPath.item]
        delegate?.sendMessage(text: messageText)
    }
}
