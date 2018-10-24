//
//  GraphViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/02.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import HMSegmentedControl
import Charts
import CoreData

extension ChartColorTemplates{
    @objc open class func original () -> [NSUIColor]
    {
        return [
            CategorySpendColor.class1,
            CategorySpendColor.class2,
            CategorySpendColor.class3,
            CategorySpendColor.class4,
            CategorySpendColor.class5,
            CategorySpendColor.class6,
            CategorySpendColor.class7,
            CategorySpendColor.class8,
            CategorySpendColor.class9,
            CategorySpendColor.class10
        ]
    }
}

class ReportData: Comparable{
    static func == (lhs: ReportData, rhs: ReportData) -> Bool {
        return lhs.date == rhs.date
    }
    static func <(x: ReportData, y: ReportData) -> Bool {
        if x.date < y.date {
            return true
        }else{
            return false
        }
    }
    
    var type: Int!
    var category: String!
    var date: Date!
    var amount: Int!
    var rangeString: String!
    var range: Int!
    var wasteBool: Bool!
    var originalData: Any!
    
    init(){ }
    
    func castFromSpendReport(_ SR:SpendReport){
        originalData = SR
        if SR.wasteBool{
            type = 2
        }else{
            type = 0
        }
        category = SR.category
        date = SR.date
        amount = Int(SR.amount)
        rangeString = SR.rangeString
        range = Int(SR.range)
        wasteBool = SR.wasteBool
    }
    
    func castFromIncomeReport(_ IR:IncomeReport){
        originalData = IR
        type = 1
        category = IR.category
        date = IR.date
        amount = Int(IR.amount)
        rangeString = IR.rangeString
        range = Int(IR.range)
        wasteBool = false
    }
}
class TotalReportData: Comparable{
    static func == (lhs: TotalReportData, rhs: TotalReportData) -> Bool {
        return lhs.categoryName == rhs.categoryName
    }
    static func <(x: TotalReportData, y: TotalReportData) -> Bool {
        if x.totalAmount < y.totalAmount {
            return true
        }else{
            return false
        }
    }
    
    var categoryName: String
    var array:[ReportData] = []
    var totalAmount: Int = 0
    var totalRange: Int = 0
    
    var totalSpend: Int = 0
    var totalSpendRange: Int = 0
    var totalIncome: Int = 0
    var totalIncomeRange: Int = 0
    
    init(_ name:String){
        categoryName = name
    }
    
    func append(_ record:ReportData){
        array.append(record)
        totalAmount += record.amount
        totalRange += record.range
    }
    
    func spendIncomeAppend(_ record:ReportData){
        array.append(record)
        if record.type == 1{
            totalIncome += record.amount
            totalIncomeRange += record.range
        }else{
            totalSpend += record.amount
            totalSpendRange += record.range
        }
        totalAmount = totalIncome - totalSpend
        totalRange = totalIncomeRange - totalSpendRange
    }
    
    func remove(_ record:ReportData){
        if array.contains(record){
            array.remove(value: record)
            totalAmount -= record.amount
            totalRange -= record.range
        }
    }
    
    func removeAll(){
        array.removeAll()
        totalAmount = 0
        totalRange = 0
    }
}

class MonthlyGraphViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate {
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var backGroundColorView: UIView!
    @IBOutlet weak var spendIncomeControl: UISegmentedControl!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allAmount1View: UIView!
    @IBOutlet weak var allAmount1Label: UILabel!
    @IBOutlet weak var allAmount1Title: UILabel!
    
    @IBOutlet weak var allAmount2View: UIView!
    @IBOutlet weak var allAmount2Label: UILabel!
    @IBOutlet weak var allAmount2Title: UILabel!

    var specialTermGraphView: SpecialTermGraphView!
    var backView:UIView!
    var specialGraphBool = false
    var allGraphBool = false
    var termTuple:(year:Int,month:Int,term:Int) = (year: 2010, month: 1, term: 1)
//    上部バー関係
    var segmentedControl: HMSegmentedControl!
    var sectionTitles: [String] = []
    var colorDic: [Int:UIColor] = [1:MonthColor.JanColor, 2:MonthColor.FebColor, 3:MonthColor.MarColor, 4:MonthColor.AprColor, 5:MonthColor.MayColor, 6:MonthColor.JunColor, 7:MonthColor.JulColor, 8:MonthColor.AugColor, 9:MonthColor.SepColor, 10:MonthColor.OctColor, 11:MonthColor.NovColor, 0:MonthColor.DecColor]
    var colorNum = 0
    
//    支出/収入のsegmentedControl関係
    var displayType = 0
    var displayNameArray: [String] = []
    var displayReportsArray: [TotalReportData] = []
    var denominator:Double = 0
    
    
//    データ取り出し関係
    var context: NSManagedObjectContext!
    var methods: Methods!

