//
//  IntExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit

extension Int {
    
    func priceFormat() -> String {
        return "$\(self)/hr"
    }
    
    func preferenceNormalization() -> String {
        if self == 0 {
            return "Will tutor Online \n"
        } else if self == 1 {
            return "Will tutor In-Person\n"
        } else if self == 2 {
            return "Will tutor Online or In-Person\n"
        } else {
            return " Currently unavailable\n"
        }
    }
    
    func distancePreference(_ preference: Int) -> String {
        if preference == 2 || preference == 1 {
            return "Will travel up to \(self) miles\n"
        } else {
            return "Is unable to travel.\n"
        }
    }
    func formatPrice() -> String {
        return "$\(self) / hour"
    }
    func formatReviewLabel(rating: Double) -> String {
		return "\(rating) ★ Rating"
//        if self == 1 {
//            return "\(rating)  ★  (\(self) rating)"
//        }
//        return "\(rating)  ★  (\(self) ratings)"
    }
    func formatDistance() -> NSMutableAttributedString {
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .bold("\(self)", 17, Colors.lightBlue)
            .regular("\n", 0, .clear)
            .bold("miles", 12, Colors.lightBlue)
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = -2
        
        formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        return formattedString
    }
    func yearlyEarningsFormat() -> String {
        let number = (Double(self) / 100) as NSNumber
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = NSLocale.current
        numberFormatter.maximumFractionDigits = 0
        
        guard let currency = numberFormatter.string(from: number) else { return "N/A" }
        
        return currency 
    }
    
    func earningsDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return dateFormatter.string(from: date)
    }
    func reportStatusUpdate(type: String) -> Int {
        
        switch type {
            
        case "learner":
            if self == 0  || self == 1{
                return 1
            }
            if self == 2  || self == 3 {
                return 3
            }
        case "tutor":
            if self == 1  || self == 2 {
                return 2
            }
            if self == 2  || self == 3 {
                return 3
            }
        default:
            break
        }
        return 0
    }

    func currencyFormat() -> String {
        
        let number = (Double(self) / 100) as NSNumber
        let numberformat = NumberFormatter()
        numberformat.numberStyle = .currency
        
        guard let currency = numberformat.string(from: number) else { return "$0.00"}
        
        return currency
    }
    
    func timeIntervalToReviewDateFormat() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
extension Double {
    func formatDistance() -> NSMutableAttributedString {
        
        let formattedString = NSMutableAttributedString()
        
        if self >= 500 {
            formattedString
                .bold("500+", 17, Colors.lightBlue)
                .regular("\n", 0, .clear)
                .bold("miles", 12, Colors.lightBlue)
        }else {
            formattedString
                .bold("\(self)", 17, Colors.lightBlue)
                .regular("\n", 0, .clear)
                .bold("miles", 12, Colors.lightBlue)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = -2
        
        formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        return formattedString
    }
    
}
