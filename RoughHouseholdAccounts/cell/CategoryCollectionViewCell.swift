//
//  ClassCollectionViewCell.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/02.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func resizing(_ width:CGFloat, _ height:CGFloat){
        self.frame.size = CGSize(width: width, height: height)
    }
    
    func cellSelected(_ color: UIColor){
        self.backgroundColor = color
    }

    func cellDeselected(){
        self.backgroundColor = UIColor.white
    }

}
