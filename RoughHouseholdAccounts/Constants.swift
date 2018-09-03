//
//  Constants.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/03.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

struct MonthColor{
    static let JanColor = UIColor.flatRedDark
    static let FebColor = UIColor.flatPowderBlueDark
    static let MarColor = UIColor.flatPinkDark
    static let AprColor = UIColor.flatLimeDark
    static let MayColor = UIColor.flatMintDark
    static let JunColor = UIColor.flatMagentaDark
    static let JulColor = UIColor.flatSkyBlueDark
    static let AugColor = UIColor.flatOrangeDark
    static let SepColor = UIColor.flatForestGreenDark
    static let OctColor = UIColor.flatSandDark
    static let NovColor = UIColor.flatCoffeeDark
    static let DecColor = UIColor.flatBlueDark
}

struct CategorySpendColor{
    static let class1 = UIColor.flatRed
    static let class2 = UIColor.flatBlue
    static let class3 = UIColor.flatWatermelon
    static let class4 = UIColor.flatGreen
    static let class5 = UIColor.flatOrange
    static let class6 = UIColor.flatPurple
    static let class7 = UIColor.flatPink
    static let class8 = UIColor.flatCoffee
    static let class9 = UIColor.flatMint
    static let class10 = UIColor.flatGray
    
    static let colorArray: [UIColor] = [class1, class2, class3, class4, class5, class6, class7, class8, class9, class10]
}

struct CategoryRangeColor{
    static let class1 = UIColor.flatRedDark
    static let class2 = UIColor.flatBlueDark
    static let class3 = UIColor.flatWatermelonDark
    static let class4 = UIColor.flatGreenDark
    static let class5 = UIColor.flatOrangeDark
    static let class6 = UIColor.flatPurpleDark
    static let class7 = UIColor.flatPinkDark
    static let class8 = UIColor.flatCoffeeDark
    static let class9 = UIColor.flatMintDark
    static let class10 = UIColor.flatGrayDark
    
    static let colorArray: [UIColor] = [class1, class2, class3, class4, class5, class6, class7, class8, class9, class10]
}

struct Const {
    static let setting = "Settings"
    static let initialization = "initialization"
    static let separateDay = "separateDay"
    static let spendCategory = "SpendCategory"
    static let incomeCategory = "IncomeCategory"
    static let categoryNum = "number"
    static let categoryName = "categoryName"
    static let spendReport = "SpendReport"
    static let incomeReport = "IncomeReport"
    static let reportRange = "range"
    static let reportAmount = "amount"
    static let reportCategory = "category"
    static let reportDate = "date"
    
}

//let rangeDic: [String:Int] = ["より少ない":-2, "よりちょっと少ない":-1, "くらい":0, "よりちょっと多い":1, "より多い":2 ]

struct HHDocInfo{
    static let NAME = "RoughHouseholdAccounts"
    static var LOCAL_DOCUMENTS_PATH:String? = nil
}
