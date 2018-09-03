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

class CategoryReport{
    var date: Date
    var amount: Int
    var rangeString: String
    var range: Int
    
    init(_ itemDate:Date, _ itemAmount:Int, _ itemRangeString:String, _ itemRange:Int){
        date = itemDate
        amount = itemAmount
        rangeString = itemRangeString
        range = itemRange
    }
}
class CategoryReports{
    var categoryName: String
    var array:[CategoryReport] = []
    var totalAmount: Int = 0
    var totalRange: Int = 0
    
    init(_ name:String){
        categoryName = name
    }
    
    func append(_ record:CategoryReport){
        array.append(record)
        totalAmount += record.amount
        totalRange += record.range
    }
}

class GraphViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate {
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var backGroundColorView: UIView!
    @IBOutlet weak var spendIncomeControl: UISegmentedControl!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allIncomeView: UIView!
    @IBOutlet weak var allIncomeLabel: UILabel!
    @IBOutlet weak var allSpendView: UIView!
    @IBOutlet weak var allSpendLabel: UILabel!
    
//    上部バー関係
    var segmentedControl: HMSegmentedControl!
    var sectionTitles: [String] = []
    var colorDic: [Int:UIColor] = [1:MonthColor.JanColor, 2:MonthColor.FebColor, 3:MonthColor.MarColor, 4:MonthColor.AprColor, 5:MonthColor.MayColor, 6:MonthColor.JunColor, 7:MonthColor.JulColor, 8:MonthColor.AugColor, 9:MonthColor.SepColor, 10:MonthColor.OctColor, 11:MonthColor.NovColor, 0:MonthColor.DecColor]
    var colorNum = 0
    
//    支出/収入のsegmentedControl関係
    var display = 0
    var displayNameArray: [String] = []
    var displayRecordsArray: [CategoryReports] = []
    var denominator:Double = 0
    
//    カテゴリ関係
    var SCategoryNameArray: [String] = []
    var SCategoryRecordsArray: [CategoryReports] = []
    var ICategoryNameArray: [String] = []
    var ICategoryRecordsArray: [CategoryReports] = []
    
//    データ取り出し関係
    var context:NSManagedObjectContext!

    let date = Date()
    let calendar = Calendar.current
    var startYear = 2018
    var startMonth = 1
    var endDay = NSDate()
    var startDay = NSDate()
    var termBool = true
    var label: UILabel!
    var selectedMonth = 0
    var separateDay: Int = 28
    var spendReportArray : [SpendReport] = []
    var incomeReportArray: [IncomeReport] = []
    
//    総額
    var allSpend = 0
    var allSpendRange = 0
    var allIncome = 0
    var allIncomeRange = 0
    
//    円グラフ
    let pieChartAttributedDic: [NSAttributedStringKey : UIFont] = [
        .font : UIFont(name: "Hiragino Maru Gothic ProN", size: 18)!
    ]
    var dataEntries = [PieChartDataEntry]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let settingsFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let setting = try! context.fetch(settingsFetch)[0]
        separateDay = Int(setting.separateDay)
        
        changeSegmendControl()

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
        
