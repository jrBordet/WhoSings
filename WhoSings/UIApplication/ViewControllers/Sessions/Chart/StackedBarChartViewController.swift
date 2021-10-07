

import Charts
import UIKit
import SnapKit

class StackedBarChartViewController: DemoBaseViewController {
	
	lazy var chartView = BarChartView()
	
	lazy var formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 1
		formatter.negativeSuffix = " points"
		formatter.positiveSuffix = " points"
		
		return formatter
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.addSubview(chartView)
		
		chartView.snp.makeConstraints { make in
			make.right.left.equalTo(self.view)
			make.topMargin.top.equalToSuperview().offset(56)
			make.bottom.equalToSuperview()
		}
		
		// Do any additional setup after loading the view.
		self.title = ""
		self.options = []
		
		
		chartView.delegate = self
		
		chartView.chartDescription?.enabled = false
		
		chartView.maxVisibleCount = 40
		chartView.drawBarShadowEnabled = false
		chartView.drawValueAboveBarEnabled = false
		chartView.highlightFullBarEnabled = false
		
		let leftAxis = chartView.leftAxis
		leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
		leftAxis.axisMinimum = 0
		
		chartView.rightAxis.enabled = false
		
		let xAxis = chartView.xAxis
		xAxis.labelPosition = .top
		
		let l = chartView.legend
		l.horizontalAlignment = .right
		l.verticalAlignment = .bottom
		l.orientation = .horizontal
		l.drawInside = false
		l.form = .square
		l.formToTextSpace = 4
		l.xEntrySpace = 6
		
		self.updateChartData()
	}
	
	var sessions: [UserSession] = [
		.init(username: "bob", score: 10),
		.init(username: "bob", score: 10),
		.init(username: "margot", score: 20),
		.init(username: "margot", score: 20),
		.init(username: "margot", score: 40)
	]
	
	override func updateChartData() {
		if self.shouldHideData {
			chartView.data = nil
			return
		}
				
		self.setChartData(count: sessions.count, range: 10)
	}
	
	func setChartData(count: Int, range: UInt32) {
		let sessionsdictionary: [String : [UserSession]] = Dictionary(grouping: sessions, by: { $0.username })
		
		let yVals = sessionsdictionary.enumerated().makeIterator().map { (offset: Int, element: Dictionary<String, [UserSession]>.Element) -> BarChartDataEntry  in
			let v: [UserSession] = element.value
			let vv: [Double] = v.map { Double($0.score) }
			
			return BarChartDataEntry(
				x: Double(offset),
				yValues: vv
			)
		}
		
		let set = BarChartDataSet(
			entries: yVals,
			label: NSLocalizedString("Users", comment: "")
		)
		
		set.drawIconsEnabled = false
		
		set.colors = [
			ChartColorTemplates.material()[0],
			ChartColorTemplates.material()[1],
			ChartColorTemplates.material()[2],
			ChartColorTemplates.material()[3]
		]
		
		set.stackLabels = sessionsdictionary.keys.map { String($0) }
		
		let data = BarChartData(dataSet: set)
		data.setValueFont(.systemFont(ofSize: 7, weight: .light))
		data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
		data.setValueTextColor(.white)
		
		chartView.fitBars = true
		chartView.data = data
	}
}

