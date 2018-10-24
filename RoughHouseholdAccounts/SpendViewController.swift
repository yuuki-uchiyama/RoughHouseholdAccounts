//
//  SpendViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/02.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import Expression
import CoreData
import GoogleMobileAds

class InputData{
    var category: String!
    var itemName: String!
    var amount: Int64!
    var rangeString: String!
    var inputDate: Date!
    
    init(_ c:String,_ i:String,_ a:Int64,_ r:String,_ d:Date) {
        category = c
        itemName = i
        amount = a
        rangeString = r
        inputDate = d
    }
}

class SpendViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var rangePickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var wasteButton: UIButton!
    @IBOutlet weak var admobView: UIView!
    @IBOutlet weak var one: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var four: UIButton!
    @IBOutlet weak var five: UIButton!
    @IBOutlet weak var six: UIButton!
    @IBOutlet weak var seven: UIButton!
    @IBOutlet weak var eight: UIButton!
    @IBOutlet weak var nine: UIButton!
    @IBOutlet weak var zero: UIButton!
    @IBOutlet weak var doubleZero: UIButton!
    @IBOutlet weak var point: UIButton!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var minus: UIButton!
    @IBOutlet weak var times: UIButton!
    @IBOutlet weak var devided: UIButton!
    @IBOutlet weak var AC: UIButton!
    @IBOutlet weak var equal: UIButton!
    
    @IBOutlet weak var viewOfTextField: UIView!
    

    var bannerView: GADBannerView!
    var bannerAdsView: BannerAdsView!
    var backView:UIView!
    
//    編集画面として使う場合のプロパティ
    var editBool = false
    var editSR: SpendReport!
    var categoryCVDic: [String: IndexPath] = [:]
    
//    計算関係
    var inputState = 0
    var pointBool = false
    var inputString = ""
    var symbol = ""
    var calculateString = ""
    
//    画面上部関係のプロパティ
    var categoryArray: [String] = []
    var rangeArray = ["より少ない", "より少し少ない", "ピッタリ", "より少し多い", "より多い"]
    var rangeDic: [String:Int] = ["より少ない":-2, "より少し少ない":-1, "ピッタリ":0, "より少し多い":1, "より多い":2 ]
    var selectedRange = "ピッタリ"
    
//    ピッカービュー、コレクションビューの初期位置
    var selectedIndex: IndexPath = [0,0]
    var rangePVRow = 2
    var categoryNib: UINib!
    
//    データ入力関係
    var date = Date()
    var amount: Int! = 0
    var range: Int! = 0
    var spendCategory = ""
    var wasteBool = false
    
//    ポップアップに日付を表示
    var formatter = DateFormatter()
//    Settings
    var initialization: Bool = false
    var rangeSetting:Double = 1.00
//    公式
    let methods = Methods().self
    
//    定期入出金の確認
    var inputArray: [InputData] = []
