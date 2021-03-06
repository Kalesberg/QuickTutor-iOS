//
//  Extensions.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import CoreLocation
import StoreKit
import SKPhotoBrowser


protocol UpdatedTutorCallBack: class {
    func tutorWasUpdated(tutor: AWTutor!)
}

protocol ApplyLearnerFilters {
    var filters: (Int, Int, Bool)! { get set }
    var location: CLLocation? { get set }
    func postFilterTutors()
}

enum Vibration {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case selection
    
    func vibrate() {
        
        switch self {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
        
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension String {
    func estimatedFrame() -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: Fonts.createSize(16)], context: nil)
    }

    func estimateFrameForFontSize(_ fontSize: CGFloat, extendedWidth: Bool = false, width: CGFloat = 1000) -> CGRect {
        let size = CGSize(width: extendedWidth ? width : 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: self).boundingRect(with: size, options: options, attributes: [.font: Fonts.createSize(fontSize)], context: nil)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension UIView {
    func applyDefaultShadow() {
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
    }
    
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

extension Date {
    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true

        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(self) {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday - 1]
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }

        return dateFormatter.string(from: self)
    }
    
    func formatRelativeStringForTimeSeparator() -> NSAttributedString {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true
        let boldAttributes = [NSAttributedString.Key.font: Fonts.createBoldSize(10), NSAttributedString.Key.foregroundColor: Colors.grayText]
        let normalAttributes = [NSAttributedString.Key.font: Fonts.createSize(10), NSAttributedString.Key.foregroundColor: Colors.grayText]
        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            
            let date = NSMutableAttributedString(string: "Today", attributes: boldAttributes)
            let time = NSAttributedString(string: " \(dateFormatter.string(from: self))", attributes: normalAttributes)
            date.append(time)
            return date
        } else if calendar.isDateInYesterday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            let date = NSMutableAttributedString(string: "Yesterday", attributes: boldAttributes)
            let time = NSAttributedString(string: " \(dateFormatter.string(from: self))", attributes: normalAttributes)
            date.append(time)
            return date
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            let date = NSMutableAttributedString(string: "\(dateFormatter.weekdaySymbols[weekday - 1])", attributes: boldAttributes)
            let time = NSAttributedString(string: " \(dateFormatter.string(from: self))", attributes: normalAttributes)
            date.append(time)
            return date
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
            let dateString = dateFormatter.string(from: self)
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            let date = NSMutableAttributedString(string: "\(dateString)", attributes: boldAttributes)
            let time = NSAttributedString(string: " \(dateFormatter.string(from: self))", attributes: normalAttributes)
            date.append(time)
            return date
        }
        
    }
}

extension UIView {
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func keyboardWillChange(_ notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let beginningFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endFrame.origin.y - beginningFrame.origin.y

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}

extension UIView {
    func getBottomAnchor() -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }

    func getTopAnchor() -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }
}

class QTDimmingLongPressGestureRecognizer: UILongPressGestureRecognizer {
    var gestureState: ((UIGestureRecognizer.State) -> ())?
}

extension UIView {
    @objc func handleDidLongPress(_ gesture: QTDimmingLongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            didTouchDown()
        case .changed:
            break
        default:
            didTouchUp()
        }
        
