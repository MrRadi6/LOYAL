//
//  LatestExpirePoints.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/4/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation

struct LatestExpirePoints {
    
    var id: Int
    var original : Int
    var redeemed: Int
    var available_points: Int
    var status: String
    var is_used: Bool
    var is_refunded: Bool
    var is_valid: Bool
    var is_pending: Bool
    var is_expired: Bool
    var pending_end_date: String
    var valid_end_date: String
    var used_at:String?
    var refunded_at: String?
    var created_at: String
    var invoice_number : Int?
}
