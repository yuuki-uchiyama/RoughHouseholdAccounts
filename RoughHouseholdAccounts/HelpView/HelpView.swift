//
//  HelpView.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/09/15.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class HelpView: UIView {
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var textView2: UITextView!
    @IBOutlet weak var textView3: UITextView!
    @IBOutlet weak var textView4: UITextView!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("HelpView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        
        layoutSetting()
        let viewArray:[UIView] = [view1,view2,view3,view4]
        let borderColorArray:[CGColor] = [UIColor.flatPowderBlueDark.cgColor, UIColor.flatLime.cgColor, UIColor.flatYellow.cgColor, UIColor.flatWatermelon.cgColor]
        for i in 0 ..< viewArray.count{
            let v = viewArray[i]
            let cgColor = borderColorArray[i]
            v.layer.cornerRadius = v.frame.height / 4
            v.layer.borderWidth = 2.0
            v.layer.borderColor = cgColor
        }
        
        self.addSubview(view)
    }
    
    func layoutSetting(){
        print(UIScreen.main.bounds.size)
        var textViewFontSize: CGFloat = 0
        var labelFontSize: CGFloat = 0
        switch UIScreen.main.bounds.size.width{
        case 0.0 ... 320.0:
            textViewFontSize = 10
            labelFontSize = 20
        case 321.0 ... 375.0:
            textViewFontSize = 12
            labelFontSize = 23
        case 376.0 ... 699.0:
            textViewFontSize = 13
            labelFontSize = 25
        case 700.0 ... 768.0:
            textViewFontSize = 19
            labelFontSize = 40
        case 769.0 ... 834.0:
            textViewFontSize = 21
            labelFontSize = 40
        default:
            textViewFontSize = 26
            labelFontSize = 45
        }
        print(textViewFontSize,labelFontSize)
        let textViewArray:[UITextView] = [textView1,textView2,textView3,textView4]
        for textView in textViewArray{
            textView.font = UIFont.systemFont(ofSize: textViewFontSize)
        }
        let labelArray:[UILabel] = [label1,label2,label3,label4]
        for label in labelArray{
            label.font = UIFont.systemFont(ofSize: labelFontSize)
        }
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: labelFontSize)
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
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
