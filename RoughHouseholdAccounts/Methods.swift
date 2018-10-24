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
    
    func loadSpendReport(_ startDate:NSDate?,_ EndDate:NSDate?,_ category:String?) -> [SpendReport] {
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        var predicate:NSPredicate!
        switch (startDate, category) {
        case (.some,.none):
            predicate = NSPredicate(format:"(date >= %@) AND (date <= %@)",startDate!,EndDate!)
        case (.none,.some):
            predicate = NSPredicate(format:"(category == %@)",category!)
        case (.some,.some):
            predicate = NSPredicate(format:"(date >= %@) AND (date <= %@) AND (category == %@)",startDate!,EndDate!,category!)
        default:break
        }

        let fetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
        fetch.sortDescriptors = [sortDescriptor]
        fetch.predicate = predicate
        let reportArray = try! context.fetch(fetch)
        
        return reportArray
    }
    
    func loadIncomeReport(_ startDate:NSDate?,_ EndDate:NSDate?,_ category:String?) -> [IncomeReport] {
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        var predicate:NSPredicate!
        switch (startDate, category) {
        case (.some,.none):
            predicate = NSPredicate(format:"(date >= %@) AND (date <= %@)",startDate!,EndDate!)
        case (.none,.some):
            predicate = NSPredicate(format:"(category == %@)",category!)
        case (.some,.some):
            predicate = NSPredicate(format:"(date >= %@) AND (date <= %@) AND (category == %@)",startDate!,EndDate!,category!)
        default:break
        }
        
        let fetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
        fetch.sortDescriptors = [sortDescriptor]
        fetch.predicate = predicate
        let reportArray = try! context.fetch(fetch)
        
        return reportArray
    }
    
    func loadWasteSpendReport(_ startDate:NSDate?,_ EndDate:NSDate?,_ category:String?) -> [SpendReport] {
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        var predicate:NSPredicate!
        switch (startDate, category) {
        case (.some,.none):
            predicate = NSPredicate(format:"(date >= %@) AND (date <= %@) AND (wasteBool == true)",startDate!,EndDate!)
        case (.none,.some):
            predicate = NSPredicate(format:"(category == %@) AND (wasteBool == true)",category!)
        case (.some,.some):
            predicate = NSPredicate(format:"(date >= %@) AND (date <= %@) AND (category == %@) AND (wasteBool == true)",startDate!,EndDate!,category!)
        default:break
        }
        
        let fetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
        fetch.sortDescriptors = [sortDescriptor]
        fetch.predicate = predicate
        let reportArray = try! context.fetch(fetch)
        
        return reportArray
    }
    
    func inputTermCalcurate() -> Int {
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        var separateDay = loadSetting().separateDay
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let spendFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
        let incomeFetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
        spendFetch.sortDescriptors = [sortDescriptor]
        incomeFetch.sortDescriptors = [sortDescriptor]
        let spendReportArray = try! context.fetch(spendFetch)
        let incomeReportArray = try! context.fetch(incomeFetch)
        var firstDate: Date!
        
        switch (spendReportArray.isEmpty,incomeReportArray.isEmpty) {
        case (true,true):
            return 0
        case (true,false):
            firstDate = incomeReportArray[0].date!
        case (false,true):
            firstDate = spendReportArray[0].date!
        case (false,false):
            let spendDate = spendReportArray[0].date!
            let incomeDate = incomeReportArray[0].date!
            if spendDate < incomeDate{
                firstDate = spendDate
            }else{
                firstDate = incomeDate
            }
        }
        
        let date = Date()
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        if separateDay == 28{
            month += 1
            separateDay = 1
        }else if calendar.component(.day, from: date) > separateDay{
            month += 1
            separateDay += 1
        }else{
            separateDay += 1
        }
        if month > 12{
            year += 1
            month -= 12
        }
        
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let d = dateFormater.date(from: "\(year)/\(month)/\(separateDay) 00:00:00")!
        let add = DateComponents(second: -2)
        let nowDate = calendar.date(byAdding: add, to: d)!
        
        var comps = calendar.dateComponents([.month], from: firstDate, to: nowDate)
        
        return comps.month! + 1
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

        let editFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
        let predicate = NSPredicate(format:"(rangeString == 'くらい')")
        editFetch.predicate = predicate
        let spendReportArray = try! context.fetch(editFetch)
        for SR in spendReportArray{
            SR.rangeString = "ピッタリ"
        }
        
        let editFetch2: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
        let predicate2 = NSPredicate(format:"(rangeString == 'くらい')")
        editFetch2.predicate = predicate2
        let incomeReportArray = try! context.fetch(editFetch2)
        for IR in incomeReportArray{
            IR.rangeString = "ピッタリ"
        }
        UserDefaults.standard.set(false, forKey: "update")
    }
}

