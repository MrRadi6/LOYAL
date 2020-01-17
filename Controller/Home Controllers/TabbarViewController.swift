//
//  TabbarViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/5/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {
    
    deinit {
        print("TAP BAR RELEASED FROM MEMORY")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.window?.rootViewController = self
        UIApplication.shared.keyWindow?.rootViewController = self
    }
}
