//
//  BarsViewController.swift
//  WhoSings
//
//  Created by Jean Raphael Bordet on 04/10/21.
//

import UIKit
import Charts

enum Option {
	case toggleValues
	case toggleIcons
	case toggleHighlight
	case animateX
	case animateY
	case animateXY
	case saveToGallery
	case togglePinchZoom
	case toggleAutoScaleMinMax
	case toggleData
	case toggleBarBorders
	// LineChart
	case toggleGradientLine
	// CandleChart
	case toggleShadowColorSameAsCandle
	case toggleShowCandleBar
	// CombinedChart
	case toggleLineValues
	case toggleBarValues
	case removeDataSet
	// CubicLineSampleFillFormatter
	case toggleFilled
	case toggleCircles
	case toggleCubic
	case toggleHorizontalCubic
	case toggleStepped
	// HalfPieChartController
	case toggleXValues
	case togglePercent
	case toggleHole
	case spin
	case drawCenter
	case toggleLabelsMinimumAngle
	// RadarChart
	case toggleXLabels
	case toggleYLabels
	case toggleRotate
	case toggleHighlightCircle
	
	var label: String {
		switch self {
		case .toggleValues: return "Toggle Y-Values"
		case .toggleIcons: return "Toggle Icons"
		case .toggleHighlight: return "Toggle Highlight"
		case .animateX: return "Animate X"
		case .animateY: return "Animate Y"
		case .animateXY: return "Animate XY"
		case .saveToGallery: return "Save to Camera Roll"
		case .togglePinchZoom: return "Toggle PinchZoom"
		case .toggleAutoScaleMinMax: return "Toggle auto scale min/max"
		case .toggleData: return "Toggle Data"
		case .toggleBarBorders: return "Toggle Bar Borders"
		// LineChart
		case .toggleGradientLine: return "Toggle Gradient Line"
		// CandleChart
		case .toggleShadowColorSameAsCandle: return "Toggle shadow same color"
		case .toggleShowCandleBar: return "Toggle show candle bar"
		// CombinedChart
		case .toggleLineValues: return "Toggle Line Values"
		case .toggleBarValues: return "Toggle Bar Values"
		case .removeDataSet: return "Remove Random Set"
		// CubicLineSampleFillFormatter
		case .toggleFilled: return "Toggle Filled"
		case .toggleCircles: return "Toggle Circles"
		case .toggleCubic: return "Toggle Cubic"
		case .toggleHorizontalCubic: return "Toggle Horizontal Cubic"
		case .toggleStepped: return "Toggle Stepped"
		// HalfPieChartController
		case .toggleXValues: return "Toggle X-Values"
		case .togglePercent: return "Toggle Percent"
		case .toggleHole: return "Toggle Hole"
		case .spin: return "Spin"
		case .drawCenter: return "Draw CenterText"
		case .toggleLabelsMinimumAngle: return "Toggle Labels Minimum Angle"
		// RadarChart
		case .toggleXLabels: return "Toggle X-Labels"
		case .toggleYLabels: return "Toggle Y-Labels"
		case .toggleRotate: return "Toggle Rotate"
		case .toggleHighlightCircle: return "Toggle highlight circle"
		}
	}
}

class DemoBaseViewController: UIViewController, ChartViewDelegate {
	private var optionsTableView: UITableView? = nil
	let parties = ["Party A", "Party B", "Party C", "Party D", "Party E", "Party F",
				   "Party G", "Party H", "Party I", "Party J", "Party K", "Party L",
				   "Party M", "Party N", "Party O", "Party P", "Party Q", "Party R",
				   "Party S", "Party T", "Party U", "Party V", "Party W", "Party X",
				   "Party Y", "Party Z"]
	
	@IBOutlet weak var optionsButton: UIButton!
	var options: [Option]!
	
	var shouldHideData: Bool = false
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initialize()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.initialize()
	}
	
	private func initialize() {
		self.edgesForExtendedLayout = []
	}
		
	func updateChartData() {
		fatalError("updateChartData not overridden")
	}
	
	func setup(pieChartView chartView: PieChartView) {
		chartView.usePercentValuesEnabled = true
		chartView.drawSlicesUnderHoleEnabled = false
		chartView.holeRadiusPercent = 0.58
		chartView.transparentCircleRadiusPercent = 0.61
		chartView.chartDescription?.enabled = false
		chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
		
		chartView.drawCenterTextEnabled = true
		
		let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.lineBreakMode = .byTruncatingTail
		paragraphStyle.alignment = .center
		
		let centerText = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
		centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 13)!,
								  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
		centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!,
								  .foregroundColor : UIColor.gray], range: NSRange(location: 10, length: centerText.length - 10))
		centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!,
								  .foregroundColor : UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)], range: NSRange(location: centerText.length - 19, length: 19))
		chartView.centerAttributedText = centerText;
		
		chartView.drawHoleEnabled = true
		chartView.rotationAngle = 0
		chartView.rotationEnabled = true
		chartView.highlightPerTapEnabled = true
		
		let l = chartView.legend
		l.horizontalAlignment = .right
		l.verticalAlignment = .top
		l.orientation = .vertical
		l.drawInside = false
		l.xEntrySpace = 7
		l.yEntrySpace = 0
		l.yOffset = 0
	}
	
	// TODO: Cannot override from extensions
	//extension DemoBaseViewController: ChartViewDelegate {
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		NSLog("chartValueSelected");
	}
	
	func chartValueNothingSelected(_ chartView: ChartViewBase) {
		NSLog("chartValueNothingSelected");
	}
	
	func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
		
	}
	
	func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
		
	}
}

extension DemoBaseViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		if optionsTableView != nil {
			return 1
		}
		
		return 0
	}
	
	@available(iOS 2.0, *)
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if optionsTableView != nil {
			return options.count
		}
		
		return 0
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if optionsTableView != nil {
			return 40.0;
		}
		
		return 44.0;
	}
	
	@available(iOS 2.0, *)
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
		
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
			cell?.backgroundView = nil
			cell?.backgroundColor = .clear
			cell?.textLabel?.textColor = .white
		}
		cell?.textLabel?.text = self.options[indexPath.row].label
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if optionsTableView != nil {
			tableView.deselectRow(at: indexPath, animated: true)
			
			optionsTableView?.removeFromSuperview()
			self.optionsTableView = nil
		}
		
	}
}

