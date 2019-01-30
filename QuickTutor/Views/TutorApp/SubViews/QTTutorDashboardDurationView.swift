//
//  QTTutorDashboardDurationView.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

enum QTTutorDashboardDurationType: String {
    case week = "1w"
    case month = "1m"
    case quarter = "1q"
    case year = "1y"
}

class QTTutorDashboardDurationView: UIView {

    @IBOutlet weak var contentView: UIView!
    var segmentView: PinterestSegment! = nil
    var durationType: QTTutorDashboardDurationType?
    
    public var durationDidSelect: ((QTTutorDashboardDurationType) -> Void)?
    
    static func load() -> QTTutorDashboardDurationView {
        return Bundle.main.loadNibNamed(String(describing: QTTutorDashboardDurationView.self),
                                        owner: nil,
                                        options: [:])?.first as! QTTutorDashboardDurationView
    }
    
    func setData(durationType: QTTutorDashboardDurationType) {
        
        self.durationType = durationType
        
        var style = PinterestSegmentStyle()
        style.indicatorColor = UIColor.qtAccentColor
        style.titleMargin = 20.0
        style.titlePendingHorizontal = 15
        style.titlePendingVertical = 10
        style.titleFont = UIFont.qtSemiBoldFont(size: 12)
        style.normalTitleColor = UIColor.qtAccentColor
        style.selectedTitleColor = UIColor.white
        
        let width: CGFloat = UIScreen.main.bounds.size.width
        segmentView = PinterestSegment(frame: CGRect(x: 0, y: 0, width: width, height: 24),
                                       segmentStyle: style,
                                       titles: [QTTutorDashboardDurationType.week.rawValue,
                                                QTTutorDashboardDurationType.month.rawValue,
                                                QTTutorDashboardDurationType.quarter.rawValue,
                                                QTTutorDashboardDurationType.year.rawValue])
        segmentView.valueChange = { index in
            
            // To prevent recursive calls
            if index == self.segmentView.titles.firstIndex(of: durationType.rawValue) ?? 1 { return }
            
            if let durationDidSelect = self.durationDidSelect {
                durationDidSelect(QTTutorDashboardDurationType(rawValue: self.segmentView.titles[index]) ?? .month)
            }
        }
        contentView.addSubview(segmentView)
        segmentView.setSelectIndex(index: segmentView.titles.firstIndex(of: durationType.rawValue) ?? 1)
    }
}
