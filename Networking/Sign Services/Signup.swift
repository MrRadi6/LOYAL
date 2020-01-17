//
//  Signup.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/5/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import SwiftyJSON

class Signup {
    
    private let language: Language
    private let country_code: String
    private let phone: String
    private let name: String
    private let email: String
    private let password: String
    private var imageURL: String?

    init(language: Language, country_code: String, phone: String, name: String, email: String, password: String, imageURL: String?) {
        self.language = language
        self.country_code = country_code
        self.phone = phone
        self.name = name
        self.email = email
        self.password = password
        self.imageURL = imageURL
    }
    
    func signup(complition: @escaping (_ userData :UserData?,_ code: Int, _ message: String) -> ()) {
        
        let requestAPI = RequestAPI(requestType: .Signup, language: language)
        DispatchQueue.global(qos: .background).async {
            let signupResquest = ["country_code":self.country_code, "phone":self.phone, "name":self.name, "email":self.email, "password": self.password, "image":self.imageURL ?? ""]
            print(signupResquest)
            requestAPI.makePostRequest(params: signupResquest) { (result) in
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
                    complition(userData,code, message)
                case .failure(let err):
                    complition(nil,401,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
                    print(err)
                }
            }
        }
        
    }
    
}
