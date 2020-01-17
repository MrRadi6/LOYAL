//
//  HistoryContent.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/24/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON

class HistoryContent {
    
    private let requestAPI: RequestAPI
    private let token: String
    
    init(token: String, language: Language) {
        requestAPI = RequestAPI(requestType: .HistoryPoints, language: language)
        self.token = token
    }
    
    func getHistoryPoints(complition: @escaping (_ code:Int,_ data:[LatestExpirePoints]?,_ message:String) -> ()) {
        let header = ["Authorization" : "Bearer \(token)"]
        var porintsArray: [LatestExpirePoints] = []
        
        requestAPI.makeGetRequest(header) { (result) in
            switch result {
            case .success(let json):
                print(json)
                let code = json["code"].intValue
                let message = json["message"].stringValue
                let points = json["data"].arrayValue
                
                for point in points {
                    porintsArray.append(self.parsePoint(point: point))
                }
                complition(code,porintsArray,message)
                
            case .failure(let error):
                print("ERROR RETRIVING VOUCHERS IN VOUCHER CONTENT \(error)")
                complition(401,nil,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
            }
        }
    }
    
    private func parsePoint(point: JSON) -> LatestExpirePoints {
        
        let id = point["id"].intValue
        let original = point["original"].intValue
        let redeemed = point["redeemed"].intValue
        let available_points = point["available_points"].intValue
        let status = point["status"].stringValue
        let used_at = point["used_at"].stringValue
        let refunded_at = point["refunded_at"].string
        let created_at = point["created_at"].stringValue
        let invoice_number = point["invoice_number"].intValue
        let valid_end_date = point["valid_end_date"].stringValue
        let pending_end_date = point["pending_end_date"].stringValue
        let is_pending = point["is_pending"].boolValue
        let is_used = point["is_used"].boolValue
        let is_valid = point["is_valid"].boolValue
        let is_expired = point["is_expired"].boolValue
        let is_refunded = point["is_refunded"].boolValue
        
        return LatestExpirePoints(id: id, original: original, redeemed: redeemed, available_points: available_points, status: status, is_used: is_used, is_refunded: is_refunded, is_valid: is_valid, is_pending:is_pending, is_expired: is_expired, pending_end_date: pending_end_date, valid_end_date: valid_end_date, used_at: used_at, refunded_at: refunded_at, created_at: created_at, invoice_number: invoice_number)
    }
}
