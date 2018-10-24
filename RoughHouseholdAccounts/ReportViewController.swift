//
//  GraphItemViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/07.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//


import UIKit
import CoreData
import GoogleMobileAds

class ReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleNavigation: UINavigationItem!
    @IBOutlet weak var cancelItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var admobView: UIView!
    
    var bannerView: GADBannerView!
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    var methods: Methods!
    
    var displayType = 0
    var color: UIColor!
    var categoryName: String?
    var displayCategoryName: String!
    var displayTerm:String!
    var startDate: NSDate!
    var endDate: NSDate!
    var totalReportData: TotalReportData!
    var allReportBool = false
    
    
    var formatter = DateFormatter()
    var rangeDic: [String:Int] = ["より少ない":-2, "よりちょっと少ない":-1, "ピッタリ":0, "よりちょっと多い":1, "より多い":2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate.persistentContainer.viewContext
        methods = Methods()
        
        let nib =  UINib(nibName: "ReportTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "report")
        tableView.dataSource = self
        tableView.delegate = self
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        admobView.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3240594386716005/9516385182"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReportFromiCroud()
        tableView.reloadData()
        
        if allReportBool{
            titleNavigation.title = "\(displayCategoryName!)(\(totalReportData.totalAmount)円)"
        }else{
            titleNavigation.title = "\(displayCategoryName!)(総額：\(totalReportData.totalAmount)円)"
        }
    }
    
    func loadReportFromiCroud(){

        totalReportData = TotalReportData(displayCategoryName)
        
        if allReportBool{
            let spendReportArray = methods.loadSpendReport(startDate, endDate, categoryName)
            let incomeReportArray = methods.loadIncomeReport(startDate, endDate, categoryName)
            for report in spendReportArray{
                let reportData = ReportData()
                reportData.castFromSpendReport(report)
                totalReportData.spendIncomeAppend(reportData)
            }
            for report in incomeReportArray{
                let reportData = ReportData()
                reportData.castFromIncomeReport(report)
                totalReportData.spendIncomeAppend(reportData)
            }
            totalReportData.array.sort()
        }else{
            switch displayType {
            case 0:
                let reportArray = methods.loadSpendReport(startDate, endDate, categoryName)
                for report in reportArray{
                    let reportData = ReportData()
                    reportData.castFromSpendReport(report)
                    totalReportData.append(reportData)
                }
            case 1:
                let reportArray = methods.loadIncomeReport(startDate, endDate, categoryName)
                for report in reportArray{
                    let reportData = ReportData()
                    reportData.castFromIncomeReport(report)
                    totalReportData.append(reportData)
                }
            case 2:
                let reportArray = methods.loadWasteSpendReport(startDate, endDate, categoryName)
                for report in reportArray{
                    let reportData = ReportData()
                    reportData.castFromSpendReport(report)
                    totalReportData.append(reportData)
                }
            default:break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalReportData.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "report", for: indexPath) as! ReportTableViewCell
        let reportData = totalReportData.array[indexPath.row]
        
        let date = reportData.date!
        let wasteBool = reportData.wasteBool!
        
        var amount: Int!
        var rangeString: String!
        var range:Int!
        var percent: Double!

        if allReportBool{
            if reportData.type == 1{
                let incomeColor = UIColor.flatGray
                amount = reportData.amount!
                rangeString = reportData.rangeString!
                range = reportData.range!
                if totalReportData.totalAmount != 0{
                    percent = round(Double(amount) / Double(totalReportData.totalIncome + totalReportData.totalSpend) * 1000.0) / 10 / 2
                }
                cell.setting(leftColor: nil, rightColor: incomeColor, date, amount, rangeString, range, percent, wasteBool)
            }else{
                let spendColor = UIColor.flatRed
                amount = reportData.amount! * -1
                rangeString = reportData.rangeString!
                range = reportData.range! * -1
                if totalReportData.totalAmount != 0{
                    percent = round(Double(reportData.amount!) / Double(totalReportData.totalIncome + totalReportData.totalSpend) * 1000.0) / 10 / 2
                }
                cell.setting(leftColor: spendColor, rightColor: nil, date, amount, rangeString, range, percent, wasteBool)
            }
        }else{
            amount = reportData.amount!
            rangeString = reportData.rangeString!
            range = reportData.range!
            if totalReportData.totalAmount != 0{
                percent = round(Double(amount) / Double(totalReportData.totalAmount) * 1000.0) / 10
            }
            cell.setting(leftColor: color, rightColor: nil, date, amount, rangeString, range, percent, wasteBool)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reportData = totalReportData.array[indexPath.row]
        let report = reportData.originalData
        if allReportBool{
            if reportData.type == 1{
                performSegue(withIdentifier: "editIncome", sender: report)
            }else{
                performSegue(withIdentifier: "editSpend", sender: report)
            }
        }else{
            if displayType == 1{
                performSegue(withIdentifier: "editIncome", sender: report)
            }else{
                performSegue(withIdentifier: "editSpend", sender: report)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            self.deleteReport(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
        deleteButton.backgroundColor = UIColor.red
        
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "削除") { (action, sourceView, completionHandler) in
            completionHandler(true)
            self.deleteReport(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func deleteReport(_ row:Int){
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext

        if displayType == 1{
            let delete = totalReportData.array[row].originalData as! IncomeReport
                context.delete(delete)
        }else{
            let delete = totalReportData.array[row].originalData as! SpendReport
            context.delete(delete)
        }
        totalReportData.array.remove(at: row)
        loadReportFromiCroud()
        
        if allReportBool{
            titleNavigation.title = "\(displayCategoryName!)(\(totalReportData.totalAmount)円)"
        }else{
            titleNavigation.title = "\(displayCategoryName!)(総額：\(totalReportData.totalAmount)円)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSpend"{
            let spendVC: SpendViewController = segue.destination as! SpendViewController
            spendVC.editBool = true
            spendVC.editSR = sender as? SpendReport
        }else if segue.identifier == "editIncome"{
            let incomeVC: IncomeViewController = segue.destination as! IncomeViewController
            incomeVC.editBool = true
            incomeVC.editIR = sender as? IncomeReport
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwintToReport(segue:UIStoryboardSegue){
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
