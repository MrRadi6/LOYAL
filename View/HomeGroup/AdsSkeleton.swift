//
//  AdsSkeleton.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/5/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import SkeletonView

class AdsSkeleton: UITableViewCell {
    
    @IBOutlet weak var SkeletonimageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        SkeletonAppearance.default.tintColor = .silver
        SkeletonimageView.layer.cornerRadius = 4
        showAnimatedGradientSkeleton(usingGradient: .init(baseColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), secondaryColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), animation: nil )
    }
}
