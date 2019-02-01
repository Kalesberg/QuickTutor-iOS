//
//  QTTutorDashboardTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Charts

extension Double {
    func currencyFormat() -> String {
        
        let number = (self / 100) as NSNumber
        let numberformat = NumberFormatter()
        numberformat.numberStyle = .currency
        
        guard let currency = numberformat.string(from: number) else { return "$0.00"}
        
        return currency
    }
}

enum QTTutorDashboardChartType: String {
    case earnings = "Earnings"
    case sessions = "Sessions"
    case hours = "Hours"
}

struct QTTutorDashboardChartData {
    var valueY: Double
    var date: TimeInterval
}

class QTTutorDashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var graphNameLabel: UILabel!
    @IBOutlet weak var leftArrowImageView: QTCustomImageView!
    @IBOutlet weak var leftValueLabel: UILabel!
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var rightArrowImageView: QTCustomImageView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rightInfoStackView: UIStackView!
    @IBOutlet weak var rightValueLabel: UILabel!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var chartType: QTTutorDashboardChartType!
    var durationType: QTTutorDashboardDurationType!
    var chartData: [QTTutorDashboardChartData]?
    var longPressGesture: UILongPressGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    var lastPoint: CGPoint?
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDashboardTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTTutorDashboardTableViewCell.self), bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Initialize chart view.
        lineChartView.delegate = self
        lineChartView.chartDescription?.enabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.highlightPerTapEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.legend.form = .none
        lineChartView.dragXEnabled = false
        lineChartView.dragYEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.noDataFont = UIFont.qtRegularFont(size: 12)
        lineChartView.noDataTextColor = UIColor.qtAccentColor
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(onLineChartViewTapGestureRecognized(_:)))
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLineChartViewTapGestureRecognized(_:)))
        longPressGesture?.minimumPressDuration = 0
        if let gesture = longPressGesture, let panGesture = panGesture {
            panGesture.require(toFail: gesture)
            panGesture.delegate = self
            gesture.delegate = self
            lineChartView.addGestureRecognizer(gesture)
            lineChartView.addGestureRecognizer(panGesture)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc
    func onLineChartViewTapGestureRecognized(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            let h = lineChartView.getHighlightByTouchPoint(gesture.location(in: lineChartView))
            lineChartView.highlightValue(h)
            print("long press gesture started")
        } else {
            lineChartView.highlightValue(nil)
            setData(chartType: chartType, durationType: durationType, chartData: chartData)
            print("long press gesture ended")
        }
    }
    
    @objc
    func onLineChartViewPanGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        
    }
    
    
    func setData(chartType: QTTutorDashboardChartType,
                 durationType: QTTutorDashboardDurationType,
                 chartData: [QTTutorDashboardChartData]?) {
        
        self.chartType = chartType
        self.durationType = durationType
        self.chartData = chartData
        
        lineChartView.clear()
        
        // Initialize chart basic info
        switch chartType {
        case .sessions:
            leftArrowImageView.isHidden = false
        case .earnings:
            leftArrowImageView.isHidden = true
        case .hours:
            leftArrowImageView.isHidden = false
        }
        rightArrowImageView.isHidden = true
        rateLabel.isHidden = true
        rightInfoStackView.isHidden = true
        graphNameLabel.text = chartType.rawValue
        
        let formatter: DateFormatter = DateFormatter()
        switch durationType {
        case .week, .month:
            formatter.dateFormat = "MMM dd"
        case .quarter, .year:
            formatter.dateFormat = "MMM YYYY"
        }
        self.leftTitleLabel.text = formatter.string(from: Date(timeIntervalSince1970: chartData?.first?.date ?? Date().timeIntervalSince1970))
            + " → "
            + formatter.string(from: Date(timeIntervalSince1970: chartData?.last?.date ?? Date().timeIntervalSince1970))
        var total: Double = 0
        chartData?.forEach({ (data) in
            total += data.valueY
        })
        leftValueLabel.text = chartType == .earnings ? total.currencyFormat() : "\(total)"
        
        if total > 0 {
            let marker = QTTutorDashboardMarkerView.load() as QTTutorDashboardMarkerView
            marker.setChartType(type: chartType)
            marker.chartView = lineChartView
            marker.contentDidChanged = { data in
                DispatchQueue.main.async {
                    self.leftValueLabel.text = chartType == .earnings ? "\((data?.valueY ?? 0).currencyFormat())" : "\(data?.valueY ?? 0)"
                    
                    let formatter: DateFormatter = DateFormatter()
                    switch durationType {
                    case .week, .month:
                        formatter.dateFormat = "MMM dd"
                    case .quarter, .year:
                        formatter.dateFormat = "MMM YYYY"
                    }
                    self.leftTitleLabel.text = formatter.string(from: Date(timeIntervalSince1970: data?.date ?? 0))
                }
            }
            lineChartView.marker = marker
            
            
            var index = -1
            let values = chartData?.map({ (data) -> ChartDataEntry in
                index += 1
                return ChartDataEntry(x: Double(index), y: data.valueY, data: data as AnyObject)
            })
            
            let set = LineChartDataSet(values: values, label: nil)
            set.drawIconsEnabled = false
            set.lineDashLengths = [1, 0]
            set.setColor(UIColor.qtAccentColor)
            set.lineWidth = 2.5
            set.circleRadius = 0
            set.drawCircleHoleEnabled = false
            set.valueFont = .systemFont(ofSize: 0)
            set.valueTextColor = .white
            set.setDrawHighlightIndicators(false)
            
            let gradientColors = [UIColor.qtAccentColor.cgColor,
                                  UIColor.qtAccentColor.withAlphaComponent(0.5).cgColor,
                                  UIColor.clear.cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: [1, 0.5, 0])!
            
            set.fillAlpha = 1
            set.fill = Fill(linearGradient: gradient, angle: 90)
            set.drawFilledEnabled = true
            set.drawCirclesEnabled = false
            set.mode = .horizontalBezier
            let data = LineChartData(dataSet: set)
            lineChartView.data = data
        } else {
            lineChartView.data = nil
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = panGesture, gestureRecognizer == panGesture {
            let velocity = panGesture.velocity(in: lineChartView)
            lastPoint = panGesture.location(in: lineChartView)
            if lineChartView.data === nil || abs(velocity.y) > abs(velocity.x) {
                return false
            }
        } else if let longPressGesture = longPressGesture, gestureRecognizer == longPressGesture {
            
            let point = longPressGesture.location(in: lineChartView)
            if lastPoint == nil {
                lastPoint = point
                return true
            }
            
            // Disable recognizer while vertical scroll
            if let lastPoint = lastPoint, abs(lastPoint.y - point.y) > abs(lastPoint.x - point.x) {
                return false
            }
            lastPoint = point
            
            if lineChartView.data === nil {
                return false
            }
        }
        
        return true
    }
}

extension QTTutorDashboardTableViewCell: ChartViewDelegate {
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        setData(chartType: chartType, durationType: durationType, chartData: chartData)
    }
}

