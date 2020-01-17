//
//  VoucherCell.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class VoucherCell: UITableViewCell {
    
    @IBOutlet weak var voucherCollection: UICollectionView!
    var vouchers: [LatestVouchers]? {
        didSet {
            self.voucherCollection.reloadData()
        }
    }
    var parentView: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        voucherCollection.dataSource = self
        voucherCollection.delegate = self
        voucherCollection.register(UINib(nibName: "VoucherItem", bundle: nil), forCellWithReuseIdentifier: "VoucherItem")
        voucherCollection.register(UINib(nibName: "NoVoucher", bundle: nil), forCellWithReuseIdentifier: "NoVoucher")
    }
}

extension VoucherCell: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if vouchers?.count == 0 {
            return 1
        }
        return vouchers?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if vouchers == nil || vouchers?.count == 0 {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "NoVoucher", for: indexPath) as! NoVoucher
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoucherItem", for: indexPath) as! VoucherItem
        if let reward = vouchers?[indexPath.item] {
            cell.remainingDays = Verification.init().calcRemaininDays(validTo: reward.valid_end_date)
            cell.discountLabel.text = (Verification.init().getCurrentLanguage() == .English) ? reward.title : reward.title.translateNumbersToArabic()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let vouchers = vouchers ,let parentView = parentView else {
            print("FAILED TO UNWRAP VOUCHERS OR/AND PARENT VIEW IN COLLECTION VIEW VOUCHER CELL")
            return
        }
        if vouchers.count == 0 {
            return
        }
        let voucher = vouchers[indexPath.item]
        let qrImage = voucher.generateQRCode()
        let popup = UIStoryboard(name: "HomeStoryboard", bundle: nil).instantiateViewController(withIdentifier: "VoucherPopup") as! VoucherPopupViewController
        parentView.present(popup, animated: true) {
            popup.voucherImage.image = qrImage
            let qrCode = (Verification.init().getCurrentLanguage() == .English) ? "\(voucher.qr_code)" : "\(voucher.qr_code)".translateNumbersToArabic()
            popup.voucerID.text = "\(NSLocalizedString("ID", comment: "ID")): \(qrCode)"
        }
    }
}

extension VoucherCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if vouchers == nil || vouchers?.count == 0 {
            return CGSize(width: frame.width, height: 160)
        }
        return CGSize(width: 130, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
}
