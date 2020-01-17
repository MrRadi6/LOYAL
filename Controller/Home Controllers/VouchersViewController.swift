//
//  VouchersViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class VouchersViewController: UIViewController {
    
    @IBOutlet weak var vouchersTableView: UITableView!
    @IBOutlet weak var navBar: CustomNavBar!
    
    private let refreshControl = UIRefreshControl()
    private var isLoading = false
    private var isSuccessCall = true
    private var isNoData = false
    private var isValidArray    : [LatestVouchers] = []
    private var isExpiredArray  : [LatestVouchers] = []
    private var isUsedArray     : [LatestVouchers] = []
    var isFromRedeem = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.parentViewController = self
        Verification.init().configureViewWithTime(viewController: self)
        vouchersTableView.register(UINib(nibName: "VoucherTableViewCell", bundle: nil), forCellReuseIdentifier: "VoucherTableViewCell")
        vouchersTableView.register(UINib(nibName: "InstructionTableViewCell", bundle: nil), forCellReuseIdentifier: "InstructionTableViewCell")
        vouchersTableView.register(UINib(nibName: "VouchersHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "VouchersHeader")
        vouchersTableView.register(UINib(nibName: "RewardsDetailtsSkeleton", bundle: nil), forCellReuseIdentifier: "RewardsDetailtsSkeleton")
        vouchersTableView.register(UINib(nibName: "VoucherErrorCell", bundle: nil), forCellReuseIdentifier: "VoucherErrorCell")
        vouchersTableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")
        
        vouchersTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleFetchData), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFetchData), name: .didRedeemVoucher, object: nil)
        handleFetchData()
        // Do any additional setup after loading the view.
    }

    
    @objc func handleFetchData() {
        isValidArray = []
        isExpiredArray = []
        isUsedArray = []
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        
        if !Connection.init().checkInterConnectivity(parentView: self) {
            isSuccessCall = false
            DispatchQueue.main.async {
                self.vouchersTableView.reloadData()
            }
            return
        }
        
        isLoading = true
        vouchersTableView.reloadData()
        guard let token = UserData.getUserData()?.token else {
            fatalError("TOKEN IS NIL IN VOUCHERS VIEW CONTROLLER (FETCH DATA")
        }
        
        let language = Verification.init().getCurrentLanguage()
        VouchersContent.init(token: token, language: language).getRewards() { [unowned self] (code, vouchers, message) in
            if code == 200 {
                self.isSuccessCall = true
                if let vouchers = vouchers {
                    if vouchers.count == 0 {
                        self.isNoData = true
                    }
                    for voucher in vouchers {
                        self.spliteVouchersTypes(voucher: voucher)
                    }
                    self.isValidArray.reverse()
                    self.isExpiredArray.reverse()
                    self.isUsedArray.reverse()
                    self.isSuccessCall = true
                }
                else {
                    print("VOUCHER IS NIL")
                }
                
            }
            else if code == 401 {
                self.isSuccessCall = false
                Verification.init().makeConnectionAlert(parentView: self, error: .BadRequest, message: message, complition: {
                    
                })
            }
            else {
                self.isSuccessCall = false
                Verification.init().makeConnectionAlert(parentView: self, error: .InternelServerError, message: message, complition: {
                    
                })
            }
            self.isLoading = false
            self.vouchersTableView.reloadData()
        }
    }
    
    private func spliteVouchersTypes(voucher: LatestVouchers) {
        
        if voucher.is_valid {
            isValidArray.append(voucher)
            
        }
        else if voucher.is_expired {
            isExpiredArray.append(voucher)
        }
        else if voucher.is_used {
            isUsedArray.append(voucher)
        }
        else {
            print("UNKNOWN STATE FOR THE VOUCHER IN VOUCHERS VIEW CONTROLLER (spliteVouchersTypes)")
        }
    }

}

extension VouchersViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else if section == 1 {
            // VALID VOUCHER CELLS
            if !isSuccessCall { return 1}
            if isNoData {return 1}
            return  (isLoading) ? 8 : isValidArray.count
        }
        else if section == 2 {
            // EXPIRED VOUCHER CELLS
            return isExpiredArray.count
        }
        else {
            // USED VOUCHER CELLS
           return isUsedArray.count
        }
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (isLoading || !isSuccessCall) ? 2 : 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell : InstructionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "InstructionTableViewCell") as! InstructionTableViewCell
            return cell
        }
        else if indexPath.section == 1 {
            if !isSuccessCall {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
                cell.addTarget(target: self, action: #selector(handleFetchData), forEvent: .touchUpInside)
                return cell
            }
            else if isLoading && !isNoData{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RewardsDetailtsSkeleton") as! RewardsDetailtsSkeleton
                DispatchQueue.main.async {
                    cell.stopSkeletonAnimation()
                    cell.startSkeletonAnimation()
                }
                cell.isUserInteractionEnabled = false
                return cell
            }
            else if isNoData {
                let cell: VoucherErrorCell = tableView.dequeueReusableCell(withIdentifier: "VoucherErrorCell") as! VoucherErrorCell
                return cell
            }
            else {
                let voucher = isValidArray[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherTableViewCell", for: indexPath) as! VoucherTableViewCell
                cell.setVoucherState(state: .Valid)
                cell.voucher = voucher
                if indexPath.row == 0 && isFromRedeem{
                    isFromRedeem = false
                    cell.makeFireWorkEffect()
                }
                return cell
            }
            
        }
        else if indexPath.section == 2 {
            let voucher = isExpiredArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherTableViewCell", for: indexPath) as! VoucherTableViewCell
            cell.setVoucherState(state: .Expired)
            cell.voucher = voucher
            return cell
        }
        else {
            let voucher = isUsedArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherTableViewCell", for: indexPath) as! VoucherTableViewCell
            cell.setVoucherState(state: .Used)
            cell.voucher = voucher
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isNoData {
            return
        }
        if !isSuccessCall {
            return
        }
        tableView.deselectRow(at: indexPath, animated: false)
        let voucher = isValidArray[indexPath.row]
        let qrImage = voucher.generateQRCode()
        let popup = UIStoryboard(name: "HomeStoryboard", bundle: nil).instantiateViewController(withIdentifier: "VoucherPopup") as! VoucherPopupViewController
            present(popup, animated: true) {
            popup.voucherImage.image = qrImage
                let qrCode = (Verification.init().getCurrentLanguage() == . English) ? "\(voucher.qr_code)" : "\(voucher.qr_code)".translateNumbersToArabic()
            popup.voucerID.text = "\(NSLocalizedString("ID", comment: "ID")): \(qrCode)"

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120
        }
        if !isSuccessCall && indexPath.section == 1 {
            return vouchersTableView.layer.frame.height - 120
        }
        if isNoData && indexPath.section == 1 {
            return vouchersTableView.layer.frame.height - 200
        }
        return 130
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || !isSuccessCall || isNoData{
            return 0.01
        }
        else if section == 1 && isValidArray.count == 0 {
            return 0
        }
        else if section == 2 && isExpiredArray.count == 0 {
            return 0
        }
        else if section == 3 && isUsedArray.count == 0 {
            return 0
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "VouchersHeader") as! VouchersHeader
    
        if section == 1 && isValidArray.count > 0 {
            header.setVoucherState(state: .Valid)
            return header
        }
        else if section == 2 && isExpiredArray.count > 0 {
            header.setVoucherState(state: .Expired)
            return header
        }
        else if section == 3 && isUsedArray.count > 0 {
            header.setVoucherState(state: .Used)
            return header
        }
        return UITableViewHeaderFooterView()
    }
    
}
