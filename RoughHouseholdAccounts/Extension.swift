//
//  Extension.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/10/18.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//
import UIKit
import HMSegmentedControl

extension UIView{
    func shadowSetting(){
        let screenHeight = UIScreen.main.bounds.height
        var shadowSize = screenHeight / 100
        if UIDevice.current.userInterfaceIdiom == .phone{
            shadowSize = screenHeight / 75
        }
        
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: shadowSize, height: shadowSize)
    }
    
    func shadowDisappear(){
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func viewTapActionSetting(){
        shadowSetting()
        let touchDown = UILongPressGestureRecognizer(target: self, action: #selector(viewTap(_:)))
        touchDown.minimumPressDuration = 0
        self.addGestureRecognizer(touchDown)
    }
    
    @objc func viewTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("tapBegan")
            let shadowSize = sender.view!.layer.shadowOffset.height
            sender.view!.frame.origin.x += shadowSize / 2
            sender.view!.frame.origin.y += shadowSize / 2
            shadowDisappear()
        }
        if  sender.state == .ended {
            print("tapEnded")
            let shadowSize = sender.view!.layer.shadowOffset.height
            sender.view!.frame.origin.x -= shadowSize * 2
            sender.view!.frame.origin.y -= shadowSize * 2
            shadowSetting()
        }
    }
    
    enum cornerType{
        case collectionView
        case verySmall
        case small
        case normal
        case circle
    }
    
    func cornerLayout(_ type:cornerType){
        let rate = self.frame.height / self.frame.width
        var side: CGFloat!
        if rate == 1{
            if UIDevice.current.userInterfaceIdiom == .pad{
                side = self.frame.width
            }else{
                side = self.frame.height
            }
        }else if rate > 1{
            side = self.frame.width
        }else{
            side = self.frame.height
        }
        switch type {
        case .collectionView:
            self.layer.cornerRadius = side / 16.0
        case .verySmall:
            self.layer.cornerRadius = side / 8.0
        case .small:
            self.layer.cornerRadius = side / 6.0
        case .normal:
            self.layer.cornerRadius = side / 4.0
        case .circle:
            self.layer.cornerRadius = side / 2.0
        }
    }
}

extension HMSegmentedControl{
    func fontAdjustOfSegmentedControl(_ fontSize:CGFloat){
        let stringAttributes: [NSAttributedStringKey : UIFont] = [.font : UIFont(name: "Hiragino Maru Gothic ProN", size: fontSize)!]
        self.titleTextAttributes = stringAttributes
    }
}

extension UIColor {
    var image: UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(self.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIButton{
    func imageFit(){
        self.imageView?.contentMode = .scaleAspectFit
        self.contentHorizontalAlignment = .fill
        self.contentVerticalAlignment = .fill
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        let image = color.image
        setBackgroundImage(image, for: state)
    }
    
    func helpButtonAction(){
        self.backgroundColor = UIColor.clear
        self.setImage(UIImage(named: "Help"), for: .normal)
        self.setImage(UIImage(named: "Close"), for: .selected)
        self.imageFit()
    }
    func viewAdd(_ addView:UIView,_ backgroundView:UIView,_ superView:UIView){
        self.isSelected = !self.isSelected
        if self.isSelected{
            backgroundView.frame = superView.frame
            backgroundView.backgroundColor = UIColor.flatGray
            backgroundView.alpha = 0.8
            superView.insertSubview(backgroundView, belowSubview: self)
            addView.frame = superView.frame
            addView.contentMode = UIViewContentMode.scaleAspectFit
            superView.insertSubview(addView, belowSubview: self)
        }else{
            backgroundView.removeFromSuperview()
            addView.removeFromSuperview()
        }
    }
    
    func buttonTapActionSetting(_ type:cornerType){
        self.cornerLayout(type)
        let screenHeight = UIScreen.main.bounds.height
        var shadowSize = screenHeight / 100
        if UIDevice.current.userInterfaceIdiom == .phone{
            shadowSize = screenHeight / 75
        }
        
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: shadowSize, height: shadowSize)
        self.addTarget(self, action: #selector(buttonTap), for: .touchDown)
        
        self.addTarget(self, action: #selector(buttonRelease), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonRelease), for: .touchUpOutside)
        
    }
    
    @objc func buttonTap() {
        let shadowSize = UIScreen.main.bounds.height / 100
        if self.layer.shadowOffset.width >= shadowSize{
            self.frame.origin.x += shadowSize / 2
            self.frame.origin.y += shadowSize / 2
            self.layer.shadowOffset = CGSize(width:
                shadowSize / 4, height: shadowSize / 4)
        }
    }
    
    @objc func buttonRelease() {
        let shadowSize = self.layer.shadowOffset.height
        if shadowSize < UIScreen.main.bounds.height / 100{
            self.frame.origin.x -= shadowSize * 2
            self.frame.origin.y -= shadowSize * 2
            self.layer.shadowOffset = CGSize(width: shadowSize * 4, height: shadowSize * 4)
        }
    }
    
    func buttonSelect(){
        if self.isSelected{
            buttonTap()
        }else{
            let shadowSize = self.layer.shadowOffset.height
            if shadowSize < UIScreen.main.bounds.height / 100{
                buttonRelease()
            }
        }
    }
}

extension NSDate{
    func termCalculate(term:Int) -> NSDate {
        let add = DateComponents(month: term, day: -1, hour: 23, minute: 59, second: 59)
        let lastday = Calendar.current.date(byAdding: add, to: self as Date)! as NSDate
        
        return lastday

    }
}

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.index(of: value) {
            self.remove(at: i)
        }
    }
}

extension String{
    func removeSpace() -> String{
        return self.replacingOccurrences(of: " ", with: "")
    }
}
