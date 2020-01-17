//
//  SectionHeader.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class SectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var sectionTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func seeAllPressed(_ sender: UIButton) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let tabController = appDelegate.window?.rootViewController as! TabbarViewController
        let tabController = UIApplication.shared.keyWindow?.rootViewController as! TabbarViewController
        switch sectionTitle.text {
        case NSLocalizedString("Trending Rewards", comment: "Trending Rewards Title"):
            tabController.selectedIndex = 1
        case NSLocalizedString("Latest Vouchers", comment: "Latest Vouchers Title"):
            tabController.selectedIndex = 2
        default:
            fatalError("*************UNKNOWN HEADER*************")
        }
    }
}
