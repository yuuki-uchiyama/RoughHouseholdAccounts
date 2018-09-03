//
//  ReportTableViewCell.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/03.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import ChameleonFramework

class CategoryReportTableViewCell: UITableViewCell {

    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var rangeColorView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var spendLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setting(_ row:Int, _ name:String, _ spend:Int, _ range:Int, _ percent:Double, _ rangePercent:Double){
        var attributes : [NSAttributedStringKey : Any] = [
            .strokeColor : CategorySpendColor.colorArray[row],
            .strokeWidth : -4.0,
            .foregroundColor : UIColor.flatWhite
        ]
        colorView.backgroundColor = CategorySpendColor.colorArray[row]
        categoryNameLabel.attributedText = NSAttributedString(string: name, attributes: attributes)
        if percent == 0.0{
            percentLabel.attributedText = NSAttributedString(string: "0%", attributes: attributes)
        }else if percent == 100.0{
            percentLabel.attributedText = NSAttributedString(string: "100%", attributes: attributes)
        }else{
            percentLabel.attributedText = NSAttributedString(string: "\(percent)％", attributes: attributes)
        }
        let s = NSAttributedString(string: "\(spend)円", attributes: attributes)
        attributes = [
            .font : UIFont(name: "Hiragino Maru Gothic ProN", size: 10)!,
            .foregroundColor : UIColor.flatGray
        ]
        let r = NSAttributedString(string: "\(range)円", attributes: attributes)
        let dash = NSAttributedString(string: " 〜 ", attributes: attributes)
        let mutableAttributedString = NSMutableAttributedString()
        if range < spend{ //rangeがマイナスの場合
            mutableAttributedString.append(r)
            mutableAttributedString.append(dash)
            mutableAttributedString.append(s)
            
            colorView.frame.size.width = self.frame.size.width * CGFloat((percent - rangePercent) / 100.0)
            rangeColorView.backgroundColor = CategoryRangeColor.colorArray[row]
            rangeColorView.alpha = 1.0
            rangeColorView.frame.size.width = self.frame.size.width * CGFloat(rangePercent / 100.0)
            rangeColorView.frame.origin = CGPoint(x: colorView.frame.size.width, y: 0.0)
            
        }else if range == spend{
            mutableAttributedString.append(s)
            colorView.frame.size.width = self.frame.size.width * CGFloat(percent / 100.0)
            rangeColorView.frame.size.width = 0.0
        }else{ //rangeがプラスの場合
            mutableAttributedString.append(s)
            mutableAttributedString.append(dash)
            mutableAttributedString.append(r)
            
            colorView.frame.size.width = self.frame.size.width * CGFloat(percent / 100.0)
            rangeColorView.backgroundColor = CategoryRangeColor.colorArray[row]
            rangeColorView.alpha = 0.5
            rangeColorView.frame.size.width = self.frame.size.width * CGFloat(rangePercent / 100.0)
            rangeColorView.frame.origin = CGPoint(x: colorView.frame.size.width, y: 0.0)
        }
        spendLabel.attributedText = mutableAttributedString
    }
}
