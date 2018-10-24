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
    @IBOutlet weak var rightColorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var underBarView: UIView!
    
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
    
    func setting(leftColor:UIColor?,rightColor:UIColor?, _ date:Date, _ amount:Int, _ rangeString:String, _ range:Int, _ percent:Double, _ wasteBool:Bool){

        if let sColor = leftColor{
        colorView.backgroundColor = sColor
        colorView.frame.size.width = self.frame.size.width * CGFloat(percent / 100.0)
        }else{
            colorView.isHidden = true
        }
        if let iColor = rightColor{
            rightColorView.backgroundColor = iColor
            rightColorView.frame.size.width = self.frame.size.width * CGFloat(percent / 100.0)
            rightColorView.frame.origin.x = self.frame.width - rightColorView.frame.width
        }else{
            rightColorView.isHidden = true
        }

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
        
        if wasteBool{
            underBarView.backgroundColor = UIColor.flatYellow
            self.backgroundColor = UIColor.flatSand
        }else{
            underBarView.backgroundColor = UIColor.clear
            self.backgroundColor = UIColor.flatWhite
        }
    }
}
