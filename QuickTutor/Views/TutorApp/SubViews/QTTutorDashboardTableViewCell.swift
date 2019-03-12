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
    
    func currencyFormat(precision: Int) -> String {
        let number = self / 100
        return String(format: "$%.*f", precision, number)
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
        lineChartView.dragXEnabled = true
        lineChartView.dragYEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.noDataFont = UIFont.qtRegularFont(size: 12)
        lineChartView.noDataTextColor = UIColor.qtAccentColor
        lineChartView.noDataText = "There is no data available."
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onLineChartViewPanGestureRecognized(_:)))
        if let panGesture = panGesture {
            panGesture.delegate = self
            lineChartView.addGestureRecognizer(panGesture)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc
    func onLineChartViewPanGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            let h = lineChartView.getHighlightByTouchPoint(gesture.location(in: lineChartView))
            lineChartView.highlightValue(h, callDelegate: true)
            print("long press gesture started")
        } else {
            lineChartView.highlightValue(nil)
            setData(chartType: chartType, durationType: durationType, chartData: chartData)
            print("long press gesture ended")
        }
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
        switch chartType {
        case .earnings:
            self.leftValueLabel.text = total.currencyFormat(precision: 2)
        case .hours:
            self.leftValueLabel.text = String(format: "%.2f", total)
        case .sessions:
            self.leftValueLabel.text = String(format: "%d", total)
        }
        
        if total > 0 {
            let marker = QTTutorDashboardMarkerView.load() as QTTutorDashboardMarkerView
            marker.setChartType(type: chartType)
            marker.chartView = lineChartView
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
            set.highlightEnabled = true
            let gradientColors = [UIColor.qtAccentColor.withAlphaComponent(0.6).cgColor,
                                  UIColor.qtAccentColor.withAlphaComponent(0.3).cgColor,
                                  UIColor.clear.cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: [1, 0.5, 0])!
            
            set.fillAlpha = 1
            set.fill = Fill(linearGradient: gradient, angle: 90)
            set.drawFilledEnabled = true
            set.drawCirclesEnabled = false
            set.mode = .linear
            let data = LineChartData(dataSet: set)
            lineChartView.data = data
            
            // Highlight min and max values.
            if let chartData = chartData, !chartData.isEmpty {
                // Get min and max data to highlight.
                let minData = chartData.min {a, b in a.valueY < b.valueY}
                let minIndex = chartData.firstIndex(where: {$0.valueY == minData?.valueY})
                
                let maxData = chartData.max {a, b in a.valueY < b.valueY}
                let maxIndex = chartData.firstIndex(where: {$0.valueY == maxData?.valueY})
                
                var highlights: [Highlight] = []
                if let minIndex = minIndex, let minData = minData {
                    highlights.append(Highlight(x: Double(minIndex), y: minData.valueY, dataSetIndex: 0))
                }
                
                if let maxIndex = maxIndex, let maxData = maxData {
                    highlights.append(Highlight(x: Double(maxIndex), y: maxData.valueY, dataSetIndex: 0))
                    lineChartView.setVisibleYRangeMaximum(maxData.valueY + maxData.valueY / 4, axis: YAxis.AxisDependency.left)
                }
                lineChartView.highlightValues(highlights)
            }
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
        }
        
        return true
    }
}

extension QTTutorDashboardTableViewCell: ChartViewDelegate {
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        setData(chartType: chartType, durationType: durationType, chartData: chartData)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let data = entry.data as? QTTutorDashboardChartData,
            let chartType = self.chartType,
            let durationType = self.durationType else { return }
        
        DispatchQueue.main.async {
            switch chartType {
            case .earnings:
                self.leftValueLabel.text = data.valueY.currencyFormat(precision: 2)
            case .hours:
                self.leftValueLabel.text = String(format: "%.2f", data.valueY)
            case .sessions:
                self.leftValueLabel.text = String(format: "%d", Int(data.valueY))
            }
            
            let formatter: DateFormatter = DateFormatter()
            switch durationType {
            case .week, .month:
                formatter.dateFormat = "MMM dd"
            case .quarter, .year:
                formatter.dateFormat = "MMM YYYY"
            }
            self.leftTitleLabel.text = formatter.string(from: Date(timeIntervalSince1970: data.date))
        }
    }
}

