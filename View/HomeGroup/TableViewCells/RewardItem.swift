//
//  RewardCell.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit


class RewardItem: UICollectionViewCell {
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var rewardBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rewardBackground.layer.cornerRadius = 4
        rewardBackground.layer.masksToBounds = true
    }
}
