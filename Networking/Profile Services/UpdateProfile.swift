//
//  UpdateProfile.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON

class UpdateProfile {
    
    private let requestAPI: RequestAPI
    private let token: String
    private var image: String
    private let language: Language
    private let name: String
    
    init(token: String, name: String,language: Language, image: String?) {
        guard let userData = UserData.getUserData() else {
            fatalError("USER DATA NOT SET YET IN USER DEFAULTS")
        }
        requestAPI = RequestAPI(requestType: .UpdateProfile, language: language)
        self.name = name
        self.token = token
        self.image = image ?? userData.image
        self.language = language
    }
    
    func update(complition: @escaping (_ code:Int, _ message: String,_ name: String?, _ imageURL: String?) -> ()){
       
        let header = ["Authorization" : "Bearer \(token)"]
        
        let params = ["name":name,"image":image]
    
        requestAPI.makePostRequest(params: params, header) { (result) in
            switch result {
            case .success(let json):
                let code = json["code"].intValue
                let message = json["message"].stringValue
                let name = json["data"]["name"].stringValue
                let image = json["data"]["image"].stringValue
                complition(code,message,name,image)
            case .failure(let error):
                print(error)
                complition(401,NSLocalizedString("Bad Reques", comment: "Bad Reques"),nil,nil)
            }
        }
    }
    
}
