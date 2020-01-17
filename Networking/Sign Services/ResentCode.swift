//
//  ResentCode.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/10/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import SwiftyJSON

class ResendCode {
    
    private let resendRequest: [String : String]
    private let requestAPI: RequestAPI
    
    init(countryCode: String,phoneNumber: String, language: Language) {
        requestAPI = RequestAPI(requestType: .ResendCode, language: language)
        self.resendRequest = ["country_code":countryCode,"phone": phoneNumber]
    }
    
    func verify(complition: @escaping (_ code: Int,_ message: String) -> ()) {
        requestAPI.makePostRequest(params: resendRequest) { (result) in
            switch result {
            case .success(let json):
                guard let code = json["code"].int, let message = json["message"].string else {
                    return
                }
                complition(code, message)
            case .failure(let err):
                complition(401,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
                print(err)
            }
        }
    }
    
}
