//
//  TrendingReward.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/4/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class TrendingReward {
    
    var id: Int
    var points: Int
    var title: String
    var description: String
    var imageURL:String
    var backgroundImage: UIImage
    
    init(id: Int, points: Int, title: String, description: String, imageURL: String) {
        
        self.id = id
        self.points = points
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.backgroundImage = UIImage(named: "RewardPlaceholder")!
        downloadRewardsBackgound()
        
    }
    
    func downloadRewardsBackgound() {
        DispatchQueue.global().async {
            DownloadAPI.init().downloadImage(urlString: self.imageURL) { (result) in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        self.backgroundImage = image
                    }
                    else {
                        self.backgroundImage = UIImage(named: "RewardPlaceholder")!
                    }
                case .failure(let error):
                    print("ERROR DOWNLOAD REWARD BACKGROUND IMAGE: \(error)")
                    self.backgroundImage = UIImage(named: "RewardPlaceholder")!
                }
            }
        }
        
    }

}
