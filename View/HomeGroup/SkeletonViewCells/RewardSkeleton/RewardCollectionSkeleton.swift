//
//  RewardCollectionSkeleton.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/5/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class RewardCollectionSkeleton: UITableViewCell {

    @IBOutlet weak var rewardsSkeletonCollection: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rewardsSkeletonCollection.delegate = self
        rewardsSkeletonCollection.dataSource = self
        rewardsSkeletonCollection.register(UINib(nibName: "RewardSkeleton", bundle: nil), forCellWithReuseIdentifier: "RewardSkeleton")
    }
    
    func startSkeleton() {
        print("Start Skeleton")
        DispatchQueue.main.async {
            self.rewardsSkeletonCollection.reloadData()
        }
        
    }
}

extension RewardCollectionSkeleton: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RewardSkeleton", for: indexPath) as! RewardSkeleton
        cell.stopAnimation()
        cell.startAnimatation()
        return cell
    }
    
    
}

extension RewardCollectionSkeleton : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
