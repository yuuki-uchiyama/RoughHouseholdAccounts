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
    
    var type = 0
    var colorRow: Int!
    var categoryName: String!
    var startDay: NSDate!
    var endDay: NSDate!
    var termBool: Bool!
    var array: [CategoryReport] = []
    var SRArray: [SpendReport] = []
    var IRArray: [IncomeReport] = []
    var totalAmount = 0
    
    var formatter = DateFormatter()
    var rangeDic: [String:Int] = ["より少ない":-2, "よりちょっと少ない":-1, "くらい":0, "よりちょっと多い":1, "より多い":2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate.persistentContainer.viewContext
        
        let nib =  UINib(nibName: "ReportTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "report")
        tableView.dataSource = self
        tableView.delegate = self
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        admobView.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReportFromiCroud()
        tableView.reloadData()
        
        titleNavigation.title = "\(categoryName!)(総額：\(totalAmount)円)"

    }
    
    func loadReportFromiCroud(){
        totalAmount = 0
        SRArray = []
        IRArray = []
        array = []
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        var predicate: NSPredicate!
        if type == 0{
            let spendFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
            spendFetch.sortDescriptors = [sortDescriptor]
            if termBool{
                predicate = NSPredicate(format:"(date >= %@) AND (date <= %@) AND (category == %@)",startDay,endDay,categoryName)
            }else{
                predicate = NSPredicate(format:"(category == %@)",categoryName)
            }
            spendFetch.predicate = predicate
            SRArray = try! context.fetch(spendFetch)
            for report in SRArray{
                let record = CategoryReport(report.date!, Int(report.amount),report.rangeString!, Int(report.range))
                totalAmount += record.amount
                array.append(record)
            }
        }else{
            let incomeFetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
            incomeFetch.sortDescriptors = [sortDescriptor]
            if termBool{
                predicate = NSPredicate(format:"(date >= %@) AND (date <= %@) AND (category == %@)",startDay,endDay,categoryName)
            }else{
                predicate = NSPredicate(format:"(category == %@)",categoryName)
            }
            incomeFetch.predicate = predicate
            IRArray = try! context.fetch(incomeFetch)
            for report in IRArray{
                let record = CategoryReport(report.date!, Int(report.amount),report.rangeString!, Int(report.range))
                totalAmount += record.amount
                array.append(record)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "report", for: indexPath) as! ReportTableViewCell
        let categoryReport = array[indexPath.row]
        
        let date = categoryReport.date
        let amount = categoryReport.amount
        let rangeString = categoryReport.rangeString
        let range = categoryReport.range
        var percent: Double = 0.0
        if totalAmount != 0{
            percent = round(Double(amount) / Double(totalAmount) * 1000.0) / 10
        }
        
        cell.setting(colorRow, date, amount, rangeString, range, percent)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == 0{
            performSegue(withIdentifier: "editSpend", sender: SRArray[indexPath.row])
        }else{
            performSegue(withIdentifier: "editIncome", sender: IRArray[indexPath.row])
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

        if type == 0{
            let delete = SRArray[row]
                context.delete(delete)
        }else{
            let delete = IRArray[row]
            context.delete(delete)
        }
        array.remove(at: row)
        loadReportFromiCroud()
        titleNavigation.title = "\(categoryName!)(総額：\(totalAmount)円)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSpend"{
            let spendVC: SpendViewController = segue.destination as! SpendViewController
            spendVC.editBool = true
            spendVC.editSR = sender as! SpendReport
        }else if segue.identifier == "editIncome"{
            let incomeVC: IncomeViewController = segue.destination as! IncomeViewController
            incomeVC.editBool = true
            incomeVC.editIR = sender as! IncomeReport
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
