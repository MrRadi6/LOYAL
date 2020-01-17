//
//  VoucherCell.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class VoucherItem: UICollectionViewCell {
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var expireDateLabel: UILabel!
    @IBOutlet weak var qrContainer: UIView!
    @IBOutlet weak var qrbackground: UIView!
    
    var remainingDays: Int? {
        didSet {
            if let remainingDays = remainingDays {
                let verification = Verification()
                let days = (verification.getCurrentLanguage() == .English) ? "\(remainingDays)" : "\(remainingDays)".translateNumbersToArabic()
                expireDateLabel.text = "\(NSLocalizedString("Expires in", comment: "Expires in")) \(days) \(NSLocalizedString("Days", comment: "Days"))"
            }
        }
    }
   override func awakeFromNib() {
        super.awakeFromNib()
        qrContainer.makeShadow(radius: 4)
        qrbackground.makeShadow(radius: 4)
    
    }
}
