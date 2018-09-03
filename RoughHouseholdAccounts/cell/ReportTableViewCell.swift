//
//  ReportTableViewCell.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/28.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    
    let formatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMMEEE", options: 0, locale: Locale(identifier: "ja_JP"))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setting(_ colorRow:Int, _ date:Date, _ amount:Int, _ rangeString:String, _ range:Int, _ percent:Double){

        colorView.backgroundColor = CategorySpendColor.colorArray[colorRow]
        colorView.frame.size.width = self.frame.size.width * CGFloat(percent / 100.0)

        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
        amountLabel.text = "\(amount)円"
        if range > 0{
            rangeLabel.text = "\(rangeString)\n(+\(range)円)"
        }else if range == 0{
            rangeLabel.text = "\(rangeString)"
        }else{
            rangeLabel.text = "\(rangeString)\n(\(range)円)"
        }
    }
}
