//
//  Methods.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/23.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import GoogleMobileAds

class Methods{
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func loadSpendCategory() -> [String]{
        var stringArray: [String] = []
        
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let categoryFetch: NSFetchRequest<SpendCategory> = SpendCategory.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Const.categoryNum, ascending: true)
        categoryFetch.sortDescriptors = [sortDescriptor]
        
        let results = try! context.fetch(categoryFetch)
        for category in results{
            stringArray.append(category.categoryName!)
        }
        return stringArray
    }
    
    func loadIncomeCategory() -> [String]{
        var stringArray: [String] = []
        
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let categoryFetch: NSFetchRequest<IncomeCategory> = IncomeCategory.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Const.categoryNum, ascending: true)
        categoryFetch.sortDescriptors = [sortDescriptor]
        
        let results = try! context.fetch(categoryFetch)
        for category in results{
            stringArray.append(category.categoryName!)
        }
        return stringArray
    }
    
    func loadInputSchedule() -> [InputSchedule]{
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let categoryFetch: NSFetchRequest<InputSchedule> = InputSchedule.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Const.categoryNum, ascending: true)
        categoryFetch.sortDescriptors = [sortDescriptor]
        
        let array: [InputSchedule] = try! context.fetch(categoryFetch)
        
        return array
    }
    
    func loadSetting() -> Settings {
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let categoryFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        
        var settingsArray: [Settings] = try! context.fetch(categoryFetch)
        if settingsArray.count == 0{
            let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)!
            let settings = NSManagedObject(entity: entity, insertInto: context)
            settings.setValue(true, forKeyPath: "initialization")
            settings.setValue(28, forKeyPath: "separateDay")
            try! context.save()
            
            settingsArray = try! context.fetch(categoryFetch)
        }
        
        return settingsArray[0]
    }
    
    func rangeCalculate(_ amount:Int,_ selectedRange:Int, _ rangeSetting:Double) -> Int{
        let range = Double(selectedRange) * rangeSetting
        
        var detailsOfAmount = 0.0
        if amount % 10000 == 0{
            detailsOfAmount = 6.0
        }else if amount % 1000 == 0{
            detailsOfAmount = 4.0
        }else if amount % 100 == 0{
            detailsOfAmount = 2.0
        }else{
            detailsOfAmount = 1.0
        }
        
        let amountOf100 = amount % 1000
        let amountOf10000 = (amount - amountOf100) % 100000
        let amountMore100000 = amount - amountOf100 - amountOf10000
        
        let rangeAmountOf100 = Double(amountOf100) * (0.10 * detailsOfAmount * range)
        let rangeAmountOf10000 = Double(amountOf10000) * (0.02 * detailsOfAmount * range)
        let rangeAmountMore100000 = Double(amountMore100000) * (0.01 * detailsOfAmount * range)
        
        let rangeAmount = Int(round(rangeAmountOf100 + rangeAmountOf10000 + rangeAmountMore100000))
        
        return rangeAmount
    }
    
    func allDelete(){
        print("データ削除開始")
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let deleteSpendFetch: NSFetchRequest<SpendCategory> = SpendCategory.fetchRequest()
        let deleteSpendResults = try! context.fetch(deleteSpendFetch)
        for i in 0 ..< deleteSpendResults.count{
            let deleteObject = deleteSpendResults[i] as SpendCategory
            context.delete(deleteObject)
        }
        let deleteIncomeFetch: NSFetchRequest<IncomeCategory> = IncomeCategory.fetchRequest()
        let deleteIncomeResults = try! context.fetch(deleteIncomeFetch)
        for i in 0 ..< deleteIncomeResults.count{
            let deleteObject = deleteIncomeResults[i] as IncomeCategory
            context.delete(deleteObject)
        }
        let deleteSRFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
        let deleteSRResults = try! context.fetch(deleteSRFetch)
        for i in 0 ..< deleteSRResults.count{
            let deleteObject = deleteSRResults[i] as SpendReport
            context.delete(deleteObject)
        }
        let deleteIRFetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
        let deleteIRResults = try! context.fetch(deleteIRFetch)
        for i in 0 ..< deleteIRResults.count{
            let deleteObject = deleteIRResults[i] as IncomeReport
            context.delete(deleteObject)
        }
        let deleteISFetch: NSFetchRequest<InputSchedule> = InputSchedule.fetchRequest()
        let deleteISResults = try! context.fetch(deleteISFetch)
        for i in 0 ..< deleteISResults.count{
            let deleteObject = deleteISResults[i] as InputSchedule
            context.delete(deleteObject)
        }
        let deleteSettingFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let deleteSettingResults = try! context.fetch(deleteSettingFetch)
        for i in 0 ..< deleteSettingResults.count{
            let deleteObject = deleteSettingResults[i] as Settings
            context.delete(deleteObject)
        }
    }
}

