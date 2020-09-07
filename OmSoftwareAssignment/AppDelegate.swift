//
//  AppDelegate.swift
//  OmSoftwareAssignment
//
//  Created by Shubham Vinod Kamdi on 05/09/20.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?
    var VC: UIViewController!
    var img: UIImageView!
    var spin: SpinnerView!
    var blurredView: UIVisualEffectView!
    var viewBelow: UIView!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func showLoader(){
        
        if #available(iOS 13.0, *) {
            self.blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        } else {
            self.blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        }
        blurredView.frame =  self.VC.view.bounds
        
        viewBelow = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        viewBelow.backgroundColor = UIColor.clear
        self.VC.view.addSubview(viewBelow)
        self.VC.view.bringSubviewToFront(blurredView)
    
       
        
        spin = SpinnerView()
        spin.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
        spin.center = self.VC.view.center
       // spin.alpha = 0
        self.VC.view.addSubview(spin)
        
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        img.layer.cornerRadius = 30
        img.clipsToBounds = true
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = 1.5
        img.image = UIImage(named: "apple-logo-business-iphone-png-favpng-hyzjSfZY66wqwfvuMkgRbVwFw")
        img.center = self.VC.view.center
       // img.alpha = 0
        self.VC.view.addSubview(img)
        self.VC.view.bringSubviewToFront(spin)
        self.VC.view.bringSubviewToFront(img)
        
      
        
    }
    
   
    
    func removeLoader(){
        if VC != nil && img != nil && spin != nil && viewBelow != nil {
            self.img.removeFromSuperview()
            self.spin.removeFromSuperview()
            self.viewBelow.removeFromSuperview()
        }
    }


}

