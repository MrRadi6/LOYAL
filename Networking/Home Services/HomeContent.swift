//
//  HomeContent.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/20/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import SwiftyJSON

class HomeContent {
    
    private let requestAPI: RequestAPI
    private let token: String
    
    init(token: String, language: Language) {
        requestAPI = RequestAPI(requestType: .HomeContent, language: language)
        self.token = token
    }
    
    func getHomeContent(complition: @escaping (_ code:Int,_ data:HomeData?,_ message:String) -> ()){
        let header = ["Authorization" : "Bearer \(token)"]
        requestAPI.makeGetRequest(header) { (result) in
            switch result {
            case .success(let json):
                let code = json["code"].intValue
                let message = json["message"].stringValue
                
                if code == 200 {
                    let totalPoints = json["data"]["total_valid"].int
                    let totalExpire = json["data"]["total_expiring"].int
                    let latestExpire = json["data"]["latest_expiring_points_date"].string
                    let latestExpirePoints = json["data"]["expiring_points"].array
                    let ads = json["data"]["ads"].arrayObject as! Array<String>
                    let trendingRewards = json["data"]["trending_rewards"].array
                    let latestVoucher = json["data"]["latest_vouchers"].array
                    let policies = json["data"]["policies"].stringValue
                    let terms_conditions = json["data"]["terms_conditions"].stringValue
                    let about = json["data"]["about"].stringValue
                    
                    let homeData = HomeData(total_points: totalPoints, total_expire: totalExpire, latest_expire: latestExpire, latest_expire_points: latestExpirePoints, ads: ads, trending_rewards: trendingRewards, latest_vouchers: latestVoucher,policies: policies,terms_conditions: terms_conditions,about: about)
                    complition(code,homeData,message)
                } else {
                    complition(code,nil,message)
                }
                
            case .failure(let error):
                complition(401,nil,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
                print("ERROR getting home content ---------> \(error)")
            }
        }
    }
}
