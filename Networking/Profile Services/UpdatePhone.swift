//
//  UpdatePhone.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/24/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON

class UpdatePhone {
    
    private let requestAPI: RequestAPI
    private let token: String
    private let countryCode: String
    private let phoneNumber: String
    
    init(token: String, countryCode: String, phoneNumber: String, language: Language) {
        requestAPI = RequestAPI(requestType: .UpdatePhone, language: language)
        self.token = token
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }
    
    func uodatePhoenNumber(complition: @escaping (_ code: Int,_ message: String) -> ()  ) {
        
        let params = ["country_code" : countryCode, "phone":phoneNumber]
        let header = ["Authorization" : "Bearer \(token)"]
        
        requestAPI.makePostRequest(params: params, header) { (result) in
            switch result {
            case .success(let json):
                print(json)
                let code = json["code"].intValue
                let message = json["message"].stringValue
                complition(code,message)
            case .failure(let error):
               complition(401,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
            }
        }
    }
    
}
