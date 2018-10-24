//
//  TermViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/08/02.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import SVProgressHUD

class TermViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,  UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var dayPickerView: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var rangePickerView: UIPickerView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var admobView: UIView!
    
    
    @IBOutlet weak var viewOfTitle: UIView!
    @IBOutlet weak var viewOfDay: UIView!
    @IBOutlet weak var viewOfAmount: UIView!
    
//    文字サイズ変更のためのアウトレット
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var inputButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var attributedDic: [NSAttributedStringKey : UIFont] = [:]
    
    var bannerView: GADBannerView!
    var bannerAdsView: BannerAdsView!
    var backView:UIView!
    
//    編集画面から遷移した際に使用するもの
    var editBool = false
    var editInputSchedule: InputSchedule!
    var categoryCVDic: [String: IndexPath] = [:]
    
    //    アウトレット関連
    var spendCategoryArray: [String] = []
    var incomeCategoryArray: [String] = []
    var displayCategoryArray: [String] = []
    let dayArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]
    var rangeArray = ["より少ない", "より少し少ない", "ピッタリ", "より少し多い", "より多い"]
    var rangeDic: [String:Int] = ["より少ない":-2, "より少し少ない":-1, "ピッタリ":0, "より少し多い":1, "より多い":2 ]
    
    //    ピッカービュー、コレクションビューの初期位置
    var rangePVRow = 2
    var selectedIndex: IndexPath = [0,0]
    
    //    データ入力関係
    var itemName = ""
    var type = "支出"
    var category = ""
    var amount = 0
    var rangeString = "ピッタリ"
    var range = 0
    var inputDay = 1
    var nextInputDate = Date()
    var rangeSetting: Double = 1.00
    
    //    日付関連
    var date = Date()
    var calendar = Calendar.current
    var formatter = DateFormatter()
    
    //    coreData関係
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!

//    公式
    let methods = Methods().self
    
