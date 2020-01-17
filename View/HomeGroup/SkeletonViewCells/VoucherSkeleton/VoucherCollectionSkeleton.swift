//
//  VoucherCollectionSkeleton.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/5/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit


class VoucherCollectionSkeleton: UITableViewCell {
    
    @IBOutlet weak var voucherCollection: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        voucherCollection.dataSource = self
        voucherCollection.delegate = self
        voucherCollection.register(UINib(nibName: "VoucherSkeleton", bundle: nil), forCellWithReuseIdentifier: "VoucherSkeleton")
    }
    
    func startSkeleton() {
        DispatchQueue.main.async {
            self.voucherCollection.reloadData()
        }
        
    }
}
    

extension VoucherCollectionSkeleton: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoucherSkeleton", for: indexPath) as! VoucherSkeleton
        cell.stopAnimation()
        cell.startAnimatation()
        return cell
    }
}

extension VoucherCollectionSkeleton : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 147)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
}
