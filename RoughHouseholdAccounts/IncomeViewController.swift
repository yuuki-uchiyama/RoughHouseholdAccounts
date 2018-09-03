//
//  IncomeViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/02.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import Expression
import CoreData
import GoogleMobileAds

class IncomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var rangePickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
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
    
    //    編集画面として使う場合のプロパティ
    var editBool = false
    var editIR: IncomeReport!
    var categoryCVDic: [String: IndexPath] = [:]
    
    //    計算関係
    var inputState = 0
    var pointBool = false
    var inputString = ""
    var symbol = ""
    var calculateString = ""
    
    //    画面上部関係のプロパティ
    var categoryArray: [String] = []
    var rangeArray = ["より少ない", "より少し少ない", "くらい", "より少し多い", "より多い"]
    var rangeDic: [String:Int] = ["より少ない":-2, "より少し少ない":-1, "くらい":0, "より少し多い":1, "より多い":2 ]
    var selectedRange = "くらい"
    
    //    ピッカービュー、コレクションビューの初期位置
    var selectedIndex: IndexPath = [0,0]
    var rangePVRow = 2
    var categoryNib: UINib!
    
    //    データ入力関係
    var date = Date()
    var amount: Int! = 0
    var range: Int! = 0
    var incomeCategory = ""
    
    //    ポップアップに日付を表示
    var formatter = DateFormatter()
    //    Settings
    var initialization: Bool!
    var rangeSetting: Double = 1.00

//    公式
    let methods = Methods().self
    
    //    coreData関係
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetting()
        
        context = appDelegate.persistentContainer.viewContext
        
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.backgroundColor = UIColor.clear
        rangePickerView.dataSource = self
        rangePickerView.delegate = self
        
        let categoryNib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        categoryCollectionView.register(categoryNib, forCellWithReuseIdentifier: "category")
        
        categoryArray = methods.loadIncomeCategory()
        categoryCollectionView.reloadData()
        if editBool{
            let editRange = editIR.rangeString!
            let editCategory = editIR.category!
            let editAmount = Int(editIR.amount)
            let editDate = editIR.date!
            rangePVRow = rangeDic[editRange]! + 2
            let amountString = String(editAmount)
            textField.text = amountString
            calculateString = amountString
            inputState = 4
            datePicker.setDate(editDate, animated: true)
            
            selectedRange = editRange
            incomeCategory = editCategory
            
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            admobView.addSubview(bannerView)
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }else{
            incomeCategory = categoryArray[0]
            AllClear()
        }
        defaultSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        symbol = ""
        inputState = 4
        categoryArray = methods.loadIncomeCategory()
        categoryCollectionView.reloadData()
        let settingsFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let setting = try! context.fetch(settingsFetch)[0]
        initialization = setting.initialization
        rangeSetting = setting.rangeSetting
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
        if incomeCategory == category{
            cell.cellSelected(UIColor.flatYellow)
            selectedIndex = indexPath
        }else{
            cell.cellDeselected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        incomeCategory = categoryArray[indexPath.row]
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
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate:"ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        date = datePicker.date
        amount = Int(textField.text!)
        let formatDate = formatter.string(from: date)
        let rangeNumber = rangeDic[selectedRange]!
        range = methods.rangeCalculate(amount, rangeNumber, rangeSetting)
        var message = ""
        if editBool{message = "上記の内容に変更します"}else{message = "上記の内容で登録します"}
        let alertController: UIAlertController = UIAlertController(title: "\(formatDate)\n\(incomeCategory)\n\(amount!)円\(selectedRange)", message: message, preferredStyle: .alert)
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
            editIR.date = date
            editIR.amount = Int64(amount)
            editIR.rangeString = selectedRange
            editIR.range = Int64(range)
            editIR.category = incomeCategory
            try! context.save()
            
        }else{
            let entity = NSEntityDescription.entity(forEntityName: "IncomeReport", in: context)!
            let spendReport = NSManagedObject(entity: entity, insertInto: context)
            
            spendReport.setValue(self.date, forKeyPath: "date")
            spendReport.setValue(Int64(self.amount), forKeyPath: "amount")
            spendReport.setValue(self.selectedRange, forKey: "rangeString")
            spendReport.setValue(Int64(self.range), forKeyPath: "range")
            spendReport.setValue(self.incomeCategory, forKeyPath: "category")
            
            try! context.save()
            AllClear()
            if initialization{
                rangePickerView.selectRow(2, inComponent: 0, animated: true)
                selectedRange = rangeArray[2]
                let d = Date()
                datePicker.setDate(d, animated: true)
                incomeCategory = categoryArray[0]
                categoryCollectionView.reloadData()
            }
        }
        bannerAdsView = BannerAdsView(frame: CGRect(x: 0, y: 0, width: 336, height: 386))
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
            incomeCategory = categoryArray[0]
            datePicker.setDate(date, animated: true)
        }
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
        bannerAdsView.removeFromSuperview()
        if editBool{
            performSegue(withIdentifier: "unwindToReport", sender: nil)
        }
    }
    
    @objc func toGraphButton(){
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
        sender.layer.shadowOffset = CGSize(width:
            0.5, height: 0.5)
    }
    
    @IBAction func buttonUnTaped(_ sender: UIButton) {
        sender.frame.origin.x -= 1
        sender.frame.origin.y -= 1
        sender.layer.shadowOffset = CGSize(width: 2, height: 2)
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