    var date = Date()
    let calendar = Calendar.current
    var startYear = 2018
    var startMonth = 1
    var endDate: NSDate?
    var startDate: NSDate?
    var label: UILabel!
    var coverView: UIView!
    var selectedMonth = 0
    var separateDay: Int = 0
    
//    総額
    var allAmount = 0
    var allRange = 0
    var comparisonAllAmount = 0
    
    
//    円グラフ
    let pieChartAttributedDic: [NSAttributedStringKey : UIFont] = [
        .font : UIFont(name: "Hiragino Maru Gothic ProN", size: 18)!
    ]
    var dataEntries = [PieChartDataEntry]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        methods = Methods().self

//        円グラフの設定
        pieChart.legend.enabled = false
        pieChart.rotationEnabled = false
        pieChart.drawEntryLabelsEnabled = false
        pieChart.chartDescription?.enabled = false
        pieChart.backgroundColor = UIColor.flatWhite
        pieChart.delegate = self
        
//        テーブルビュー設定
        let nib =  UINib(nibName: "CategoryReportTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "category")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.borderWidth = 2.5
        tableView.layer.borderColor = UIColor.flatWhite.cgColor
        
        allAmount1View.layer.borderWidth = 3.0
        allAmount2View.layer.borderWidth = 3.0
        
        backView = UIView(frame: self.view.frame)
        backView.backgroundColor = UIColor.white
        backView.alpha = 0.3
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
            if segmentedControl != nil{
                segmentedControl.removeFromSuperview()
            }
            changeSegmendControl()
            colorChange()
        }

        
        loadAllData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        segmentedControl.frame = tabView.frame
    }
    
    func loadAllData(){
        loadCategoryFromiCloud()
        termAdjust()
        loadReportFromiCloud()
        chartChange()
    }
    
    func loadTermData(){
        termAdjust()
        loadReportFromiCloud()
        chartChange()
    }
    
    func chartChange(){
        editPieChart()
        tableView.reloadData()
    }
    
    func changeSegmendControl(){
        sectionTitles.removeAll()
        startYear = calendar.component(.year, from: date)
        startMonth = calendar.component(.month, from: date)
        colorNum = startMonth
        sectionTitles.append("\(startYear)年\(startMonth)月                    ")
        for _ in 0 ... 23{
            if startMonth != 1{
                startMonth -= 1
            }else{
                startMonth = 12
                startYear -= 1
            }
            sectionTitles.append("\(startYear)年\(startMonth)月                    ")
        }
        segmentedControl = HMSegmentedControl.init(frame: tabView.frame)
        segmentedControl.sectionTitles = sectionTitles
        segmentedControl.fontAdjustOfSegmentedControl(13)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyle.box
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.down
        let chengeGraph :IndexChangeBlock = {(index:Int) -> Void in
            self.selectSegment(index)
        }
        segmentedControl.indexChangeBlock = chengeGraph
        self.view.addSubview(segmentedControl)
    }
    
    func selectSegment(_ index: Int){
        self.selectedMonth = index
        self.colorChange()
        self.loadAllData()
    }
    
    func colorChange(){
        var a = selectedMonth
        if self.colorNum < a{
            a -= 12
            if self.colorNum < a{
                a -= 12
            }
        }
        let num = (self.colorNum - a) % 12
        backGroundColorView.backgroundColor = colorDic[num]
        self.segmentedControl.selectionIndicatorColor = self.colorDic[num]
        self.segmentedControl.selectionIndicatorBoxColor = self.colorDic[num]
    }
    
    @IBAction func nextTerm(_ sender: Any) {
        var index = segmentedControl.selectedSegmentIndex + 1
        if index > 23 {
            index = 23
        }
        segmentedControl.setSelectedSegmentIndex(UInt(index), animated: true)
        selectSegment(index)
    }
    
    @IBAction func previousTerm(_ sender: Any) {
        var index = segmentedControl.selectedSegmentIndex - 1
        if index < 0 {
            index = 0
        }
        segmentedControl.setSelectedSegmentIndex(UInt(index), animated: true)
        selectSegment(index)
    }
    
