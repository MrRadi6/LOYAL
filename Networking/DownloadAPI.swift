//
//  DownloadAPI.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/11/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Alamofire

class DownloadAPI {
    
   
    
    func downloadImage(urlString: String,complition: @escaping (Result<Data>) -> () ){
        DispatchQueue.global(qos: .background).async {
            Alamofire.request(urlString, method: .get).responseData { (response) in
                if let data = response.data {
                    complition(.success(data))
                } else {
                    complition(.failure(ConnectionError.DownloadImageError))
                }
            }
        }
        
    }
}

