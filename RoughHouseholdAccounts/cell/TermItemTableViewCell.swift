//
//  TermItemTableViewCell.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/29.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class TermItemTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var inputDayLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var rangeStringLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setting(_ inputSchedule:InputSchedule){
        let type = inputSchedule.type
        typeLabel.text = type
        if type == "支出"{
            typeLabel.textColor = UIColor.flatRed
            colorView.backgroundColor = UIColor.flatRed
        }else{
            typeLabel.textColor = UIColor.flatGreen
            colorView.backgroundColor = UIColor.flatGreen
        }
        categoryLabel.text = inputSchedule.category
        itemNameLabel.text = inputSchedule.itemName
        if inputSchedule.inputDay == 28{ inputDayLabel.text = "月末" }else{ inputDayLabel.text = "\(inputSchedule.inputDay)日" }
        amountLabel.text = "\(inputSchedule.amount)円"
        rangeStringLabel.text = inputSchedule.rangeString
    }
}
