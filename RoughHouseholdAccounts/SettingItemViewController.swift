//
//  SettingItemViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/07.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD
import GoogleMobileAds

class SettingItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var titleNavi: UINavigationItem!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var keyboardLayout: NSLayoutConstraint!
    @IBOutlet weak var admobView: UIView!
    
    var bannerView: GADBannerView!
    var rectangleBannerView: GADBannerView!

    var type: String!
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    var SCResults:[SpendCategory] = []
    var ICResults:[IncomeCategory] = []
    var categoryTitleArray:[String] = []
    
    var scrollLenge: CGFloat = 0.0
    var tapGesture: UITapGestureRecognizer!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate.persistentContainer.viewContext

        loadCategory()
        if type == "spend"{
            titleNavi.title = "支出項目"
        }else{
            titleNavi.title = "収入項目"
        }
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.isEditing = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
        tapGesture = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false
        
        SVProgressHUD.setMinimumDismissTimeInterval(0)
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        admobView.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3240594386716005/9516385182"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "categoryItem", for: indexPath)
            let category = categoryTitleArray[indexPath.row]
            cell.textLabel?.text = category

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryName = tableView.cellForRow(at: indexPath)?.textLabel?.text
        let alertController: UIAlertController = UIAlertController(title: categoryName, message: "カテゴリ名変更", preferredStyle: .alert)
        let yes = UIAlertAction(title: "変更", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            let textFields:Array<UITextField>? =  alertController.textFields as Array<UITextField>?
            if let newCategoryName = textFields![0].text{
                self.categoryTableView.cellForRow(at: indexPath)?.textLabel?.text = newCategoryName
                self.editCategory(indexPath.row, newCategoryName)
            }
        })
        let no = UIAlertAction(title: "キャンセル", style: .cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.resignFirstResponder()
        })
        
        alertController.addAction(yes)
        alertController.addAction(no)
        
        alertController.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.text = categoryName
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            self.deleteCategory(indexPath.row)
        }
        deleteButton.backgroundColor = UIColor.red

        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let targetCategory = categoryTitleArray[sourceIndexPath.row]
        if let index = categoryTitleArray.index(of: targetCategory) {
                categoryTitleArray.remove(at: index)
                categoryTitleArray.insert(targetCategory, at: destinationIndexPath.row)
        }
        numberUpdate()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "削除") { (action, sourceView, completionHandler) in
            completionHandler(true)
            self.deleteCategory(indexPath.row)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
//    データ更新・消去
    func deleteCategory(_ row:Int){
        if type == "spend"{
            let delete = SCResults[row]
            changeReports(delete.categoryName!)
            context.delete(delete)
        }else{
            let delete = ICResults[row]
            changeReports(delete.categoryName!)
            context.delete(delete)
        }
        categoryTitleArray.remove(at: row)
        numberUpdate()
    }
    
    func changeReports(_ category:String){
        if type == "spend"{
            let editSpendFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
            let predicate = NSPredicate(format:"(category == %@)",category)
            editSpendFetch.predicate = predicate
            let spendReportArray = try! context.fetch(editSpendFetch)
            for SR in spendReportArray{
                SR.category = "その他"
            }
        }else{
            let editIncomeFetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
            let predicate = NSPredicate(format:"(category == %@)",category)
            editIncomeFetch.predicate = predicate
            let incomeReportArray = try! context.fetch(editIncomeFetch)
            for IR in incomeReportArray{
                IR.category = "その他"
            }
        }
        let editScheduleFetch: NSFetchRequest<InputSchedule> = InputSchedule.fetchRequest()
        let predicate = NSPredicate(format:"(category == %@)",category)
        editScheduleFetch.predicate = predicate
        let inputScheduleArray = try! context.fetch(editScheduleFetch)
        for IS in inputScheduleArray{
            IS.category = "その他"
        }
        try! context.save()
    }
    
    func editCategory(_ row:Int,_ categoryName:String){
        categoryTitleArray[row] = categoryName
        if type == "spend"{
            let SC = SCResults[row]
            let editSpendFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
            let predicate = NSPredicate(format:"(category == %@)",SC.categoryName!)
            editSpendFetch.predicate = predicate
            let spendReportArray = try! context.fetch(editSpendFetch)
            
            SC.categoryName = categoryName
            for SR in spendReportArray{
                SR.category = categoryName
            }
        }else{
            let IC = ICResults[row]
            let editIncomeFetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
            let predicate = NSPredicate(format:"(category == %@)",IC.categoryName!)
            editIncomeFetch.predicate = predicate
            let incomeReportArray = try! context.fetch(editIncomeFetch)
            
            IC.categoryName = categoryName
            for IR in incomeReportArray{
                IR.category = categoryName
            }
            print(IC.categoryName!)
        }
        try! context.save()
    }
    
    func numberUpdate(){
        if type == "spend"{
            for i in 0 ..< categoryTitleArray.count{
                print(i)
                let targetCategory = categoryTitleArray[i]
                let SCFetch: NSFetchRequest<SpendCategory> = SpendCategory.fetchRequest()
                let predicate = NSPredicate(format:"(categoryName == %@)",targetCategory)
                SCFetch.predicate = predicate
                let SCArray = try! context.fetch(SCFetch)
                SCArray[0].number = Int16(i)
                print(SCArray[0].categoryName!)
                print(SCArray[0].number)
            }
        }else{
            for i in 0 ..< categoryTitleArray.count{
                let targetCategory = categoryTitleArray[i]
                let ICFetch: NSFetchRequest<IncomeCategory> = IncomeCategory.fetchRequest()
                let predicate = NSPredicate(format:"(categoryName == %@)",targetCategory)
                ICFetch.predicate = predicate
                let ICArray = try! context.fetch(ICFetch)
                ICArray[0].number = Int16(i)
            }
        }
        try! context.save()
        loadCategory()
    }
    
//    テキストフィールドのせり上がり設定
    @objc func keyboardWillBeShown(notification:NSNotification) {
        if textField.isEditing{
        if let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            print(keyboardFrame.origin.y)
            scrollLenge = keyboardFrame.height
            if scrollLenge > keyboardLayout.constant{
                keyboardLayout.constant += scrollLenge
                
                UIView.animate(withDuration: 0.5, animations:{ self.view.layoutIfNeeded()})
            }
        }
        }
        tapGesture.isEnabled = true
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
        if  scrollLenge != 0.0{
            keyboardLayout.constant -= scrollLenge
            UIView.animate(withDuration: 0.5, animations:{ self.view.layoutIfNeeded()})
            scrollLenge = 0.0
        }
        tapGesture.isEnabled = false
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let newCategory = textField.text
//        同カテゴリや空白の確認
        if newCategory != ""{
            if categoryTitleArray.count >= 9{
                SVProgressHUD.showError(withStatus: "項目は9個までしか作成できません")
            }else if (newCategory?.count)! > 7{
                SVProgressHUD.showError(withStatus: "項目は7文字以内にしてください")
            }else{
                if newCategory == "その他" || newCategory == "そのほか"{
                    SVProgressHUD.showError(withStatus: "「その他」カテゴリは既に存在します")
                }else{
                var sameCategoryBool = false
                for category in categoryTitleArray{
                    if category == newCategory{
                        sameCategoryBool = true
                        break
                    }
                }
                if sameCategoryBool{
                    SVProgressHUD.showError(withStatus: "同じ項目があります")
                }else{
//                    入力開始
                    if type == "spend"{
                        let entity = NSEntityDescription.entity(forEntityName: Const.spendCategory, in: context)!
                        let spendCategory = NSManagedObject(entity: entity, insertInto: context)
                        spendCategory.setValue(Int16(SCResults.count - 1), forKey:Const.categoryNum)
                        spendCategory.setValue(textField.text, forKey: Const.categoryName)
                    }else{
                        let entity = NSEntityDescription.entity(forEntityName: Const.incomeCategory, in: context)!
                        let incomeCategory = NSManagedObject(entity: entity, insertInto: context)
                        incomeCategory.setValue(Int16(ICResults.count - 1), forKey:Const.categoryNum)
                        incomeCategory.setValue(textField.text, forKey: Const.categoryName)
                    }
                    try! context.save()
                    textField.text = ""
                    loadCategory()
                    }
                }
            }
        }
    }
    

    @IBAction func editButton(_ sender: UIBarButtonItem) {
        if self.categoryTableView.isEditing{
            categoryTableView.isEditing = false
            sender.title = "編集"
        }else{
            categoryTableView.isEditing = true
            sender.title = "完了"
        }
    }
    
    func loadCategory(){
        categoryTitleArray = []
        if type == "spend"{
            SCResults = []
            let SCFetch: NSFetchRequest<SpendCategory> = SpendCategory.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: Const.categoryNum, ascending: true)
            SCFetch.sortDescriptors = [sortDescriptor]
            SCResults = try! context.fetch(SCFetch)
            for i in 0 ..< (SCResults.count - 1){
                if let a = SCResults[i].categoryName{
                    categoryTitleArray.append(a)
                }
            }
        }else{
            ICResults = []
            let ICFetch: NSFetchRequest<IncomeCategory> = IncomeCategory.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: Const.categoryNum, ascending: true)
            ICFetch.sortDescriptors = [sortDescriptor]
            ICResults = try! context.fetch(ICFetch)
            for i in 0 ..< (ICResults.count - 1){
                if let a = ICResults[i].categoryName{
                    categoryTitleArray.append(a)
                }
            }
        }
        categoryTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
