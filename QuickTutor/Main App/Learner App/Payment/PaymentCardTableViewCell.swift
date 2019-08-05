//
//  PaymentCardTableViewCell.swift
//  QuickTutor
//
//  Created by Will Saults on 5/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SwipeCellKit

enum CardChoice {
    case defaultCard
    case optionalCard
    
    var description : String {
        switch self {
        case .defaultCard: return "Default"
        case .optionalCard: return "Optional"
        }
    }
    
    var backgroundColor : UIColor {
        switch self {
        case .defaultCard: return Colors.purple
        case .optionalCard: return Colors.buttonGray
        }
    }
}

protocol PaymentCardTableViewCellDelegate {
    func didTapDefaultButton(_ cell: PaymentCardTableViewCell)
}

class PaymentCardTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var lastFourLabel: UILabel!
    @IBOutlet weak var defaultButton: UIButton!
    var row: NSInteger?
    var cardChoice: CardChoice?
    var cellDelegate: PaymentCardTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLastFour(text: String) {
        lastFourLabel?.text = "•••• \(text)"
    }
    
    func setCardButtonType(type: CardChoice) {
        cardChoice = type
        defaultButton?.backgroundColor = type.backgroundColor
        defaultButton?.setTitle(type.description, for: .normal)
        
        guard let containerView = defaultButton?.superview as? BorderedPaymentCardView else { return }
        containerView.borderColor = cardChoice == .defaultCard ? Colors.purple : Colors.gray
    }
    
    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        resetBackgroundColor(sender)
        if cardChoice == .optionalCard {
            cellDelegate?.didTapDefaultButton(self)
        }
    }
    
    @IBAction func touchDownOnButton(_ sender: UIButton) {
        sender.backgroundColor = sender.backgroundColor?.darker(by: 10.0)
    }
    
    @IBAction func touchCancelOnButton(_ sender: UIButton) {
        resetBackgroundColor(sender)
    }
    @IBAction func touchDragOutsideButton(_ sender: UIButton) {
        resetBackgroundColor(sender)
    }
    
    func resetBackgroundColor(_ button: UIButton) {
        if let type = cardChoice {
            button.backgroundColor = type.backgroundColor
        }
    }
}

@IBDesignable
class RoundedButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}

@IBDesignable
class BorderedPaymentCardView: UIView {
    @IBInspectable var borderColor: UIColor = Colors.qtRed {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
