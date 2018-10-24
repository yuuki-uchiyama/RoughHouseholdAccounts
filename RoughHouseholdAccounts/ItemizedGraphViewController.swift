//
//  LineGraphViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/10/18.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import HMSegmentedControl
import Charts
import CoreData

//折れ線グラフのX軸
public class ItemizedGraphFormatter: NSObject, IAxisValueFormatter{
    // x軸のラベル
    var xLabelArray: [String]!
    
    public func labelArraySetting(_ labelArray:[String]){
        xLabelArray = labelArray
    }
    // デリゲート。TableViewのcellForRowAtで、indexで渡されたセルをレンダリングするのに似てる。
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // 0 -> Jan, 1 -> Feb...
        return xLabelArray[Int(value)]
    }
}

class ItemizedGraphViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ChartViewDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var selectType = 0
    @IBOutlet weak var PVView: UIView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    var categoryTitleArray: [String] = []
    var selectCategory = ""
    @IBOutlet weak var toPreviousButton: UIButton!
    @IBOutlet weak var toNextButton: UIButton!
    @IBOutlet weak var lineGraphScrollView: UIScrollView!
    @IBOutlet weak var averageView: UIView!
    @IBOutlet weak var averageTitle: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var specialItemGraphView: SpecialItemGraphView!
    var backView: UIView!
    var displayItem = 0
    var specifyTermBool = false
    var startTerm = 2016
    var endTerm = 2018
    var selectInterval = 1
    
    var termArray:[NSDate] = []
    var tableViewTitleArray: [String] = []
    var displayReportsArray: [TotalReportData] = []
    var totalAmount = 0
    var firstInputCount = 0
    var amountAverage = 0

    
    var context:NSManagedObjectContext!
    var methods: Methods!

    var date = Date()
    let calendar = Calendar.current

    var separateDay: Int = 0
    var label: UILabel!
    var coverView: UIView!

    var lineChart: LineChartView!
    var averageLine:ChartLimitLine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        methods = Methods().self
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        toPreviousButton.isEnabled = false
        
        loadCategoryFromiCloud()
        
        lineChart = LineChartView(frame: CGRect(x: 10, y: 0, width: 1000, height: 300))
        lineChart.delegate = self
        lineChart.legend.enabled = false
        lineChart.chartDescription?.enabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelRotationAngle = 90
        lineChart.leftAxis.axisMinimum = 0
        lineChart.rightAxis.axisMinimum = 0
        averageLine = ChartLimitLine(limit: 0.0, label: "平均")
        lineChart.rightAxis.addLimitLine(averageLine)
        lineGraphScrollView.addSubview(lineChart)
        
        let nib =  UINib(nibName: "CategoryReportTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "category")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.borderWidth = 2.5
        tableView.layer.borderColor = UIColor.flatWhite.cgColor
        
        averageView.layer.borderWidth = 2.0
        
        backView = UIView(frame: self.view.frame)
        backView.backgroundColor = UIColor.white
        backView.alpha = 0.3
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let settingsFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let setting = try! context.fetch(settingsFetch)[0]
        if separateDay != Int(setting.separateDay){
            separateDay = Int(setting.separateDay)
            if calendar.component(.day, from: date) > separateDay{
                date = calendar.date(byAdding: .month, value: 1, to: calendar.startOfDay(for: Date()))!
            }else{
                date = Date()
            }
            firstInputCount = methods.inputTermCalcurate()
            categoryPickerView.selectRow(0, inComponent: 0, animated: true)
        }

        loadAllData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadAllData(){
        termAdjust()
        loadCategoryFromiCloud()
        print("OK")
        loadReportFromiCloud()
        tableView.reloadData()
        categoryPickerView.reloadAllComponents()
        editChartData()
    }
    
    func loadCategoryData(){
        loadReportFromiCloud()
        tableView.reloadData()
        editChartData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryTitleArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return PVView.frame.height
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: pickerView.frame.height / 3))
        label.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 13)
        label.text = categoryTitleArray[row]
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.flatWhite
        label.layer.borderWidth = label.frame.height / 10
        label.layer.borderColor = CategorySpendColor.colorArray[row].cgColor
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectCategory = categoryTitleArray[row]
        averageView.layer.borderColor = CategorySpendColor.colorArray[row].cgColor
        loadCategoryData()
        if row == 0{
            toPreviousButton.isEnabled = false
            toNextButton.isEnabled = true
        }else if row == pickerView.numberOfRows(inComponent: 0) - 1{
            toPreviousButton.isEnabled = true
            toNextButton.isEnabled = false
        }else{
            toPreviousButton.isEnabled = true
            toNextButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayReportsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! CategoryReportTableViewCell
        
        let records = displayReportsArray[indexPath.row]
        let termName = records.categoryName
        let termAmount = records.totalAmount
        let termRange = records.totalRange + records.totalAmount
        
        var percent: Double = 0.0
        var rangePercent: Double = 0.0
        if amountAverage != 0{
            percent = round(Double(termAmount) / Double(amountAverage) * 1000.0) / 10
            rangePercent = round(Double(records.totalRange) / Double(amountAverage) * 1000.0) / 10
        }
        let selectedPVRow = categoryPickerView.selectedRow(inComponent: 0)
        var cellColor: UIColor!
        switch displayItem {
        case 1:cellColor = UIColor.flatOrange
        case 2:cellColor = UIColor.flatRed
        case 3:cellColor = UIColor.flatGray
        case 4:cellColor = UIColor.flatYellow
        default:cellColor = CategorySpendColor.colorArray[selectedPVRow]
        }
        cell.setting(indexPath.row, termName, termAmount, termRange, percent, rangePercent, cellColor, monthlyBool: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "report", sender: indexPath.row)
    }
    
    @IBAction func typeChange(_ sender: UISegmentedControl) {
        selectType = sender.selectedSegmentIndex
        loadAllData()
    }
    
    @IBAction func toPrevious(_ sender: Any) {
        let row = categoryPickerView.selectedRow(inComponent: 0)
        if row != 0{
            categoryPickerView.selectRow(row - 1, inComponent: 0, animated: true)
        }
        loadCategoryData()
        if categoryPickerView.selectedRow(inComponent: 0) == 0{
            toPreviousButton.isEnabled = false
            toNextButton.isEnabled = true
        }else{
            toPreviousButton.isEnabled = true
            toNextButton.isEnabled = true
        }
    }
    
    @IBAction func toNext(_ sender: Any) {
        let row = categoryPickerView.selectedRow(inComponent: 0)
        if row != categoryTitleArray.count{
            categoryPickerView.selectRow(row + 1, inComponent: 0, animated: true)
        }
        loadCategoryData()
        if categoryPickerView.selectedRow(inComponent: 0) == categoryPickerView.numberOfRows(inComponent: 0) - 1{
            toPreviousButton.isEnabled = true
            toNextButton.isEnabled = false
        }else{
            toPreviousButton.isEnabled = true
            toNextButton.isEnabled = true
        }
    }
    
    func termAdjust(){
        termArray = []
        tableViewTitleArray = []
        displayReportsArray = []
        
        var year = 2018
        var month = 1
        var day = separateDay + 1
        
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        if specifyTermBool{
            year = endTerm
            month = 12 - selectInterval + 1
            if separateDay < 28{
                month -= 1
            }else{
                day = 1
            }
            if month < 1{
                year -= 1
                month += 12
            }
            var startDate = dateFormater.date(from: "\(year)/\(month)/\(day) 00:00:00")! as NSDate

            repeat {
                termArray.append(startDate)
                let displayDate = startDate.termCalculate(term: 1)
                let displayYear = Calendar.current.component(.year, from: displayDate as Date)
                let displayMonth = Calendar.current.component(.month, from: displayDate as Date)
                let endMonth = displayMonth + selectInterval - 1
                var tableViewTitle = "\(displayYear)年\(endMonth)月 ~ \(displayMonth)月"
                if selectInterval == 1{
                    tableViewTitle = "\(displayYear)年\(displayMonth)月"
                }else if displayMonth == 12{
                    tableViewTitle = "\(endMonth - 12)月 ~ \(displayYear)年\(displayMonth)月"
                }
                tableViewTitleArray.append(tableViewTitle)
                let totalReportData = TotalReportData(tableViewTitle)
                displayReportsArray.append(totalReportData)
                let reduce = DateComponents(month: -(selectInterval))
                startDate = Calendar.current.date(byAdding: reduce, to: startDate as Date)! as NSDate
                
                month -= selectInterval
                if month < 1{
                    year -= 1
                    month += 12
                }
            } while(year >= startTerm)
        }else{
            year = calendar.component(.year, from: date)
            month = calendar.component(.month, from: date)
            if separateDay < 28{
                month -= 1
                if month == 0{
                    year -= 1
                    month = 12
                }
            }else{
                day = 1
            }
            
            var startDate = dateFormater.date(from: "\(year)/\(month)/\(day) 00:00:00")! as NSDate
            for _ in 0 ..< 23{
                termArray.append(startDate)
                let displayDate = startDate.termCalculate(term: 1)
                let displayYear = Calendar.current.component(.year, from: displayDate as Date)
                let displayMonth = Calendar.current.component(.month, from: displayDate as Date)
                let tableViewTitle = "\(displayYear)年\(displayMonth)月"
                tableViewTitleArray.append(tableViewTitle)
                let totalReportData = TotalReportData(tableViewTitle)
                displayReportsArray.append(totalReportData)
                let reduce = DateComponents(month: -1)
                startDate = Calendar.current.date(byAdding: reduce, to: startDate as Date)! as NSDate
            }
        }
        
        let width = 100 + (termArray.count * 35)
        lineChart.frame.size.width = CGFloat(width)
        lineGraphScrollView.contentSize = CGSize(width: width + 20, height: 300)

    }
    
    func loadCategoryFromiCloud(){
        categoryTitleArray = []
        
        if selectType == 1{
            categoryTitleArray = methods.loadIncomeCategory()
        }else{
            categoryTitleArray = methods.loadSpendCategory()
        }
        categoryPickerView.reloadAllComponents()
    }
    
    func loadReportFromiCloud(){
        totalAmount = 0
        amountAverage = 0
        
        var category: String?
        if displayItem == 0{
            category = categoryTitleArray[categoryPickerView.selectedRow(inComponent: 0)]
        }
        
        if displayItem == 1{
            for i in 0 ..< termArray.count{
                displayReportsArray[i].removeAll()
                let startDate = termArray[i]
                let endDate = startDate.termCalculate(term: selectInterval)
                let spendReportArray = methods.loadSpendReport(startDate, endDate, category)
                let incomeReportArray = methods.loadIncomeReport(startDate, endDate, category)
                for report in spendReportArray{
                    let reportData = ReportData()
                    reportData.castFromSpendReport(report)
                    displayReportsArray[i].spendIncomeAppend(reportData)
                }
                for report in incomeReportArray{
                    let reportData = ReportData()
                    reportData.castFromIncomeReport(report)
                    displayReportsArray[i].spendIncomeAppend(reportData)
                }
                totalAmount += displayReportsArray[i].totalAmount
            }
            var array = displayReportsArray
            array.sort()
            var minimum = Double(array[0].totalAmount)
            if minimum >= 0 {
                minimum = 0
            }
            lineChart.leftAxis.axisMinimum = minimum
            lineChart.rightAxis.axisMinimum = minimum
        }else{
            lineChart.leftAxis.axisMinimum = 0
            lineChart.rightAxis.axisMinimum = 0
            switch selectType {
            case 0:
                for i in 0 ..< termArray.count{
                    displayReportsArray[i].removeAll()
                    let startDate = termArray[i]
                    let endDate = startDate.termCalculate(term: selectInterval)
                    let reportArray = methods.loadSpendReport(startDate, endDate, category)
                    for report in reportArray{
                        let reportData = ReportData()
                        reportData.castFromSpendReport(report)
                        displayReportsArray[i].append(reportData)
                    }
                    totalAmount += displayReportsArray[i].totalAmount
                }
            case 1:
                for i in 0 ..< termArray.count{
                    displayReportsArray[i].removeAll()
                    let startDate = termArray[i]
                    let endDate = startDate.termCalculate(term: selectInterval)
                    let reportArray = methods.loadIncomeReport(startDate, endDate, category)
                    for report in reportArray{
                        let reportData = ReportData()
                        reportData.castFromIncomeReport(report)
                        displayReportsArray[i].append(reportData)
                    }
                    totalAmount += displayReportsArray[i].totalAmount
                }
            case 2:
                for i in 0 ..< termArray.count{
                    displayReportsArray[i].removeAll()
                    let startDate = termArray[i]
                    let endDate = startDate.termCalculate(term: selectInterval)
                    let reportArray = methods.loadWasteSpendReport(startDate, endDate, category)
                    for report in reportArray{
                        let reportData = ReportData()
                        reportData.castFromSpendReport(report)
                        displayReportsArray[i].append(reportData)
                    }
                    totalAmount += displayReportsArray[i].totalAmount
                }
            default:break
            }
        }
        if totalAmount == 0{
            averageLabel.text = "0円"
        }else{
            amountAverage = totalAmount / firstInputCount
            averageLabel.text = String(amountAverage) + "円"
        }
        let selectRow = categoryPickerView.selectedRow(inComponent: 0)
        var categoryColor: UIColor!
        if displayItem != 0{
            if label == nil{
                label = UILabel()
                coverView = UIView()
            }
            coverView.frame.size = CGSize(width: self.view.frame.width, height: segmentedControl.frame.height + PVView.frame.height)
            coverView.frame.origin = CGPoint(x: 0, y: 0)
            coverView.backgroundColor = UIColor.flatSand
            label.frame = coverView.frame
            label.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 20 )
            label.textAlignment = NSTextAlignment.center
            
            self.view.addSubview(coverView)
            self.view.addSubview(label)
        }else{
            if label != nil{
                coverView.removeFromSuperview()
                label.removeFromSuperview()
            }
        }
        switch displayItem {
        case 0:
            categoryColor = CategorySpendColor.colorArray[selectRow]
        case 1:
            categoryColor = UIColor.flatOrange
            label.text = "収支の総計"
        case 2:
            categoryColor = UIColor.flatRed
            label.text = "支出合計"
        case 3:
            categoryColor = UIColor.flatGray
            label.text = "収入合計"
        case 4:
            categoryColor = UIColor.flatYellow
            label.text = "ムダ遣い？合計"
        default:break
        }
        averageTitle.backgroundColor = categoryColor
        averageView.layer.borderColor = categoryColor.cgColor
        
        averageLine.limit = Double(amountAverage)
        averageLine.lineColor = categoryColor
        
        let valueFormatter = ItemizedGraphFormatter()
        valueFormatter.labelArraySetting(tableViewTitleArray)
        lineChart.xAxis.valueFormatter = valueFormatter
        lineChart.xAxis.labelCount = tableViewTitleArray.count - 1
    }
    
    func editChartData(){
        var chartDataEntries:[ChartDataEntry] = []

        for i in 0 ..< displayReportsArray.count{
            chartDataEntries.append(ChartDataEntry(x: Double(i), y: Double(displayReportsArray[i].totalAmount)))
        }
        
        let lineDataSet = LineChartDataSet(values: chartDataEntries, label: "")
        lineDataSet.drawIconsEnabled = false
        let selectRow = categoryPickerView.selectedRow(inComponent: 0)
        let color = CategorySpendColor.colorArray[selectRow]
        switch displayItem {
        case 1:
            lineDataSet.colors = [UIColor.flatOrange]
            lineDataSet.circleColors = [UIColor.flatOrange]
        case 2:
            lineDataSet.colors = [UIColor.flatRed]
            lineDataSet.circleColors = [UIColor.flatRed]
        case 3:
            lineDataSet.colors = [UIColor.flatGray]
            lineDataSet.circleColors = [UIColor.flatGray]
        case 4:
            lineDataSet.colors = [UIColor.flatYellow]
            lineDataSet.circleColors = [UIColor.flatYellow]
        default:
            lineDataSet.colors = [color]
            lineDataSet.circleColors = [color]
        }
        
        lineChart.data = LineChartData(dataSet: lineDataSet)
        lineChart.animate(xAxisDuration: 0.1, yAxisDuration: 0.3)
    }
    
    func buttonTap(_ button: UIButton) {
        if button.isSelected{
            button.isSelected = false
            displayItem = 0
            specifyTermBool = false
            endTerm = 2018
            startTerm = 2016
            selectInterval = 1
            loadAllData()
        }else{
            specialItemGraphView = SpecialItemGraphView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
            specialItemGraphView.center = self.view.center
            specialItemGraphView.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            specialItemGraphView.OKButton.addTarget(self, action: #selector(specifyGraphSetting), for: .touchUpInside)
            specialItemGraphView.cornerLayout(.collectionView)
            self.view.addSubview(backView)
            self.view.addSubview(specialItemGraphView)
        }
    }
    
    @objc func cancel(){
        backView.removeFromSuperview()
    }
        
    @objc func specifyGraphSetting(){
        if !specialItemGraphView.displayDefaultButton.isSelected || !specialItemGraphView.termDefaultButton.isSelected{
            displayItem = specialItemGraphView.displayItem
            specifyTermBool = specialItemGraphView.specifyTermBool
            endTerm = specialItemGraphView.endTerm
            startTerm = specialItemGraphView.startTerm
            selectInterval = specialItemGraphView.selectInterval
            
            switch displayItem {
            case 2:segmentedControl.selectedSegmentIndex = 0
            selectType = 0
            case 3:segmentedControl.selectedSegmentIndex = 1
            selectType = 1
            case 4:segmentedControl.selectedSegmentIndex = 2
            selectType = 2
            default:break
            }
            
            loadAllData()
        }
        specialItemGraphView.removeFromSuperview()
        backView.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let reportViewController: ReportViewController = segue.destination as! ReportViewController
        let tableViewRow = sender as! Int
        let categoryRow = categoryPickerView.selectedRow(inComponent: 0)
        reportViewController.displayType = selectType
        switch displayItem {
        case 0:
            reportViewController.color = CategorySpendColor.colorArray[categoryRow]
            reportViewController.categoryName = categoryTitleArray[categoryRow]
            reportViewController.displayCategoryName = categoryTitleArray[categoryRow]
        case 1:
            reportViewController.color = UIColor.flatOrange
            reportViewController.displayCategoryName = "収支総額"
            reportViewController.allReportBool = true
        case 2:
            reportViewController.color = UIColor.flatRed
            reportViewController.displayCategoryName = "支出合計"
        case 3:
            reportViewController.color = UIColor.flatGray
            reportViewController.displayCategoryName = "収入合計"
        case 4:
            reportViewController.color = UIColor.flatYellow
            reportViewController.displayCategoryName = "ムダ遣い？合計"
        default:break
        }
        reportViewController.startDate = termArray[tableViewRow]
        reportViewController.endDate = termArray[tableViewRow].termCalculate(term: selectInterval)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToGraph(segue: UIStoryboardSegue){
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
