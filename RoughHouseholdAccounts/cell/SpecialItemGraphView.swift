//
//  SpecialItemGraphView.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/10/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class SpecialItemGraphView: UIView, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var displayDefaultButton: UIButton!
    @IBOutlet weak var allTotalButton: UIButton!
    @IBOutlet weak var spendTotalButton: UIButton!
    @IBOutlet weak var incomeTotalButton: UIButton!
    @IBOutlet weak var wasteTotalButton: UIButton!
    var displayItemButtonArray:[UIButton]!
    var displayItem = 0
    
    @IBOutlet weak var termDefaultButton: UIButton!
    @IBOutlet weak var specifyTermButton: UIButton!
    var termButtonArray:[UIButton]!
    @IBOutlet weak var specifyTermView: UIView!
    @IBOutlet weak var startTermPV: UIPickerView!
    var startTermPVArray: [Int] = []
    @IBOutlet weak var endTermPV: UIPickerView!
    var endTermPVArray: [Int] = []
    var specifyTermBool = false
    var startTerm = 2017
    var endTerm = 2018
    
    @IBOutlet weak var intervalSC: UISegmentedControl!
    var selectInterval = 1
    
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
        let view = Bundle.main.loadNibNamed("SpecialItemGraphView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        displayItemButtonArray = [displayDefaultButton, allTotalButton, spendTotalButton, incomeTotalButton, wasteTotalButton]
        termButtonArray = [termDefaultButton, specifyTermButton]
        let date = Date()
        let year = Calendar.current.component(.year, from: date)
        for i in (2010 ... year).reversed(){
            endTermPVArray.append(i)
            startTermPVArray.append(i - 1)
        }
        
        layoutSetting()
        displayDefaultButton.isSelected = true
        termChange(termDefaultButton)
        intervalSC.selectedSegmentIndex = 0
        
        startTermPV.dataSource = self
        startTermPV.delegate = self
        endTermPV.dataSource = self
        endTermPV.delegate = self
    }
    
    func layoutSetting(){
        for button in displayItemButtonArray{
            button.buttonTapActionSetting(.circle)
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor(hexString: "0096FF")?.cgColor
            button.setImage(UIImage(named: "ColorRadioButton(On)"), for: .selected)
            button.setBackgroundColor(UIColor(hexString: "0096FF")!, for: .selected)
            button.setTitleColor(UIColor.white, for: .selected)
        }
        
        for button in termButtonArray{
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
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return startTermPVArray.count
        }else{
            return endTermPVArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.frame.height / 1.5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            return "\(startTermPVArray[row])年"
        }else{
            return "\(endTermPVArray[row])年"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            startTerm = startTermPVArray[row]
            if pickerView.selectedRow(inComponent: 0) < endTermPV.selectedRow(inComponent: 0){
                endTermPV.selectRow(row, inComponent: 0, animated: true)
                endTerm = endTermPVArray[row]
            }
        }else{
            endTerm = endTermPVArray[row]
            if pickerView.selectedRow(inComponent: 0) > startTermPV.selectedRow(inComponent: 0){
                startTermPV.selectRow(row, inComponent: 0, animated: true)
                startTerm = startTermPVArray[row]
            }
        }
    }
    
    
    @IBAction func displayItemChange(_ sender: UIButton) {
        for i in 0 ..< displayItemButtonArray.count{
            let button = displayItemButtonArray[i]
            if sender == button{
                button.isSelected = true
                displayItem = i
            }else{
                button.isSelected = false
            }
        }
    }
    
    @IBAction func termChange(_ sender: UIButton) {
        if sender == termDefaultButton{
            termDefaultButton.isSelected = true
            specifyTermButton.isSelected = false
            specifyTermView.alpha = 0.3
        }else{
            termDefaultButton.isSelected = false
            specifyTermButton.isSelected = true
            specifyTermView.alpha = 1.0
        }
        specifyTermBool = specifyTermButton.isSelected
        specifyTermView.isUserInteractionEnabled = specifyTermBool
    }
    
    @IBAction func intervalChange(_ sender: UISegmentedControl) {
        var intArray = [1, 2, 3, 4, 6, 12]
        selectInterval = intArray[sender.selectedSegmentIndex]
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
