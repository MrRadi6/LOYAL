//
//  RedeemReward.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/8/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON

class RedeemReward {
    
    private let requestAPI: RequestAPI
    private let token: String
    
    init(token: String, language: Language) {
        requestAPI = RequestAPI(requestType: .Redeem, language: language)
        self.token = token
    }
    
    func redeem(id: Int,complition: @escaping (_ code:Int,_ message:String) -> ()){
        let params = ["voucher_id":"\(id)"]
        let header = ["Authorization":"Bearer \(token)"]
        
        requestAPI.makePostRequest(params: params, header) { (result) in
            switch result {
            case .success(let json):
                let message = json["message"].stringValue
                let code = json["code"].intValue
                complition(code,message)
            case .failure(let error):
                complition(401,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
                print("ERROR REDEEMING REWARD \(error)")
            }
        }
    }
}
