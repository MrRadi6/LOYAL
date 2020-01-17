//
//  Connection.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/4/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct RequestAPI {
    
    private let baseURL = "http://dev.soleekhub.com/lolo/public/api/"
    private let language: Language
    private var url: String
    private let requestType: RequestType
    
    init(requestType: RequestType, language: Language) {
        self.language = language
        self.requestType = requestType
        url = baseURL
        url += getEndpoint(requestType: requestType)
    }
    
    func makePostRequest(params: [String : String], _ postHeader:[String:String]? = nil, complition: @escaping(Result <JSON>) -> ()) {
        var header: [String : String]
        
        switch language {
        case .English:
            header = ["Content-Type" : "application/json", "Accept": "application/json", "locale" : "en"]
        case .Arabic:
            header = ["Content-Type" : "application/json", "Accept": "application/json" ,"locale" : "ar"]
        }
        
        if let postHeader = postHeader {
            for (key,value) : (String,String) in postHeader{
                header.updateValue(value, forKey: key)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            Alamofire.request(self.url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).validate(contentType: ["application/json"]).responseJSON { (response) in
                
                switch response.result {
                case .success(let val):
                    complition(.success(JSON(val)))
                case .failure(let err):
                    complition(.failure(err))
                }
            }
        }
        
    }
    
    func makeGetRequest(_ getHeader:[String:String]? = nil, complition: @escaping(Result <JSON>) -> ()) {
        var header: [String : String]
        
        switch language {
        case .English:
            header = ["Content-Type" : "application/json", "Accept": "application/json", "locale" : "en"]
        case .Arabic:
            header = ["Content-Type" : "application/json", "Accept": "application/json" ,"locale" : "ar"]
        }
        
        if let getHeader = getHeader {
            for (key,value) : (String,String) in getHeader{
                header.updateValue(value, forKey: key)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            
            Alamofire.request(self.url, method: .get, parameters: nil, headers: header).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    complition(.success(JSON(value)))
                case .failure(let err):
                    complition(.failure(err))
                }
            }
        }
        
    }
    
    func makeGetRequest(params: [String:String],_ getHeader:[String:String]? = nil, complition: @escaping(Result <JSON>) -> ()) {
        var header: [String : String]
        
        switch language {
        case .English:
            header = ["Content-Type" : "application/json", "Accept": "application/json", "locale" : "en"]
        case .Arabic:
            header = ["Content-Type" : "application/json", "Accept": "application/json" ,"locale" : "ar"]
        }
        
        if let getHeader = getHeader {
            for (key,value) : (String,String) in getHeader{
                header.updateValue(value, forKey: key)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            Alamofire.request(self.url, method: .get, parameters: params, headers: header).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    complition(.success(JSON(value)))
                case .failure(let err):
                    complition(.failure(err))
                }
            }
        }
        
    }
    
    private func getEndpoint(requestType: RequestType) -> String{
        var endpoint: String
        
        switch requestType {
        case .Signin:
            endpoint = "mobile/login"
        case .Signup:
            endpoint = "mobile/register"
        case .verify:
            endpoint = "mobile/verify"
        case .ResendCode:
            endpoint = "mobile/resend"
        case .imageUpload:
            endpoint = "store"
        case .SocialLogin:
            endpoint = "mobile/login/social"
        case .CompleteSignup:
            endpoint = "mobile/signup/complete"
        case .ValidateUser:
            endpoint = "mobile/validate"
        case .PhoneVerify:
            endpoint = "mobile/phone/verify"
        case .ResetPassword:
            endpoint = "mobile/reset"
        case .Logout:
            endpoint = "logout"
        case .HomeContent:
            endpoint = "mobile/home"
        case .Rewards:
            endpoint = "rewards"
        case .Redeem:
            endpoint = "mobile/redeem"
        case .Vouchers:
            endpoint = "vouchers"
        case .UpdateProfile:
            endpoint = "mobile/profile"
        case .ChangePassword:
            endpoint = "mobile/password"
        case .MakeReport:
            endpoint = "mobile/report"
        case .HistoryPoints:
            endpoint = "mobile/history/points"
        case .UpdatePhone:
            endpoint = "mobile/phone"
        }
        
        return endpoint
    }
    
}
