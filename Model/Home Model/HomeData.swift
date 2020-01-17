//
//  HomeData.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/20/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import SwiftyJSON

class HomeData {
    
    var total_points: Int?
    var total_expire: Int?
    var latest_expire: String?
    var latest_expire_points: [JSON]?
    var ads: [String]?
    var trending_rewards: [JSON]?
    var latest_vouchers: [JSON]?
    var policies: String?
    var terms_conditions: String?
    var about: String?
    
    init(total_points: Int?, total_expire: Int?, latest_expire: String?, latest_expire_points: [JSON]?, ads: [String]?, trending_rewards: [JSON]?, latest_vouchers: [JSON]?,policies: String?,terms_conditions: String?,about: String?) {
        self.total_points = total_points
        self.total_expire = total_expire
        self.latest_expire = latest_expire
        self.latest_expire_points = latest_expire_points
        self.ads = ads
        self.trending_rewards = trending_rewards
        self.latest_vouchers = latest_vouchers
        self.policies = policies
        self.terms_conditions = terms_conditions
        self.about = about
    }
    
    func getTotalPoint() -> Int {
        return total_points ?? 0
    }
    
    func getTotalExpire() -> Int {
        return total_expire ?? 0
    }
    
    func getLatestExpire() -> String {
        return latest_expire ?? "NO Expiraton Date"
    }
    
    func getLatestExpirePoints() -> [LatestExpirePoints] {
        var latestExpirePointsArray: [LatestExpirePoints] = []
        
        if let latest_expire_points = latest_expire_points {
            for json in latest_expire_points {
                let id = json["id"].intValue
                let original = json["original"].intValue
                let redeemed = json["redeemed"].intValue
                let available_points = json["available_points"].intValue
                let status = json["status"].stringValue
                let is_used = json["is_used"].boolValue
                let is_refunded = json["is_refunded"].boolValue
                let is_valid = json["is_valid"].boolValue
                let is_pending = json["is_pending"].boolValue
                let is_expired = json["is_expired"].boolValue
                let pending_end_date = json["pending_end_date"].stringValue
                let valid_end_date = json["valid_end_date"].stringValue
                let used_at = json["used_at"].string
                let refunded_at = json["refunded_at"].string
                let created_at = json["created_at"].stringValue
                
                latestExpirePointsArray.append(LatestExpirePoints(id: id, original: original, redeemed: redeemed, available_points: available_points, status: status, is_used: is_used, is_refunded: is_refunded, is_valid: is_valid, is_pending: is_pending, is_expired: is_expired, pending_end_date: pending_end_date, valid_end_date: valid_end_date, used_at: used_at, refunded_at: refunded_at, created_at: created_at,invoice_number: nil))
            }
        }
        return latestExpirePointsArray
    }
    
    func getAds() -> [Ads] {
        var adsImages: [Ads] = []
        if let ads = ads {
            for url in ads {
                adsImages.append(Ads(adURL: url))
            }
        }
        
        return adsImages
    }
    
    func getTrendingReward() -> [TrendingReward] {
        var trendingRewardArray: [TrendingReward] = []
        
        if let trending_rewards = trending_rewards {
            for json in trending_rewards {
                let id = json["id"].intValue
                let points = json["points"].intValue
                let title = json["title"].stringValue
                let description = json["description"].stringValue
                let imageURL = json["image"].stringValue
                
                trendingRewardArray.append(TrendingReward(id: id, points: points, title: title, description: description, imageURL: imageURL))
            }
        }
        return trendingRewardArray
    }

    func getLatestVoucher() -> [LatestVouchers] {
        var LatestVoucherArray: [LatestVouchers] = []
        if let latest_vouchers = latest_vouchers {
            for json in latest_vouchers {
                let id = json["id"].intValue
                let user_id = json["user_id"].intValue
                let qr_code = json["qr_code"].intValue
                let title = json["title"].stringValue
                let used_at = json["used_at"].stringValue
                let invoice_number = json["invoice_number"].intValue
                let valid_end_date = json["valid_end_date"].stringValue
                let status = json["status"].stringValue
                let is_used = json["is_used"].boolValue
                let is_valid = json["is_valid"].boolValue
                let is_expired = json["is_expired"].boolValue
                let created_at = json["created_at"].stringValue

                LatestVoucherArray.append(LatestVouchers(id: id, user_id: user_id, qr_code: qr_code, title: title, used_at: used_at, invoice_number: invoice_number, valid_end_date: valid_end_date, status: status, is_used: is_used, is_valid: is_valid, is_expired: is_expired, created_at: created_at))
            }
           
        }
        return LatestVoucherArray
    }
    
}
