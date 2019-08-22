//
//  QTEditProfileExperienceTableViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/18.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import RangeSeekSlider

class QTEditProfileExperienceTableViewCell: UITableViewCell {

    @IBOutlet weak var periodSlider: RangeSeekSlider!
    
    static var reuseIdentifier: String {
        return String(describing: QTEditProfileExperienceTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        periodSlider.disableRange = true
        periodSlider.minValue = 0.5
        periodSlider.maxValue = 20
        periodSlider.lineHeight = 8
        periodSlider.tintColor = Colors.gray
        periodSlider.colorBetweenHandles = Colors.purple
        periodSlider.handleColor = Colors.purple
        periodSlider.handleDiameter = 20
        periodSlider.maxLabelColor = UIColor.white.withAlphaComponent(0.5)
        periodSlider.maxLabelFont = Fonts.createBoldSize(12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setExperiencePeriod (_ period: Float) {
        periodSlider.selectedMaxValue = CGFloat(period)
    }
}
