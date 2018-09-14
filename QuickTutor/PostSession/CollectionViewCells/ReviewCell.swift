//
//  ReviewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class ReviewCell : BasePostSessionCell {
	
	let textView : UITextView = {
		let textView = UITextView()
		
		textView.font = Fonts.createSize(13)
		textView.keyboardAppearance = .dark
		textView.textColor = UIColor.gray
		textView.tintColor = .white
		textView.backgroundColor = .clear
		textView.returnKeyType = .done
		textView.text = "Tell us about your experience..."
		
		return textView
	}()
	
	let characterCount : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .right
		label.font = Fonts.createSize(14)
		label.text = "500/500"
		
		return label
	}()
	
	let errorLabel : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .left
		label.textColor = Colors.qtRed
		label.font = Fonts.createSize(13)
		label.isHidden = true
		
		return label
	}()
	
	let textViewContainer : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.navBarColor
		
		return view
	}()
	
	var delegate : PostSessionInformationDelegate?
	
	override func configureCollectionViewCell() {
		addSubview(textViewContainer)
		textViewContainer.addSubview(textView)
		textViewContainer.addSubview(errorLabel)
		headerView.addSubview(characterCount)
		super.configureCollectionViewCell()
		
		textView.delegate = self
	}
	override func applyConstraints() {
		super.applyConstraints()
		characterCount.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(10)
			make.height.centerY.equalToSuperview()
		}
		textViewContainer.snp.makeConstraints { (make) in
			make.top.equalTo(backgroundHeaderView.snp.bottom).inset(-1)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(150)
		}
		textView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview().inset(5)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		textViewContainer.roundCorners([.bottomLeft, .bottomRight], radius: 4)
	}
	private func adjustTextViewToFitKeyboard() {
		self.backgroundHeaderView.snp.remakeConstraints({ (make) in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
			make.height.equalTo(50)
		})
		self.titleView.snp.remakeConstraints { (make) in
			make.top.width.height.equalTo(0)
		}
		UIView.animate(withDuration: 0.2) {
			self.layoutSubviews()
		}
	}
	private func resetTextViewWhenKeyboardResigns() {
		self.titleView.snp.remakeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalTo(120)
		}
		
		self.backgroundHeaderView.snp.remakeConstraints { (make) in
			make.top.equalTo(titleView.snp.bottom).inset(-30)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(50)
		}

		UIView.animate(withDuration: 0.2) {
			self.layoutSubviews()
		}
	}
}
extension ReviewCell : UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if (textView.text == "Tell us about your experience...") {
			textView.text = ""
			textView.textColor = .white
		}
		delegate?.reviewTextViewDidBecomeFirstResponsder()
		adjustTextViewToFitKeyboard()
	}
	func textViewDidChange(_ textView: UITextView) {
		let maxCharacters = 500
		
		let characters = textView.text.count
		let charactersFromMax = maxCharacters - characters
		
		if characters <= maxCharacters {
			characterCount.textColor = .white
			characterCount.text = String(charactersFromMax) + "/500"
		} else {
			characterCount.textColor = UIColor.red
			characterCount.text = String(charactersFromMax) + "/500"
		}
	}
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text == "" {
			textView.text = "Tell us about your experience..."
			textView.textColor = UIColor.gray
		}
		let review = (textView.text == "Tell us about your experience...") ? nil : textView.text
		delegate?.didWriteReview(review: review)
		delegate?.reviewTextViewDidResign()
		resetTextViewWhenKeyboardResigns()
	}
}