//    円グラフのデータ更新
    func editPieChart(){
        dataEntries = []
        for records in displayReportsArray{
            dataEntries.append(PieChartDataEntry(value: Double(records.totalAmount), label: records.categoryName))
        }
        let dataSet = PieChartDataSet(values: dataEntries, label: "")
        dataSet.colors = ChartColorTemplates.original()
        dataSet.drawValuesEnabled = false
        let data = PieChartData(dataSet: dataSet)
        self.pieChart.data = data
        if denominator == 0{
            pieChart.centerAttributedText = NSAttributedString(string: "データなし", attributes: pieChartAttributedDic)
        }else{
        pieChart.centerAttributedText = NSAttributedString(string: "", attributes: pieChartAttributedDic)
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let row = Int(floor(highlight.x))
        let name = displayNameArray[row]
        let amount = Int(floor(highlight.y))
        pieChart.centerAttributedText = NSAttributedString(string: "\(name)\n\(amount)円", attributes: pieChartAttributedDic)
    }
    
//    テーブルビュー設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return displayReportsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! CategoryReportTableViewCell
        
        let records = displayReportsArray[indexPath.row]
        let categoryName = records.categoryName
        let categorySpend = records.totalAmount
        let categoryRange = records.totalRange + records.totalAmount

        var percent: Double = 0.0
        var rangePercent: Double = 0.0
        if denominator != 0{
            percent = round(Double(categorySpend) / denominator * 1000.0) / 10
            rangePercent = round(Double(records.totalRange) / denominator * 1000.0) / 10
        }
        let cellColor = CategorySpendColor.colorArray[indexPath.row]
        
        cell.setting(indexPath.row, categoryName, categorySpend, categoryRange, percent, rangePercent, cellColor, monthlyBool: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "report", sender: indexPath.row)
    }
    
//    グラフに表示する項目の設定(segmentedControl)
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        displayType = sender.selectedSegmentIndex
        loadAllData()
    }
    
//    期間の設定
    func termAdjust(){
        var year = 2018
        var month = 1
        var day = separateDay + 1
        
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        if allGraphBool{
            startDate = nil
            endDate = nil
        }else if specialGraphBool{
            year = specialTermGraphView.selectYear
            month = specialTermGraphView.selectMonth
            if separateDay < 28{
                month -= 1
            }else{
                day = 1
            }
            if month == 0{
                year -= 1
                month += 12
            }
            startDate = dateFormater.date(from: "\(year)/\(month)/\(day) 00:00:00")! as NSDate
            endDate = startDate!.termCalculate(term: specialTermGraphView.selectTerm)
            print(specialTermGraphView.selectTerm)
        }else{
            year = calendar.component(.year, from: date)
            month = calendar.component(.month, from: date)
            if separateDay < 28{
                month -= 1
            }else{
                day = 1
            }
            if selectedMonth >= month + 12{
                year -= 2
                month += 24 - selectedMonth
            }else if selectedMonth >= month{
                year -= 1
                month += 12 - selectedMonth
            }else{
                month -= selectedMonth
            }
            startDate = dateFormater.date(from: "\(year)/\(month)/\(day) 00:00:00")! as NSDate
            endDate = startDate!.termCalculate(term: 1)
        }

        if (allGraphBool || specialGraphBool){
            if label == nil{
                label = UILabel(frame: tabView.frame)
                coverView = UIView(frame: tabView.frame)
            }
            coverView.frame.size.width = self.view.frame.width
            coverView.center = tabView.center
            coverView.backgroundColor = UIColor.flatSand
            if allGraphBool{
                label.text = "今までの累計記録"
            }else{
                var term = ""
                for button in specialTermGraphView.specifyTermButtonArray{
                    if button.isSelected{
                        term = (button.titleLabel?.text)!
                    }
                }
                label.text = "\(year)年\(month)月から\(term)"
            }
            label.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 15 )
            label.textAlignment = NSTextAlignment.center
            self.view.addSubview(coverView)
            self.view.addSubview(label)
        }else{
            if label != nil{
                coverView.removeFromSuperview()
                label.removeFromSuperview()
            }
        }

    }
    
//    データ読み込み関係
//    カテゴリ読み込み
    func loadCategoryFromiCloud(){
        displayNameArray = []
        
        switch displayType {
        case 0:
            displayNameArray = methods.loadSpendCategory()
        case 1:
            displayNameArray = methods.loadIncomeCategory()
        case 2:
            displayNameArray = methods.loadSpendCategory()
        default:break
        }
        
        displayReportsArray = []
        for category in displayNameArray{
            let a = TotalReportData(category)
            displayReportsArray.append(a)
        }
    }
    
