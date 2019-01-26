//
//  QTTutorDashboardMarkerView.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Charts

class QTTutorDashboardMarkerView: MarkerView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    
    var chartType: QTTutorDashboardChartType?
    var contentDidChanged: ((QTTutorDashboardChartData?) -> Void)?
    func setChartType(type: QTTutorDashboardChartType) {
        chartType = type
    }
    
    static func load() -> QTTutorDashboardMarkerView {
        return Bundle.main.loadNibNamed(String(describing: QTTutorDashboardMarkerView.self),
                                        owner: nil,
                                        options: [:])?.first as! QTTutorDashboardMarkerView
    }
    
    public override func awakeFromNib() {
        self.offset.x = -self.frame.size.width / 2.0
        self.offset.y = -self.frame.size.height / 2.0
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        guard let chartType = chartType else { return }
        switch chartType {
        case .earnings:
            valueLabel.text = entry.y.currencyFormat()
        case .sessions, .hours:
            valueLabel.text = String(format: "%d", Int(round(entry.y)))
        }
        
        if let text = valueLabel.text {
            self.frame.size.width = text.getStringWidth(font: valueLabel.font) + 10
            self.offset.x = -self.frame.size.width / 2.0
            
            if let contentDidChanged = self.contentDidChanged {
                contentDidChanged(entry.data as? QTTutorDashboardChartData)
            }
        }
        
        
        layoutIfNeeded()
    }
}
