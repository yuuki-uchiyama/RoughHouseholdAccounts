//
//  MoneyReport+CoreDataProperties.swift
//  
//
//  Created by 内山由基 on 2018/08/14.
//
//

import Foundation
import CoreData


extension MoneyReport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoneyReport> {
        return NSFetchRequest<MoneyReport>(entityName: "MoneyReport")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var itemName: String?
    @NSManaged public var amount: Int64
    @NSManaged public var range: Int16

}
