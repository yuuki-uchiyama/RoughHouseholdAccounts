//
//  BannerAdsView.swift
//  RoughHouseholdAccounts
//
//  Created by 内山由基 on 2018/09/01.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BannerAdsView: UIView, GADBannerViewDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rectangleView: UIView!
    @IBOutlet weak var OKButton: UIButton!
    @IBOutlet weak var toGraphButton: UIButton!
    
    var rectangleBannerView: GADBannerView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("BannerAdsView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        OKButton.layer.cornerRadius = 20.0
        toGraphButton.layer.cornerRadius = 20.0
        OKButton.alpha = 0.3
        toGraphButton.alpha = 0.3
        OKButton.isEnabled = false
        toGraphButton.isEnabled = false
    }
    

    
    func labelChenged(_ editBool:Bool){
        if editBool{
            label.text = "データを更新しました"
        }else{
            label.text = "データを入力しました"
        }
    }
    
    func addAds(_ VC:UIViewController){
        rectangleBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        print(rectangleBannerView)
        rectangleView.addSubview(rectangleBannerView)
        rectangleBannerView.adUnitID = "ca-app-pub-3240594386716005/9516385182"
        rectangleBannerView.delegate = self
        rectangleBannerView.rootViewController = VC
        rectangleBannerView.load(GADRequest())

    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        OKButton.alpha = 1.0
        toGraphButton.alpha = 1.0
        OKButton.isEnabled = true
        toGraphButton.isEnabled = true
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        OKButton.alpha = 1.0
        toGraphButton.alpha = 1.0
        OKButton.isEnabled = true
        toGraphButton.isEnabled = true
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
