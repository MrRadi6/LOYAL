//
//  NoVoucher.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/4/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class NoVoucher: UICollectionViewCell {
    
    @IBOutlet weak var redeemButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRedeemButton()
        descriptionLabel.text = NSLocalizedString("No Vouchers", comment: "No Vouchers")
    }
    
    private func configureRedeemButton() {
        redeemButton.layer.cornerRadius = 4
        redeemButton.layer.borderColor = #colorLiteral(red: 0.2588235294, green: 0.4784313725, blue: 0.6196078431, alpha: 1)
        redeemButton.layer.borderWidth = 1
        redeemButton.setTitle(NSLocalizedString("Get One Now", comment: "Get One Now"), for: .normal)
        
    }
    
    @IBAction func redeemPressed(sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabController = appDelegate.window?.rootViewController as! TabbarViewController
        tabController.selectedIndex = 1
        
    }
}