        allIncomeView.layer.borderWidth = 3.0
        allIncomeView.layer.borderColor = UIColor.flatBlack.cgColor
        allSpendView.layer.borderWidth = 3.0
        allSpendView.layer.borderColor = UIColor.flatRed.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let settingsFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let setting = try! context.fetch(settingsFetch)[0]
        if separateDay != Int(setting.separateDay){
            separateDay = Int(setting.separateDay)
            segmentedControl.removeFromSuperview()
            changeSegmendControl()
        }

        
        loadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        segmentedControl.frame = tabView.frame
        colorChange(colorNum)
    }
    
    func loadData(){
        loadCategoryFromiCloud()
        termAdjust()
        loadReportFromiCloud()
        choiceData()
    }
    
    func changeSegmendControl(){
        sectionTitles.removeAll()
        startYear = calendar.component(.year, from: date)
        startMonth = calendar.component(.month, from: date)
        if calendar.component(.day, from: date) > separateDay{
            startMonth += 1
            if startMonth > 12{
                startYear += 1
                startMonth -= 12
            }
        }
        colorNum = startMonth
        sectionTitles.append("\(startYear)年\(startMonth)月")
        for _ in 0 ... 23{
            if startMonth != 1{
                startMonth -= 1
                sectionTitles.append(" \(startMonth)月　　　")
            }else{
                startMonth = 12
                startYear -= 1
                sectionTitles.append("\(startYear)年\(startMonth)月")
            }
        }
        segmentedControl = HMSegmentedControl.init(frame: tabView.frame)
        segmentedControl.sectionTitles = sectionTitles
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyle.box
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.down
        segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyle.dynamic
        let chengeGraph :IndexChangeBlock = {(index:Int) -> Void in
            print(index)
            self.termBool = true
            self.selectedMonth = index
            var a = self.selectedMonth
            if self.colorNum < a{
                a -= 12
                if self.colorNum < a{
                    a -= 12
                }
            }
            let num = (self.colorNum - a) % 12
            self.colorChange(num)
            self.loadData()
        }
        segmentedControl.indexChangeBlock = chengeGraph
        self.view.addSubview(segmentedControl)
    }
    
    func colorChange(_ sender:Int){
        backGroundColorView.backgroundColor = colorDic[sender]
        self.segmentedControl.selectionIndicatorColor = self.colorDic[sender]
        self.segmentedControl.selectionIndicatorBoxColor = self.colorDic[sender]
    }
    
//    円グラフのデータ更新
    func editPieChart(){
        dataEntries = []
        for records in displayRecordsArray{
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
            return displayRecordsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! CategoryReportTableViewCell
        
        let records = displayRecordsArray[indexPath.row]
        let categoryName = records.categoryName
        let categorySpend = records.totalAmount
        let categoryRange = records.totalRange + records.totalAmount
        

        var percent: Double = 0.0
        var rangePercent: Double = 0.0
        if denominator != 0{
            percent = round(Double(categorySpend) / denominator * 1000.0) / 10
            rangePercent = round(Double(records.totalRange) / denominator * 1000.0) / 10
        }
        
        cell.setting(indexPath.row, categoryName, categorySpend, categoryRange, percent, rangePercent)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "report", sender: indexPath.row)
    }
    
//    グラフに表示する項目の設定(segmentedControl)
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        display = sender.selectedSegmentIndex
        choiceData()
    }
    
    @IBAction func totalButton(_ sender: UIButton) {
        if termBool{
            termBool = false
            segmentedControl.isHidden = true
            sender.setTitle("月毎", for: .normal)
            label = UILabel(frame: tabView.frame)
            label.text = "今までの累計記録"
            label.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 18 )
            label.textAlignment = NSTextAlignment.center
            self.view.addSubview(label)
        }else{
            termBool = true
            segmentedControl.isHidden = false
            sender.setTitle("総計", for: .normal)
            if (label) != nil{
                label.removeFromSuperview()
            }
        }
        loadData()
    }
    
    
//    期間の設定
    func termAdjust(){
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        if selectedMonth >= month + 12{
            year -= 2
            month += 24 - selectedMonth
        }else if selectedMonth >= month{
            year -= 1
            month += 12 - selectedMonth
        }else{
            month -= selectedMonth
        }
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        if separateDay == 28{
            startDay = dateFormater.date(from: "\(year)/\(month)/01 00:00:00")! as NSDate
            //        月末が何日かを計算
            let add = DateComponents(month: 1, day: -1)
            let last = calendar.date(byAdding: add, to: startDay as Date)!
            let lastDay = calendar.component(.day, from: last)
            
            endDay = dateFormater.date(from: "\(year)/\(month)/\(lastDay) 23:59:59")! as NSDate
        }else{
            endDay = calendar.date(from: DateComponents(year: year, month: month, day: separateDay, hour:23, minute: 59, second: 59))! as NSDate
            
            if month == 1{
                year -= 1
                month = 12
            }else{
                month -= 1
            }
            
            startDay = Calendar.current.date(from: DateComponents(year: year, month: month, day: separateDay + 1, hour:0, minute: 0, second: 0))! as NSDate
        }
    }
    
//    データ読み込み関係
//    カテゴリ読み込み
    func loadCategoryFromiCloud(){
        SCategoryRecordsArray = []
        ICategoryRecordsArray = []
        
        let methods = Methods().self
            SCategoryNameArray = methods.loadSpendCategory()
            ICategoryNameArray = methods.loadIncomeCategory()
        
        for category in SCategoryNameArray{
            let a = CategoryReports(category)
            SCategoryRecordsArray.append(a)
        }
        for category in ICategoryNameArray{
            let a = CategoryReports(category)
            ICategoryRecordsArray.append(a)
        }
    }
    
