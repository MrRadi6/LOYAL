//
//  ChangePassword.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/22/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChangePassword {
    
    private let requestAPI: RequestAPI
    private let token: String
    private let oldPassword: String
    private let newPassword: String
    
    init(token: String, oldPassword: String, newPassword: String, language: Language) {
        requestAPI = RequestAPI(requestType: .ChangePassword, language: language)
        self.token = token
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
    
    func changePassword(complition: @escaping (_ code: Int,_ message: String) -> () ) {
        let params = ["old_password" : oldPassword, "password":newPassword]
        let header = ["Authorization" : "Bearer \(token)"]
        
        requestAPI.makePostRequest(params: params, header) { (result) in
            switch result {
            case .success(let json):
                let code = json["code"].intValue
                let message = json["message"].stringValue
                complition(code,message)
            case .failure(let _):
                complition(401,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
            }
        }
    }
}
