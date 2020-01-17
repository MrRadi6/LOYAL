//
//  RewardsCell.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class RewardsCell: UITableViewCell {
    
    @IBOutlet weak var rewardsCollection: UICollectionView!
    
    var rewards: [TrendingReward]? {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.rewardsCollection.reloadData()
            }
        }
    }
    var parentViewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rewardsCollection.delegate = self
        rewardsCollection.dataSource = self
        rewardsCollection.register(UINib(nibName: "RewardItem", bundle: nil), forCellWithReuseIdentifier: "RewardItem")
    }
}

extension RewardsCell: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewards?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RewardItem", for: indexPath) as! RewardItem
        let title = (Verification.init().getCurrentLanguage() == .English) ? rewards?[indexPath.item].title : rewards?[indexPath.item].title.translateNumbersToArabic()
        cell.discountLabel.text = title
        cell.rewardBackground.image = rewards?[indexPath.item].backgroundImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let parentViewController = parentViewController else {
            fatalError("PARENT VIEW CONTROLLER NOT SET YET IN REWARDS CELL")
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        if let reward = rewards?[indexPath.item] {
         
            let rewardVC = UIStoryboard(name: "HomeStoryboard", bundle: nil).instantiateViewController(withIdentifier: "RewardsDetailsViewController") as! RewardsDetailsViewController
            rewardVC.reward = reward
            parentViewController.present(rewardVC, animated: true, completion: nil)
        }
    }
    
    
}

extension RewardsCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
