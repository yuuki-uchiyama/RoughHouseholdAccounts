//
//  TabBarController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/07/31.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController
import CoreData
import GoogleMobileAds



class TabBarController: RAMAnimatedTabBarController {
    
    var bannerView: GADBannerView!
    var testBannerBool = true
    
    var spendClassArray = ["食費", "交通費", "医療", "日用品", "項目その1", "項目その2", "項目その3", "項目その4", "項目その5", "その他"]
    var incomeClassArray = ["給与", "臨時収入", "賞与", "お小遣い", "副業", "その他"]
    
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let methods = Methods().self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let spendCategoryFetch: NSFetchRequest<SpendCategory> = SpendCategory.fetchRequest()
        let spendCategoryResults = try! context.fetch(spendCategoryFetch)
        if spendCategoryResults.count == 0{
            print("カテゴリ設定開始")
            var entity = NSEntityDescription.entity(forEntityName: Const.spendCategory, in: context)!
            for i in 0 ..< 10{
                let category = NSManagedObject(entity: entity, insertInto: context)
                category.setValue(i, forKeyPath: Const.categoryNum)
                category.setValue(spendClassArray[i], forKeyPath: Const.categoryName)
                do{
                    try context.save()
                }catch{
                }
            }
            entity = NSEntityDescription.entity(forEntityName: Const.incomeCategory, in: context)!
            for i in 0 ..< 6{
                let category = NSManagedObject(entity: entity, insertInto: context)
                if i == 5{
                    category.setValue(9, forKey: Const.categoryNum)
                }else{
                    category.setValue(i, forKeyPath: Const.categoryNum)
                }
                category.setValue(incomeClassArray[i], forKeyPath: Const.categoryName)
                try! context.save()
            }
        }
        let settings = methods.loadSetting()
        UserDefaults.standard.set(settings.initialization, forKey: Const.initialization)
        UserDefaults.standard.set(settings.separateDay, forKey: Const.separateDay)
        
        if !UserDefaults.standard.bool(forKey: Const.updateTo2){
            
        }
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
