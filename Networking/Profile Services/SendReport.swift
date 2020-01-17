//
//  Report.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/23/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON


class SendReport {
    
    private let requestAPI: RequestAPI
    private let token: String
    private var image: String?
    private let language: Language
    private let message: String
    
    init(token: String, message: String,language: Language, image: String?) {
        requestAPI = RequestAPI(requestType: .MakeReport, language: language)
        self.message = message
        self.token = token
        self.image = image
        self.language = language
    }
    
    func sendReport(complition: @escaping (_ code: Int,_ message: String) -> ()) {
        
        let params: [String : String]
        let header = ["Authorization" : "Bearer \(token)"]
        if let image = image {
            params = ["message" : message, "attachment":image]
        }
        else {
            params = ["message" : message]
        }
        
        requestAPI.makePostRequest(params: params, header) { (result) in
            switch result {
            case .success(let json):
                let code = json["code"].intValue
                let message = json["message"].stringValue
                complition(code,message)
            case .failure(let error):
                print(error)
                complition(401,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
            }
        }
    }
}
