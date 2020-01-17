//
//  RewardsContent.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/7/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import SwiftyJSON

class RewardsContent {
    
    private let requestAPI: RequestAPI
    private let token: String
    
    init(token: String, language: Language) {
        requestAPI = RequestAPI(requestType: .Rewards, language: language)
        self.token = token
    }
    
    func getRewards(page: Int,complition: @escaping (_ code:Int,_ data:[TrendingReward]?,_ message:String) -> ()) {
        
        let header = ["Authorization" : "Bearer \(token)"]
        let params = ["page":"\(page)"]
        
        requestAPI.makeGetRequest(params: params, header) { (result) in
            switch result {
            case .success(let json):
                var rewards : [TrendingReward] = []
                let code = json["code"].intValue
                let rewardsData = json["data"]["vouchers"].arrayValue
                let message = json["message"].stringValue
                
                for reward in rewardsData {
                    let points = reward["points"].intValue
                    let title = reward["title"].stringValue
                    let description = reward["description"].stringValue
                    let id = reward["id"].intValue
                    let image = reward["image"].stringValue
                    rewards.append(TrendingReward(id: id, points: points, title: title, description: description, imageURL: image))
                }
                
                complition(code,rewards,message)
            case .failure(let error):
                print("ERROR FETCHING REWARDS \(error)")
                complition(401,nil,NSLocalizedString("Bad Reques", comment: "Bad Reques"))
            }
        }
    }
}