//    記録読み込み
    func loadReportFromiCloud(){
        allAmount = 0
        allRange = 0
        
        switch displayType {
        case 0:
            for totalReportData in displayReportsArray{
                let category = totalReportData.categoryName
                let reportArray = methods.loadSpendReport(startDate, endDate, category)
                for report in reportArray{
                    let reportData = ReportData()
                    reportData.castFromSpendReport(report)
                    totalReportData.append(reportData)
                }
                allAmount += totalReportData.totalAmount
                allRange += totalReportData.totalRange
            }
            let totalIncomeArray = methods.loadIncomeReport(startDate, endDate, nil)
            var totalIncome = 0
            for report in totalIncomeArray{
                totalIncome += Int(report.amount)
            }
            comparisonAllAmount = totalIncome
            allAmount1Title.text = "収入総額"
            allAmount1View.layer.borderColor = UIColor.flatGray.cgColor
            allAmount2Title.text = "支出総額"
            allAmount2View.layer.borderColor = UIColor.flatRed.cgColor

        case 1:
            for totalReportData in displayReportsArray{
                let category = totalReportData.categoryName
                let reportArray = methods.loadIncomeReport(startDate, endDate, category)
                for report in reportArray{
                    let reportData = ReportData()
                    reportData.castFromIncomeReport(report)
                    totalReportData.append(reportData)
                }
                allAmount += totalReportData.totalAmount
                allRange += totalReportData.totalRange
            }
            let totalSpendArray = methods.loadSpendReport(startDate, endDate, nil)
            var totalSpend = 0
            for report in totalSpendArray{
                totalSpend += Int(report.amount)
            }
            comparisonAllAmount = totalSpend
            allAmount1Title.text = "支出総額"
            allAmount1View.layer.borderColor = UIColor.flatRed.cgColor
            allAmount2Title.text = "収入総額"
            allAmount2View.layer.borderColor = UIColor.flatGray.cgColor

        case 2:
            for totalReportData in displayReportsArray{
                let category = totalReportData.categoryName
                let reportArray = methods.loadWasteSpendReport(startDate, endDate, category)
                for report in reportArray{
                    let reportData = ReportData()
                    reportData.castFromSpendReport(report)
                    totalReportData.append(reportData)
                }
                allAmount += totalReportData.totalAmount
                allRange += totalReportData.totalRange
            }
            let totalSpendArray = methods.loadSpendReport(startDate, endDate, nil)
            var totalSpend = 0
            for report in totalSpendArray{
                totalSpend += Int(report.amount)
            }
            comparisonAllAmount = totalSpend
            allAmount1Title.text = "支出総額"
            allAmount1View.layer.borderColor = UIColor.flatRed.cgColor
            allAmount2Title.text = "ムダ遣い？総額"
            allAmount2View.layer.borderColor = UIColor.flatYellow.cgColor

        default:break
        }
        allAmount1Label.text = String(comparisonAllAmount) + "円"
        allAmount2Label.text = String(allAmount) + "円"
        denominator = Double(allAmount)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let reportViewController: ReportViewController = segue.destination as! ReportViewController
        let row = sender as! Int
        reportViewController.displayType = displayType
        reportViewController.color = CategorySpendColor.colorArray[row]
        reportViewController.categoryName = displayReportsArray[row].categoryName
        reportViewController.displayCategoryName = displayReportsArray[row].categoryName
        reportViewController.startDate = startDate
        reportViewController.endDate = endDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToGraph(segue: UIStoryboardSegue){
    }
    
    func buttonTap(_ button: UIButton) {
        if button.isSelected{
            button.isSelected = false
            specialGraphBool = false
            allGraphBool = false
            loadAllData()
        }else{
            specialTermGraphView = SpecialTermGraphView()
            specialTermGraphView.frame.size = CGSize(width: 300, height: 300)
            specialTermGraphView.center = self.view.center
            specialTermGraphView.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            specialTermGraphView.OKButton.addTarget(self, action: #selector(specifyGraphSetting), for: .touchUpInside)
            specialTermGraphView.cornerLayout(.collectionView)
            self.view.addSubview(backView)
            self.view.addSubview(specialTermGraphView)
        }
    }
    
    @objc func cancel(){
        backView.removeFromSuperview()
    }
    
    @objc func specifyGraphSetting(){
        if specialTermGraphView.allTermButton.isSelected{
            allGraphBool = true
            specialGraphBool = false
        }else{
            specialGraphBool = true
            allGraphBool = false
            let year = specialTermGraphView.yearMonthPickerView.selectedRow(inComponent: 0)
            let month = specialTermGraphView.yearMonthPickerView.selectedRow(inComponent: 1)
            var term = 1
            for i in 0 ..< specialTermGraphView.specifyTermButtonArray.count{
                let button = specialTermGraphView.specifyTermButtonArray[i]
                if button.isSelected{
                    term = specialTermGraphView.specifyTermIntArray[i]
                    break
                }
            }
            termTuple = (year: year, month: month, term: term)
        }
        loadAllData()
        specialTermGraphView.removeFromSuperview()
        backView.removeFromSuperview()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
