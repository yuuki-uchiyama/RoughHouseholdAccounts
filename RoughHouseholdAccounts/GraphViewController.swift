//
//  GraphViewController.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/10/18.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var itemizedButton: UIButton!
    var buttonArray: [UIButton]!

    @IBOutlet weak var otherGraphButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: UIViewController?

    var monthlyGraphVC:MonthlyGraphViewController!
    var itemizedGraphVC:ItemizedGraphViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: "monthly")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView)
        monthlyButton.isSelected = true
        
        buttonArray = [monthlyButton,itemizedButton]

        layoutSetting()
        
        otherGraphButton.setImage(UIImage(named: "Close(White)"), for: .selected)
        otherGraphButton.setBackgroundColor(UIColor.red, for: .selected)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if monthlyButton.isSelected{
            selectButtonChange(sender: monthlyButton)
            let monthlyVC = self.currentViewController as! MonthlyGraphViewController
            if monthlyVC.allGraphBool || monthlyVC.specialGraphBool{
                self.otherGraphButton.isSelected = true
            }
        }else{
            selectButtonChange(sender: itemizedButton)
            let itemVC = self.currentViewController as! ItemizedGraphViewController
            if itemVC.displayItem != 0 || itemVC.specifyTermBool{
                self.otherGraphButton.isSelected = true
            }
        }
    }
    
    func layoutSetting(){
        monthlyButton.cornerLayout(.circle)
        itemizedButton.cornerLayout(.circle)
        monthlyButton.shadowSetting()
        itemizedButton.shadowSetting()
        otherGraphButton.cornerLayout(.circle)
        monthlyButton.setTitleColor(UIColor.white, for: .selected)
        itemizedButton.setTitleColor(UIColor.white, for: .selected)
    }
    
    func addSubview(_ subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|", options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func selectButtonChange(sender:UIButton){
        for button in buttonArray{
            if sender == button{
                button.isSelected = true
                button.isEnabled = false
                button.alpha = 1.0
                button.buttonTap()
            }else{
                button.isSelected = false
                button.isEnabled = true
                button.alpha = 0.3
                button.buttonRelease()
            }
        }
    }
    
    @IBAction func showComponent(sender: UIButton) {
        if otherGraphButton.isSelected{
            otherGraphButton.isSelected = false
        }
        selectButtonChange(sender: sender)
        
        if sender == monthlyButton {
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "monthly")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        } else {
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "itemized")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        }
    }
    
    func cycleFromViewController(_ oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        }, completion: { finished in
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMove(toParentViewController: self)
        })
    }
    
    @IBAction func otherGraph(_ sender: UIButton) {
        if monthlyButton.isSelected{
            if !sender.isSelected{
                otherGraphButton.isEnabled = false
                monthlyButton.isEnabled = false
                itemizedButton.isEnabled = false
            }
            
            let VC = self.currentViewController as! MonthlyGraphViewController
            VC.buttonTap(sender)
            VC.specialTermGraphView.cancelButton.addTarget(self, action: #selector(buttonCancel), for: .touchUpInside)
            VC.specialTermGraphView.OKButton.addTarget(self, action: #selector(buttonSelect), for: .touchUpInside)
        }else{
            let VC = self.currentViewController as! ItemizedGraphViewController
            VC.buttonTap(sender)
            VC.specialItemGraphView.cancelButton.addTarget(self, action: #selector(buttonCancel), for: .touchUpInside)
            VC.specialItemGraphView.OKButton.addTarget(self, action: #selector(buttonSelectForItemVC), for: .touchUpInside)
        }
    }
    
    @objc func buttonCancel(){
        otherGraphButton.isEnabled = true
        if monthlyButton.isSelected{
            itemizedButton.isEnabled = true
        }else{
            monthlyButton.isEnabled = true
        }
    }
    
    @objc func buttonSelect(){
        otherGraphButton.isSelected = true
        otherGraphButton.isEnabled = true
        if monthlyButton.isSelected{
            itemizedButton.isEnabled = true
        }else{
            monthlyButton.isEnabled = true
        }
    }
    
    @objc func buttonSelectForItemVC(){
        let VC = self.currentViewController as! ItemizedGraphViewController
        let displayBool = VC.specialItemGraphView.displayDefaultButton.isSelected
        let termBool = VC.specialItemGraphView.termDefaultButton.isSelected
        if !displayBool || !termBool{
            otherGraphButton.isSelected = true
        }
        otherGraphButton.isEnabled = true
        if monthlyButton.isSelected{
            itemizedButton.isEnabled = true
        }else{
            monthlyButton.isEnabled = true
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
