//
//  TermItemViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/07.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class TermItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var admobView: UIView!
    
    var bannerView: GADBannerView!
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

    let methods = Methods().self
    var array: [InputSchedule] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
        
        let nib = UINib(nibName: "TermItemTableViewCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "item")
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        admobView.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        array = methods.loadInputSchedule()
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "item") as! TermItemTableViewCell
        cell.setting(array[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "edit", sender: array[indexPath.row])
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

        let delete = array[row]
        context.delete(delete)
        
        array.remove(at: row)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit"{
            let termVC: TermViewController = segue.destination as! TermViewController
            termVC.editBool = true
            termVC.editInputSchedule = sender as! InputSchedule
        }
    }
    
    @IBAction func unwindToTermItem(segue: UIStoryboardSegue){
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
