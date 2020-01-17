//
//  Ads.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/5/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class Ads {
    
    let adURL: String
    var image: UIImage
    
    init(adURL: String){
        self.adURL = adURL
        self.image = UIImage(named: "AdsPlaceholder")!
        downloadAdsImages()
    }
    
    func downloadAdsImages(){
        DispatchQueue.global().async {
            DownloadAPI.init().downloadImage(urlString: self.adURL) { (result) in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        self.image = image
                    }
                case .failure(let error):
                    print("ERROR DOWNLOADING IMAGE ------> \(error)")
                }
            }
        }
        
    }
}