//    coreData関係
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetting()
        
        context = appDelegate.persistentContainer.viewContext
        
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate:"ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        rangePickerView.dataSource = self
        rangePickerView.delegate = self
        
        categoryNib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        categoryCollectionView.register(categoryNib, forCellWithReuseIdentifier: "category")
        
        categoryArray = methods.loadSpendCategory()
        categoryCollectionView.reloadData()
        if editBool{
            let editRange = editSR.rangeString!
            let editCategory = editSR.category!
            let editAmount = Int(editSR.amount)
            let editDate = editSR.date!
            rangePVRow = rangeDic[editRange]! + 2
            let amountString = String(editAmount)
            textField.text = amountString
            calculateString = amountString
            inputState = 4
            datePicker.setDate(editDate, animated: true)
            
            selectedRange = editRange
            spendCategory = editCategory
            wasteButton.isSelected = editSR.wasteBool
            
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            admobView.addSubview(bannerView)
            bannerView.adUnitID = "ca-app-pub-3240594386716005/9516385182"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }else{
            spendCategory = categoryArray[0]
            AllClear()
            inputData()
        }
        defaultSetting()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        symbol = ""
        inputState = 4
        categoryArray = methods.loadSpendCategory()
        categoryCollectionView.reloadData()
        let settingsFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let setting = try! context.fetch(settingsFetch)[0]
        initialization = setting.initialization
        rangeSetting = setting.rangeSetting
        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !inputArray.isEmpty{
            alert(inputArray[0])
        }
    }
    
    func layoutSetting(){
        let buttonArray: [UIButton] = [one, two, three, four, five, six, seven, eight, nine, zero, doubleZero, point, plus, minus, times, devided, AC, equal]
        for button in buttonArray{
            button.layer.cornerRadius = 10.0
            button.layer.shadowOpacity = 0.5
            button.layer.shadowOffset = CGSize(width: 2, height: 2)
            button.addTarget(self, action: #selector(buttonTaped(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonUnTaped(_:)), for: .touchDragExit)
            button.addTarget(self, action: #selector(buttonUnTaped(_:)), for: .touchUpInside)
        }
        viewOfTextField.layer.cornerRadius = viewOfTextField.frame.height / 2.5
        wasteButton.setImage(UIImage(named: "CheckOn"), for: .selected)
    }
    
    func defaultSetting(){
        rangePickerView.selectRow(rangePVRow, inComponent: 0, animated: false)
        categoryCollectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: UICollectionViewScrollPosition.top)
        if calculateString != ""{
            textField.text = calculateString
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = categoryCollectionView.frame.size.width / 7
        let height: CGFloat = categoryCollectionView.frame.size.height / 2.3
        let returnSize = CGSize(width: width, height: height)
        return returnSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categoryArray[indexPath.row]
        categoryCVDic[category] = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCollectionViewCell
        cell.layer.cornerRadius = 10.0
        cell.backgroundColor = UIColor.white
        cell.categoryLabel.text = category
        cell.categoryLabel.adjustsFontSizeToFitWidth = true
        if spendCategory == category{
            cell.cellSelected(UIColor.flatYellow)
            selectedIndex = indexPath
        }else{
            cell.cellDeselected()
        }
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        spendCategory = categoryArray[indexPath.row]
        let deselectedCell = categoryCollectionView.cellForItem(at: selectedIndex) as! CategoryCollectionViewCell
        deselectedCell.cellDeselected()
        let selectedCell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        selectedCell.cellSelected(UIColor.flatYellow)
        selectedIndex = indexPath
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rangeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.size.width, height: pickerView.frame.size.height / 3))
        label.textAlignment = .center
        label.text = rangeArray[row]
        label.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 18 )
        label.adjustsFontSizeToFitWidth = true
        return label
    } 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRange = rangeArray[row]
    }
    
    @IBAction func inputButton(_ sender: Any) {
        enter()
        if textField.text != "0"{
            date = datePicker.date
            amount = Int(textField.text!)
            let formatDate = formatter.string(from: date)
            let rangeNumber = rangeDic[selectedRange]!
            range = methods.rangeCalculate(amount, rangeNumber, rangeSetting)
            wasteBool = wasteButton.isSelected
            var title = "\(formatDate)\n\(spendCategory)\n\(amount!)円\(selectedRange)\n"
            if wasteButton.isSelected{
                title += "ムダ遣いかも？"
            }
            var message = ""
            if editBool{message = "上記の内容に変更します"}else{message = "上記の内容で登録します"}
            let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let yes = UIAlertAction(title: "はい", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.recording()
            })
            let no = UIAlertAction(title: "いいえ", style: .cancel)
            
            alertController.addAction(yes)
            alertController.addAction(no)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func recording(){
        if editBool{
            editSR.date = date
            editSR.amount = Int64(amount)
            editSR.rangeString = selectedRange
            editSR.range = Int64(range)
            editSR.category = spendCategory
            editSR.wasteBool = wasteButton.isSelected
            try! context.save()
            
        }else{
            let entity = NSEntityDescription.entity(forEntityName: "SpendReport", in: context)!
            let spendReport = NSManagedObject(entity: entity, insertInto: context)
            
            spendReport.setValue(self.date, forKeyPath: "date")
            spendReport.setValue(Int64(self.amount), forKeyPath: "amount")
            spendReport.setValue(self.selectedRange, forKey: "rangeString")
            spendReport.setValue(Int64(self.range), forKeyPath: "range")
            spendReport.setValue(self.spendCategory, forKeyPath: "category")
            spendReport.setValue(self.wasteButton.isSelected, forKey: "wasteBool")
            
            try! context.save()
            AllClear()
            if initialization{
                rangePickerView.selectRow(2, inComponent: 0, animated: true)
                selectedRange = rangeArray[2]
                let d = Date()
                datePicker.setDate(d, animated: true)
                spendCategory = categoryArray[0]
                categoryCollectionView.reloadData()
            }
            wasteButton.isSelected = false
        }
        backView = UIView(frame: self.view.frame)
        backView.backgroundColor = UIColor.white
        backView.alpha = 0.3
        self.view.addSubview(backView)
        bannerAdsView = BannerAdsView(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        bannerAdsView.center = self.view.center
        bannerAdsView.addAds(self)
        bannerAdsView.labelChenged(editBool)
        bannerAdsView.OKButton.addTarget(self, action: #selector(OKButton), for: .touchUpInside)
        bannerAdsView.toGraphButton.addTarget(self, action: #selector(toGraphButton), for: .touchUpInside)
        self.view.addSubview(bannerAdsView)
    }
    
    @IBAction func cancel(_ sender: Any) {
        if editBool{
            self.dismiss(animated: true, completion: nil)
        }else{
            AllClear()
            defaultSetting()
            spendCategory = categoryArray[0]
            datePicker.setDate(date, animated: true)
        }
    }
    
    @IBAction func wasteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    
//    inputState = 1
    @IBAction func numberButton(_ sender: UIButton) {
        let number = (sender.titleLabel?.text)!
        
        switch inputState {
        case 4:
            symbol = ""
            calculateString = ""
            fallthrough
        default:
            inputString += number
            textField.text = inputString
            inputState = 1
            break
        }
    }
    
    @IBAction func zeroButton(_ sender: UIButton) {
        let zero = (sender.titleLabel?.text)!
        
        switch inputState {
        case 0:
            break
        case 1, 2:
            inputString += zero
            textField.text = inputString
            break
        case 3, 4:
            textField.text = "0"
            break
        default:
            break
        }
    }
    
//    inputState = 2
    @IBAction func pointButton(_ sender: UIButton) {
        if !pointBool{
            switch inputState {
            case 0, 3:
                inputString = "0."
                break
            case 1:
                inputString += "."
                break
            case 2:
                break
            case 4:
                inputString = "0."
                symbol = ""
                calculateString = ""
                break
            default:
                break
            }
            textField.text = inputString
            pointBool = true
            inputState = 2
        }
    }
    
//    inputState = 0
    @IBAction func ACButton(_ sender: UIButton) {
        AllClear()
    }
    
    func AllClear(){
        textField.text = "0"
        inputState = 0
        pointBool = false
        inputString = ""
        symbol = ""
        calculateString = ""
    }

    
    
//    inputState = 3
    @IBAction func calculateButton(_ sender: UIButton) {
        var calc = ""
        switch sender.tag {
        case 1: calc = "+"
            break
        case 2: calc = "-"
            break
        case 3: calc = "*"
            break
        case 4: calc = "/"
            break
        default: break
        }
        
        switch inputState {
        case 0:
            break
        case 1:
            calculate()
            print(inputState)
            break
        case 2:
            inputString += "0"
            calculate()
            break
        default:
            break
        }
        if inputState != 0{
            symbol = calc
            inputState = 3
            pointBool = false
        }
    }
    
//    inputState = 4
    @IBAction func enterButton(_ sender: UIButton) {

        enter()
    }
    func enter(){
        switch inputState {
        case 0:
            break
        case 2:
            inputString += "0"
            break
        case 3:
            symbol = ""
            break
        default:
            break
        }
        if inputState != 0{
            calculate()
            inputState = 4
            pointBool = false
        }
    }
    
    func calculate(){
        if inputString != "0"{
            calculateString += symbol
            calculateString += inputString
            print(calculateString)
            do{
                let expression = Expression(calculateString)
                let resultDouble = try expression.evaluate()
                let result = round(resultDouble)
                if result.isNaN || result.isInfinite{
                    AllClear()
                }else{
                calculateString = String(Int(result))
                textField.text! = calculateString
                }
                inputString = ""
                symbol = ""
            }catch{
                AllClear()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func OKButton(){
        backView.removeFromSuperview()
        bannerAdsView.removeFromSuperview()
        if editBool{
            performSegue(withIdentifier: "unwindToReport", sender: nil)
        }
    }
    
    @objc func toGraphButton(){
        backView.removeFromSuperview()
        bannerAdsView.removeFromSuperview()
        if editBool{
            performSegue(withIdentifier: "unwindToGraph", sender: nil)
        }else{
            tabBarController?.selectedIndex = 2
        }
    }

    @IBAction func buttonTaped(_ sender: UIButton) {
        sender.frame.origin.x += 1
        sender.frame.origin.y += 1
        sender.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }
    
    @IBAction func buttonUnTaped(_ sender: UIButton) {
        sender.frame.origin.x -= 1
        sender.frame.origin.y -= 1
        sender.layer.shadowOffset = CGSize(width: 2, height: 2)

    }
    
    
//    定期入出金
    func inputData(){
        let date = Date()
        //        let date = Calendar.current.date(byAdding: .month, value: 0, to: d)!
        print(date)
        let inputScheduleFetch: NSFetchRequest<InputSchedule> = InputSchedule.fetchRequest()
        let inputScheduleResults = try! context.fetch(inputScheduleFetch)
        if inputScheduleResults.count != 0{
            for inputSchedule in inputScheduleResults{
                print("定期入出金\(inputSchedule.nextInputDate!)")
                print("現在日時\(date)")
                if inputSchedule.nextInputDate! <= date{
                    if inputSchedule.type == "支出"{
                        spendReportAdded(inputSchedule)
                    }else{
                        incomeReportAdded(inputSchedule)
                    }
                    let inputDate = inputSchedule.nextInputDate!
                    let inputData = InputData(inputSchedule.category!, inputSchedule.itemName!, inputSchedule.amount, inputSchedule.rangeString!, inputDate)
                    inputArray.append(inputData)
                    inputSchedule.nextInputDate = Calendar.current.date(byAdding: .month, value: 1, to: inputDate)
                    try! context.save()
                }
            }
        }
    }
    func spendReportAdded(_ inputSchedule: InputSchedule){
        print("OK")
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: Const.spendReport, in: context)!
        
        let spendReport = NSManagedObject(entity: entity, insertInto: context)
        spendReport.setValue(inputSchedule.nextInputDate, forKeyPath: "date")
        spendReport.setValue(Int64(inputSchedule.amount), forKeyPath: "amount")
        spendReport.setValue(inputSchedule.rangeString, forKey: "rangeString")
        spendReport.setValue(Int16(inputSchedule.range), forKeyPath: "range")
        spendReport.setValue(inputSchedule.category, forKeyPath: "category")
        
        try! context.save()
    }
    
    func incomeReportAdded(_ inputSchedule: InputSchedule){
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: Const.incomeReport, in: context)!
        
        let incomeReport = NSManagedObject(entity: entity, insertInto: context)
        incomeReport.setValue(inputSchedule.nextInputDate, forKeyPath: "date")
        incomeReport.setValue(Int64(inputSchedule.amount), forKeyPath: "amount")
        incomeReport.setValue(inputSchedule.rangeString, forKey: "rangeString")
        incomeReport.setValue(Int16(inputSchedule.range), forKeyPath: "range")
        incomeReport.setValue(inputSchedule.category, forKeyPath: "category")
        
        try! context.save()
    }
    
    func alert(_ inputData:InputData){
        let formatDate = formatter.string(from: inputData.inputDate)
        let alertController: UIAlertController = UIAlertController(title: "\(inputData.category!):\(inputData.itemName!)\n金額：\(inputData.amount!)円\(inputData.rangeString!)\n\(formatDate)", message: "上記を自動入力しました。", preferredStyle: .alert)
        let yes = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.inputArray.remove(at: 0)
            if self.inputArray.isEmpty{
                self.dismiss(animated: true, completion: nil)
            }else{
                self.alert(self.inputArray[0])
            }
        })
        alertController.addAction(yes)
        present(alertController, animated: true, completion: nil)
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
