//
//  LatestVouchers.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/4/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

struct LatestVouchers {
    
    var id: Int
    var user_id: Int
    var qr_code: Int
    var title: String
    var used_at: String
    var invoice_number: Int
    var valid_end_date: String
    var status: String
    var is_used: Bool
    var is_valid: Bool
    var is_expired: Bool
    var created_at: String
    
    func generateQRCode() -> UIImage? {
        let codeString = String(qr_code)
        let data = codeString.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }


}
