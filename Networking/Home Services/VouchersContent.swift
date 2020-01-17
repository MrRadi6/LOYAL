//
//  VouchersContent.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/18/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON

class VouchersContent {
    private let requestAPI: RequestAPI
    private let token: String
    
    init(token: String, language: Language) {
        requestAPI = RequestAPI(requestType: .Vouchers, language: language)
        self.token = token
    }
    
    func getRewards(complition: @escaping (_ code:Int,_ data:[LatestVouchers]?,_ message:String) -> ()) {
        
        let header = ["Authorization" : "Bearer \(token)"]
        var vouchersArray: [LatestVouchers] = []
        
        requestAPI.makeGetRequest(header) { (result) in
            switch result {
            case .success(let json):
                print(json)
                let code = json["code"].intValue
                let message = json["message"].stringValue
                let vouchers = json["data"].arrayValue
                for voucher in vouchers {
                    vouchersArray.append(self.parseVoucher(voucher: voucher))
                }
                complition(code,vouchersArray,message)
               
            case .failure(let error):
                print("ERROR RETRIVING VOUCHERS IN VOUCHER CONTENT \(error)")
                complition(401,nil,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
            }
        }
    }
    
    private func parseVoucher(voucher: JSON) -> LatestVouchers {
        let id = voucher["id"].intValue
        let user_id = voucher["user_id"].intValue
        let qr_code = voucher["qr_code"].intValue
        let title = voucher["title"].stringValue
        let used_at = voucher["used_at"].stringValue
        let invoice_number = voucher["invoice_number"].intValue
        let valid_end_date = voucher["valid_end_date"].stringValue
        let status = voucher["status"].stringValue
        let is_used = voucher["is_used"].boolValue
        let is_valid = voucher["is_valid"].boolValue
        let is_expired = voucher["is_expired"].boolValue
        let created_at = voucher["created_at"].stringValue
        
        return LatestVouchers(id: id, user_id: user_id, qr_code: qr_code, title: title, used_at: used_at, invoice_number: invoice_number, valid_end_date: valid_end_date, status: status, is_used: is_used, is_valid: is_valid, is_expired: is_expired, created_at: created_at)
    }
}