//    テキストフィールド設定
    var scrollBool = false
    var tapGesture: UITapGestureRecognizer!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setMinimumDismissTimeInterval(0)
        context = appDelegate.persistentContainer.viewContext
        
        layoutSetting()
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        dayPickerView.dataSource = self
        dayPickerView.delegate = self
        rangePickerView.dataSource = self
        rangePickerView.delegate = self
        itemNameTextField.delegate = self
        amountTextField.delegate = self
        
        let categoryNib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        categoryCollectionView.register(categoryNib, forCellWithReuseIdentifier: "category")
        

        spendCategoryArray = methods.loadSpendCategory()
        incomeCategoryArray = methods.loadIncomeCategory()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        tapGesture = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false
        
        if editBool{
            editButton.isHidden = true
            amountTextField.text = String(editInputSchedule.amount)
            itemNameTextField.text = editInputSchedule.itemName
            type = editInputSchedule.type!
            category = editInputSchedule.category!
            rangeString = editInputSchedule.rangeString!
            inputDay = Int(editInputSchedule.inputDay)
            if type == "支出"{segmentedControl.selectedSegmentIndex = 0}else{segmentedControl.selectedSegmentIndex = 1}
            typeChenged(segmentedControl)
            let rangePVRow = rangeDic[rangeString]! + 2
            rangePickerView.selectRow(rangePVRow, inComponent: 0, animated: false)
            let dayPVRow = Int(editInputSchedule.inputDay - 1)
            dayPickerView.selectRow(dayPVRow, inComponent: 0, animated: false)
            
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            admobView.addSubview(bannerView)
            bannerView.adUnitID = "ca-app-pub-3240594386716005/9516385182"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }else{
            editButton.isHidden = false
            typeChenged(segmentedControl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let settingsFetch: NSFetchRequest<Settings> = Settings.fetchRequest()
        let setting = try! context.fetch(settingsFetch)[0]
        rangeSetting = setting.rangeSetting
        
        spendCategoryArray = methods.loadSpendCategory()
        incomeCategoryArray = methods.loadIncomeCategory()
        
        if !editBool{
            defaultSetting()
        }

    }
    
    func layoutSetting(){
        let viewArray:[UIView] = [viewOfDay, viewOfTitle, viewOfAmount]
        for view in viewArray{
            let height = view.frame.height
            view.layer.cornerRadius = height / 4
            view.layer.borderWidth = 3.0
            view.layer.borderColor = UIColor.flatOrange.cgColor
            view.backgroundColor = UIColor.flatSand
        }
        
        let toolbar: UIToolbar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let done = UIBarButtonItem(title: "完了",
                                   style: .done,
                                   target: self,
                                   action: #selector(dismissKeyboard))
        toolbar.items = [space, done]
        toolbar.sizeToFit()
        self.amountTextField.inputAccessoryView = toolbar
        
        editButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        inputButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelButton.layer.cornerRadius = 20.0
        inputButton.layer.cornerRadius = 20.0
        editButton.layer.cornerRadius = 20.0
        segmentedControl.frame.size.height = editButton.frame.size.height
    }
    
    func defaultSetting(){
        category = displayCategoryArray[0]
        amountTextField.text = ""
        itemNameTextField.text = ""
        rangePickerView.selectRow(2, inComponent: 0, animated: false)
        dayPickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return dayArray.count
        }else{
            return rangeArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            if row == 27{
                return "月末"
            }else{
                return "\(dayArray[row])日"
            }
        }else{
            return rangeArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            inputDay = dayArray[row]
        }else{
            rangeString = rangeArray[row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = categoryCollectionView.frame.size.width / 7
        let height: CGFloat = categoryCollectionView.frame.size.height / 2.3
        let returnSize = CGSize(width: width, height: height)
        return returnSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayCategoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = displayCategoryArray[indexPath.row]
        categoryCVDic[c] = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCollectionViewCell
        cell.layer.cornerRadius = 10.0
        cell.backgroundColor = UIColor.white
        cell.categoryLabel.text = c
        cell.categoryLabel.adjustsFontSizeToFitWidth = true
        if category == c{
            cell.cellSelected(UIColor.flatLime)
            selectedIndex = indexPath
        }else{
            cell.cellDeselected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        category = displayCategoryArray[indexPath.row]
        let deselectedCell = categoryCollectionView.cellForItem(at: selectedIndex) as! CategoryCollectionViewCell
        deselectedCell.cellDeselected()
        let selectedCell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        selectedCell.cellSelected(UIColor.flatLime)
        selectedIndex = indexPath
        if segmentedControl.selectedSegmentIndex == 0{
            type = "支出"
        }else{
            type = "収入"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    @IBAction func typeChenged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            displayCategoryArray = spendCategoryArray
        }else{
            displayCategoryArray = incomeCategoryArray
        }
        categoryCollectionView.reloadData()
    }
    
    @IBAction func inputButton(_ sender: Any) {
        if itemNameTextField.text == ""{
            SVProgressHUD.showError(withStatus: "項目名が未記入です")
        }else if amountTextField.text == ""{
            SVProgressHUD.showError(withStatus: "金額が未記入です")
        }else{
            itemName = itemNameTextField.text!
            amount = Int(amountTextField.text!)!
            let rangeNumber = rangeDic[rangeString]!
            range = methods.rangeCalculate(amount, rangeNumber, rangeSetting)
            
            var year = calendar.component(.year, from: date)
            var month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            if day > inputDay{
                month += 1
                if month > 12{
                    year += 1
                    month -= 12
                }
            }
            nextInputDate = calendar.date(from: DateComponents(year: year, month: month, day: inputDay, hour:0, minute: 0, second: 0))!
            
            var message = ""
            if editBool{message = "上記の内容に変更します"}else{message = "上記の内容で登録します"}
            var d = ""
            if inputDay == 28{d = "月末"}else{d = "\(inputDay)日"}
            let alertController: UIAlertController = UIAlertController(title: "\(type)\n\(category):\(itemName)\n\(amount)円\(rangeString)\n毎月\(d)", message: message, preferredStyle: .alert)
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
            editInputSchedule.itemName = itemName
            editInputSchedule.type = type
            editInputSchedule.category = category
            editInputSchedule.amount = Int64(amount)
            editInputSchedule.rangeString = rangeString
            editInputSchedule.range = Int64(range)
            editInputSchedule.inputDay = Int16(inputDay)
            editInputSchedule.nextInputDate = nextInputDate
            
            try! context.save()
        }else{
            let methods = Methods().self
            let array = methods.loadInputSchedule()
            var number: Int16 = 0
            if array.count != 0{number = (array.last?.number)! + 1}
            print(number)
            let entity = NSEntityDescription.entity(forEntityName: "InputSchedule", in: context)!
            let inputSchedule = NSManagedObject(entity: entity, insertInto: context)
            
            inputSchedule.setValue(number, forKeyPath: "number")
            inputSchedule.setValue(itemName, forKeyPath: "itemName")
            inputSchedule.setValue(type, forKeyPath: "type")
            inputSchedule.setValue(category, forKey: "category")
            inputSchedule.setValue(Int64(amount), forKeyPath: "amount")
            inputSchedule.setValue(rangeString, forKeyPath: "rangeString")
            inputSchedule.setValue(Int64(range), forKeyPath: "range")
            inputSchedule.setValue(Int16(inputDay), forKeyPath: "inputDay")
            inputSchedule.setValue(nextInputDate, forKeyPath: "nextInputDate")

            try! context.save()
            print(nextInputDate)
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
        bannerAdsView.toGraphButton.addTarget(self, action: #selector(toTermItemButton), for: .touchUpInside)
        self.view.addSubview(bannerAdsView)
    }
    
    @objc func OKButton(){
        backView.removeFromSuperview()
        bannerAdsView.removeFromSuperview()
        if editBool{
            performSegue(withIdentifier: "unwindToTerm", sender: nil)
        }else{
            if type == "支出"{segmentedControl.selectedSegmentIndex = 0}else{segmentedControl.selectedSegmentIndex = 1}
            typeChenged(segmentedControl)
            defaultSetting()
        }
    }
    
    @objc func toTermItemButton(){
        backView.removeFromSuperview()
        bannerAdsView.removeFromSuperview()
        if editBool{
            performSegue(withIdentifier: "unwindToTermItem", sender: nil)
        }else{
            performSegue(withIdentifier: "toTermItem", sender: nil)
        }
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        if editBool{
            self.dismiss(animated: true, completion: nil)
        }else{
            defaultSetting()
        }
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
        if scrollBool{
            UIView.animate(withDuration: 0.2, animations:{
                self.centerView.frame.origin.y = 0
            })
            scrollBool = false
        }
        tapGesture.isEnabled = false
    }
    
    //    テキストフィールドのせり上がり設定
    @objc func keyboardWillBeShown(notification:NSNotification) {
        if !scrollBool{
            if let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
                let keyboardFrameY = keyboardFrame.origin.y
                let centerViewBottom = centerView.frame.height
                if centerViewBottom > keyboardFrameY {
                    let scrollRange = centerViewBottom - keyboardFrameY
                    UIView.animate(withDuration: 0.2, animations:{
                        self.centerView.frame.origin.y -= scrollRange
                        })
                }
            }
            scrollBool = true
            tapGesture.isEnabled = true
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTerm(segue: UIStoryboardSegue){
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
