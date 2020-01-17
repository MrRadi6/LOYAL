//
//  Logout.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/13/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import SwiftyJSON

class Logout {
    
    private let logoutRequest: [String : String]
    private let requestAPI: RequestAPI
    private let token: String
    
    init(token: String, language: Language) {
        requestAPI = RequestAPI(requestType: .Logout, language: language)
        self.token = token
        self.logoutRequest = [:]
    }
    
    func logout(complition: @escaping (_ userData:UserData,_ code: Int,_ message: String) -> ()) {
        requestAPI.makePostRequest(params: logoutRequest,["Authorization":"Bearer \(token)"]) { (result) in
            switch result {
            case .success(let json):
                print(json)
                guard let code = json["code"].int, let message = json["message"].string else {
                    print("failed to parse json in signin")
                    return
                }
                let data = JSON(json["data"])
                let id = data["id"].intValue
                let email = data["email"].stringValue
                let phone = data["phone"].stringValue
                let country_code = data["country_code"].stringValue
                let image = data["image"].stringValue
                let name = data["name"].stringValue
                let token = data["token"].stringValue
                let qr_code = data["qr_code"].stringValue
                
                let userData = UserData(id: id, email: email, phone: phone, country_code: country_code, image: image, name: name, token: token,qr_code: qr_code)
                
                complition(userData, code, message)
            case .failure(let err):
                print(err)
            }
        }
    }
    
}
