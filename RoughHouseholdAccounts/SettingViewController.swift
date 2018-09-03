//
//  SettingViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/02.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dayPickerView: UIPickerView!
    @IBOutlet weak var initializationSC: UISegmentedControl!
    
    @IBOutlet weak var editDayButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var rangeAdjustPV: UIPickerView!
    @IBOutlet weak var editRangeButton: UIButton!
    
    var attributedDic: [NSAttributedStringKey : UIFont] = [:]
    
    @IBOutlet weak var viewObSeparateDay: UIView!
    @IBOutlet weak var viewOfInitialization: UIView!
    @IBOutlet weak var viewOfRangeAdjust: UIView!
    @IBOutlet weak var viewOfCategoryItem: UIView!
    
    let dayArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]
    let rangeAdjustArray = ["少なめ", "やや少なめ", "普通", "やや多め", "多め"]
    let rangeAdjustDic: [String:Double] = ["少なめ":0.5, "やや少なめ":0.75, "普通":1, "やや多め":1.5, "多め":2]
    let rangeAdjustPVRowDic: [Double:Int] = [0.5:0, 0.75:1, 1:2, 1.5:3, 2:4]
    var separateDay = 1
    var initialization = false
    var rangeSetting: Double = 1.00
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    var settings: Settings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetting()
        
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        rangeAdjustPV.delegate = self
        rangeAdjustPV.dataSource = self
        
        SVProgressHUD.setMinimumDismissTimeInterval(0)
        
        context = appDelegate.persistentContainer.viewContext
        let settingsFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let settingsResults = try! context.fetch(settingsFetch)
        settings = settingsResults[0]
        separateDay = Int(settings.separateDay)
        initialization = settings.initialization
        rangeSetting = settings.rangeSetting
        
        dayPickerView.selectRow(separateDay - 1, inComponent: 0, animated: false)
        let rangeAdjustPVRow = rangeAdjustPVRowDic[rangeSetting]
        rangeAdjustPV.selectRow(rangeAdjustPVRow!, inComponent: 0, animated: false)
        if initialization{initializationSC.selectedSegmentIndex = 1}else{initializationSC.selectedSegmentIndex = 0}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dayPickerView.selectRow(Int(settings.separateDay) - 1, inComponent: 0, animated: false)
        let rangeAdjustPVRow = rangeAdjustPVRowDic[settings.rangeSetting]
        rangeAdjustPV.selectRow(rangeAdjustPVRow!, inComponent: 0, animated: false)
    }
    
    func layoutSetting(){
        let viewArray:[UIView] = [viewObSeparateDay, viewOfInitialization, viewOfRangeAdjust, viewOfCategoryItem]
        let borderColorArray:[CGColor] = [UIColor.flatPowderBlueDark.cgColor, UIColor.flatLime.cgColor, UIColor.flatYellow.cgColor, UIColor.flatWatermelon.cgColor]
        for i in 0 ..< viewArray.count{
            let v = viewArray[i]
            let height = v.frame.height
            v.layer.cornerRadius = height / 2
            v.layer.borderWidth = height / 15
            v.layer.borderColor = borderColorArray[i]
            v.backgroundColor = UIColor.flatSandDark
            self.view.sendSubview(toBack: v)
        }
        let buttonArray:[UIButton] = [editDayButton, editRangeButton, spendButton, incomeButton]
        for button in buttonArray{
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.layer.shadowOpacity = 0.5
            button.layer.shadowOffset = CGSize(width: 3, height: 3)
            button.addTarget(self, action: #selector(buttonTaped(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonUnTaped(_:)), for: .touchDragExit)
            button.addTarget(self, action: #selector(buttonUnTaped(_:)), for: .touchUpInside)
        }
        editDayButton.layer.cornerRadius = 5.0
        editRangeButton.layer.cornerRadius = 5.0
        spendButton.layer.cornerRadius = 20.0
        incomeButton.layer.cornerRadius = 20.0
        segmentedControl.frame.size.height = editDayButton.frame.size.height
        attributedDic = [ .font : (editDayButton.titleLabel?.font)!
        ]
        segmentedControl.setTitleTextAttributes(attributedDic, for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: return 28
        case 2: return 5
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            if row == 27{ return "月末"
            }else{ return "\(dayArray[row])日"}
        case 2:
            return rangeAdjustArray[row]
        default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            separateDay = dayArray[row]
        case 2:
            let selectedRange = rangeAdjustArray[row]
            rangeSetting = rangeAdjustDic[selectedRange]!
        default: break
        }
    }
    
    @IBAction func separateDayEdit(_ sender: Any) {
        let sDay = Int16(separateDay)
        if settings.separateDay != sDay{
        settings.separateDay = sDay
        try! context.save()
        SVProgressHUD.showSuccess(withStatus: "区切り設定を変更しました")
        }
    }
    
    @IBAction func initializationChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{initialization = false}else{initialization = true}
        settings.initialization = initialization
        try! context.save()
    }
    
    @IBAction func rangeSettingEdit(_ sender: Any) {
        if settings.rangeSetting != rangeSetting{
        settings.rangeSetting = rangeSetting
        let rangeDic: [String:Int] = ["より少ない":-2, "より少し少ない":-1, "くらい":0, "より少し多い":1, "より多い":2 ]
        let methods = Methods().self
        let editSpendFetch: NSFetchRequest<SpendReport> = SpendReport.fetchRequest()
        let spendReportArray = try! context.fetch(editSpendFetch)
        for SR in spendReportArray{
            let amount = Int(SR.amount)
            let selectRange = rangeDic[SR.rangeString!]!
            SR.range = Int64(methods.rangeCalculate(amount, selectRange, rangeSetting))
        }
        let editIncomeFetch: NSFetchRequest<IncomeReport> = IncomeReport.fetchRequest()
        let IncomeReportArray = try! context.fetch(editIncomeFetch)
        for IR in IncomeReportArray{
            let amount = Int(IR.amount)
            let selectRange = rangeDic[IR.rangeString!]!
            IR.range = Int64(methods.rangeCalculate(amount, selectRange, rangeSetting))
        }
        let editScheduleFetch: NSFetchRequest<InputSchedule> = InputSchedule.fetchRequest()
        let inputScheduleArray = try! context.fetch(editScheduleFetch)
        for IS in inputScheduleArray{
            let amount = Int(IS.amount)
            let selectRange = rangeDic[IS.rangeString!]!
            IS.range = Int64(methods.rangeCalculate(amount, selectRange, rangeSetting))
        }
        try! context.save()
        SVProgressHUD.showSuccess(withStatus: "誤差の範囲を変更しました")
        }
    }
    
    @IBAction func buttonTaped(_ sender: UIButton) {
        sender.frame.origin.x += 2
        sender.frame.origin.y += 2
        sender.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    @IBAction func buttonUnTaped(_ sender: UIButton) {
        sender.frame.origin.x -= 2
        sender.frame.origin.y -= 2
        sender.layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != ""{
            let settingItemVC: SettingItemViewController = segue.destination as! SettingItemViewController
        if segue.identifier == "spendCategoryEdit"{
            settingItemVC.type = "spend"
        }else if segue.identifier == "incomeCategoryEdit"{
            settingItemVC.type = "income"
        }
        }
    }
    
    @IBAction func unwindToSetting(segue: UIStoryboardSegue){
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
