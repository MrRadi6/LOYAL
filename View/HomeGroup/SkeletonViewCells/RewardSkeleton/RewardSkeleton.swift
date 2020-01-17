//
//  RewardSkeleton.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/5/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import SkeletonView

class RewardSkeleton: UICollectionViewCell {
    
    @IBOutlet weak var skeletonView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        skeletonView.layer.cornerRadius = 4
        SkeletonAppearance.default.tintColor = .silver
        showAnimatedGradientSkeleton(usingGradient: .init(baseColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), secondaryColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), animation: nil)
    }
    
    func startAnimatation() {
        DispatchQueue.main.async {
            self.startSkeletonAnimation()
        }
        
    }
    
    func stopAnimation() {
        DispatchQueue.main.async {
            self.stopSkeletonAnimation()
        }
    }
}
