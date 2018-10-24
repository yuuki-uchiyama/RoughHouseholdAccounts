//
//  SpecialTermGraphView.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/10/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class SpecialTermGraphView: UIView, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var allTermButton: UIButton!
    @IBOutlet weak var specifyTermButton: UIButton!
    var termButtonArray:[UIButton]!
    @IBOutlet weak var specifyTermView: UIView!
    @IBOutlet weak var yearMonthPickerView: UIPickerView!
    var yearArray:[Int] = []
    var monthArray:[Int] = [1,2,3,4,5,6,7,8,9,10,11,12]
    var selectYear = 2018
    var selectMonth = 1
    @IBOutlet weak var oneMonthButton: UIButton!
    @IBOutlet weak var threeMonthButton: UIButton!
    @IBOutlet weak var halfYearButton: UIButton!
    @IBOutlet weak var oneYearButton: UIButton!
    @IBOutlet weak var twoYearButton: UIButton!
    @IBOutlet weak var threeYearButton: UIButton!
    var specifyTermButtonArray:[UIButton]!
    var specifyTermIntArray = [1,3,6,12,24,36]
    var selectTerm = 1
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var OKButton: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("SpecialTermGraphView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        termButtonArray = [allTermButton, specifyTermButton]
        specifyTermButtonArray = [oneMonthButton, threeMonthButton, halfYearButton, oneYearButton, twoYearButton, threeYearButton]
        let date = Date()
        let year = Calendar.current.component(.year, from: date)
        for i in (2010 ... year).reversed(){
            yearArray.append(i)
        }
        layoutSetting()
        oneMonthButton.isSelected = true
        termSelect(allTermButton)
        
        yearMonthPickerView.dataSource = self
        yearMonthPickerView.delegate = self
        
    }
    
    func layoutSetting(){
        allTermButton.setImage(UIImage(named: "RadioButton(On)"), for: .selected)
        specifyTermButton.setImage(UIImage(named: "RadioButton(On)"), for: .selected)
        
        for button in specifyTermButtonArray{
            button.buttonTapActionSetting(.circle)
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor(hexString: "0096FF")?.cgColor
            button.setImage(UIImage(named: "ColorRadioButton(On)"), for: .selected)
            button.setBackgroundColor(UIColor(hexString: "0096FF")!, for: .selected)
            button.setTitleColor(UIColor.white, for: .selected)
        }
        
        cancelButton.cornerLayout(.circle)
        OKButton.cornerLayout(.circle)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return yearArray.count
        }else{
            return monthArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.frame.height / 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return "\(yearArray[row])年"
        }else{
            return "\(monthArray[row])月"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            selectYear = yearArray[row]
        }else{
            selectMonth = monthArray[row]
        }
    }
    
    @IBAction func termSelect(_ sender: UIButton) {
        for button in termButtonArray{
            if sender == button{
                button.isSelected = true
            }else{
                button.isSelected = false
            }
        }
        
        if specifyTermButton.isSelected{
            specifyTermView.isUserInteractionEnabled = true
            specifyTermView.alpha = 1.0
        }else{
            specifyTermView.isUserInteractionEnabled = false
            specifyTermView.alpha = 0.3
        }
    }
    
    @IBAction func specifyTermSelect(_ sender: UIButton) {
        for i in 0 ..< specifyTermButtonArray.count{
            let button = specifyTermButtonArray[i]
            if sender == button{
                button.isSelected = true
                selectTerm = specifyTermIntArray[i]
            }else{
                button.isSelected = false
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
