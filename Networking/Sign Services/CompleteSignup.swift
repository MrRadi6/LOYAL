//
//  CompleteSignup.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/11/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import SwiftyJSON

class CompleteSignup {
    
    private let completeSignupRequest: [String : String]
    private let requestAPI: RequestAPI
    
    init(social_token: String,provider_name: String, language: Language,country_code: String,phone: String,name: String) {
        requestAPI = RequestAPI(requestType: .CompleteSignup, language: language)
        self.completeSignupRequest = ["social_token":social_token,"provider_name": provider_name,"country_code": country_code,"phone": phone,"name": name]
    }
    
    func signup(complition: @escaping (_ userData:UserData?,_ code:Int,_ message:String) -> ()) {
        requestAPI.makePostRequest(params: completeSignupRequest) { (result) in
            switch result {
            case .success(let json):
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
                complition(nil,401,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
            }
        }
    }
    
}