        if let gestureState = gesture.gestureState {
            gestureState(gesture.state)
        }
    }
    
    func setupTargets(gestureState: ((UIGestureRecognizer.State) -> ())?) {
        let dimmingGesture = QTDimmingLongPressGestureRecognizer(target: self, action: #selector(handleDidLongPress(_:)))
        dimmingGesture.gestureState = gestureState
        dimmingGesture.minimumPressDuration = 0
        addGestureRecognizer(dimmingGesture)
        isUserInteractionEnabled = true
    }
    
    func didTouchDown() {
        if let label = self as? UILabel {
            label.textColor = label.textColor.darker(by: 15)
            return
        }
        
        backgroundColor = backgroundColor?.darker(by: 15)
        guard let borderColor = layer.borderColor?.uiColor() else { return }
        layer.borderColor = borderColor.darker(by: 15)?.cgColor
        
        for subView in subviews {
            if subView is UILabel {
                let label = subView as! UILabel
                label.textColor = label.textColor.darker(by: 15)
            } else if subView is UIButton {
                let button = subView as! UIButton
                button.handleTouchDownTitleDimming()
            } else if subView is UIImageView {
                let imageView = subView as! UIImageView
                if let tintColor = imageView.tintColor,
                    let newTintColor = tintColor.darker(by: 15) {
                    imageView.overlayTintColor(color: newTintColor)
                }
            }
        }
        
    }
    
    func didTouchUp() {
        if let label = self as? UILabel {
            label.textColor = label.textColor.lighter(by: 15)
            return
        }
        
        backgroundColor = backgroundColor?.lighter(by: 15)
        guard let borderColor = layer.borderColor?.uiColor() else { return }
        layer.borderColor = borderColor.lighter(by: 15)?.cgColor
        
        for subView in subviews {
            if subView is UILabel {
                let label = subView as! UILabel
                label.textColor = label.textColor.lighter(by: 15)
            } else if subView is UIButton {
                let button = subView as! UIButton
                button.handleTouchUpTitleDimming()
            } else if subView is UIImageView {
                let imageView = subView as! UIImageView
                if let tintColor = imageView.tintColor,
                    let newTintColor = tintColor.lighter(by: 15) {
                    imageView.overlayTintColor(color: newTintColor)
                }
            }
        }
    }
}

extension UILabel {
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}

class DateService {
    static let shared = DateService()
    private init() {}

    func localToUTC(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current

        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "H:mm:ss"

        return dateFormatter.string(from: dt!)
    }

    func UTCToLocal(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm a"

        return dateFormatter.string(from: dt!)
    }
}

extension UIViewController {
    func showCommunityGuidelines() {
        let next = WebViewVC()
        next.navigationItem.title = "Community Guidelines"
        next.url = "https://www.quicktutor.com/community/community-guidelines"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    func showUserSafety() {
        let next = WebViewVC()
        next.navigationItem.title = "User Safety"
        next.url = "https://www.quicktutor.com/community/user-safety"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    func showTermsOfUse() {
        let next = WebViewVC()
        next.navigationItem.title = "Terms of Service"
        next.url = "https://www.quicktutor.com/legal/terms-of-service"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    func showForgotPasswordScreen() {
        navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
    }
}

extension UIViewController {
    func showReviewController (_ userDefaultKey: String) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            guard let appstoreUrl = URL(string: QTConstants.APP_STORE_URL) else { return }
            
            var components = URLComponents(url: appstoreUrl, resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "action", value: "write-review")
            ]
            guard let writeReviewURL = components?.url else { return }
            
            UIApplication.shared.open(writeReviewURL)
        }
        
        UserDefaults.standard.set(true, forKey: userDefaultKey)
        UserDefaults.standard.synchronize()
    }
}

extension NSMutableAttributedString {
    @discardableResult func regular(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Lato-Regular", size: size)!, .foregroundColor: color]
        let string = NSMutableAttributedString(string: text, attributes: attrs)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, string.length))
        
        append(string)
        
        return self
    }
    
    @discardableResult func bold(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Lato-Bold", size: size)!, .foregroundColor: color]
        let string = NSMutableAttributedString(string: text, attributes: attrs)
        append(string)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, string.length))
        
        return self
    }
    
    @discardableResult func underline(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat=0, id: String="") -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key : Any] = [.font: UIFont(name: "Lato-Regular", size: size)!, .foregroundColor: color, .underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key(rawValue: "id") : id]
        let string = NSMutableAttributedString(string: text, attributes: attrs)
        append(string)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, string.length))
        
        return self
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
            
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}