//    記録読み込み
    func loadReportFromiCloud(){
        allSpend = 0
        allSpendRange = 0
        allIncome = 0
        allIncomeRange = 0
        
        
        let spendFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
        let incomeFetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        spendFetch.sortDescriptors = [sortDescriptor]
        incomeFetch.sortDescriptors = [sortDescriptor]
        if termBool{
        let predicate = NSPredicate(format:"(date >= %@) AND (date <= %@)",startDay,endDay)
        spendFetch.predicate = predicate
        incomeFetch.predicate = predicate
        }
        spendReportArray = try! context.fetch(spendFetch)
        incomeReportArray = try! context.fetch(incomeFetch)
        for report in spendReportArray{
            let record = CategoryReport(report.date!, Int(report.amount),report.rangeString!, Int(report.range))
            switch report.category{
            case SCategoryNameArray[0]:
                SCategoryRecordsArray[0].append(record)
            case SCategoryNameArray[1]:
                SCategoryRecordsArray[1].append(record)
            case SCategoryNameArray[2]:
                SCategoryRecordsArray[2].append(record)
            case SCategoryNameArray[3]:
                SCategoryRecordsArray[3].append(record)
            case SCategoryNameArray[4]:
                SCategoryRecordsArray[4].append(record)
            case SCategoryNameArray[5]:
                SCategoryRecordsArray[5].append(record)
            case SCategoryNameArray[6]:
                SCategoryRecordsArray[6].append(record)
            case SCategoryNameArray[7]:
                SCategoryRecordsArray[7].append(record)
            case SCategoryNameArray[8]:
                SCategoryRecordsArray[8].append(record)
            case SCategoryNameArray[9]:
                SCategoryRecordsArray[9].append(record)
            default:
                break
            }
        }
        for i in 0 ..< SCategoryRecordsArray.count{
            allSpend += SCategoryRecordsArray[i].totalAmount
            allSpendRange += SCategoryRecordsArray[i].totalRange
        }
        
        for report in incomeReportArray{
            let record = CategoryReport(report.date!, Int(report.amount),report.rangeString!, Int(report.range))
            switch report.category{
            case ICategoryNameArray[0]:
                ICategoryRecordsArray[0].append(record)
            case ICategoryNameArray[1]:
                ICategoryRecordsArray[1].append(record)
            case ICategoryNameArray[2]:
                ICategoryRecordsArray[2].append(record)
            case ICategoryNameArray[3]:
                ICategoryRecordsArray[3].append(record)
            case ICategoryNameArray[4]:
                ICategoryRecordsArray[4].append(record)
            case ICategoryNameArray[5]:
                ICategoryRecordsArray[5].append(record)
            case ICategoryNameArray[6]:
                ICategoryRecordsArray[6].append(record)
            case ICategoryNameArray[7]:
                ICategoryRecordsArray[7].append(record)
            case ICategoryNameArray[8]:
                ICategoryRecordsArray[8].append(record)
            case ICategoryNameArray[9]:
                ICategoryRecordsArray[9].append(record)
            default:
                break
            }
        }
        for i in 0 ..< ICategoryRecordsArray.count{
            allIncome += ICategoryRecordsArray[i].totalAmount
            allIncomeRange += ICategoryRecordsArray[i].totalRange
        }
        allIncomeLabel.text = "\(allIncome)円"
        allSpendLabel.text = "\(allSpend)円"
    }
    
    func choiceData(){
        if display == 0{
            displayNameArray = SCategoryNameArray
            displayRecordsArray = SCategoryRecordsArray
            denominator = Double(allSpend)
        }else{
            displayNameArray = ICategoryNameArray
            displayRecordsArray = ICategoryRecordsArray
            denominator = Double(allIncome)
        }
        editPieChart()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let reportViewController: ReportViewController = segue.destination as! ReportViewController
        let row = sender as! Int
        let category = displayRecordsArray[row].categoryName
        reportViewController.type = display
        reportViewController.colorRow = row
        reportViewController.categoryName = category
        reportViewController.startDay = startDay
        reportViewController.endDay = endDay
        reportViewController.termBool = termBool
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
