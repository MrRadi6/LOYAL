//
//  UploadAPI.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/9/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct UploadAPI {
    
    let endpoint = "http://dev.soleekhub.com/lolo/public/api/store"
    let imageData: Data
    let language: Language
    
    func uploadImage(complition: @escaping(Result<(imageURL:String,code:Int,message:String)>) -> ()){
        var header: [String : String]
        let uuid = UUID.init().uuidString
        
        switch language {
        case .English:
            header = ["locale": "en"]
        case .Arabic:
            header = ["locale": "ar"]
        }
        DispatchQueue.global(qos: .background).async {
            Alamofire.upload(multipartFormData: { multiPartFromData in
                multiPartFromData.append(self.imageData, withName: "image",fileName: "\(uuid).jpeg",mimeType: "image/jpeg")},
                             to:self.endpoint,
                             method:.post,
                             headers: header,
                             encodingCompletion: { (encodingResults) in
                                switch encodingResults {
                                case .success(let uploadRequest , _, _):
                                    uploadRequest.responseJSON(completionHandler: { (response) in
                                        let result = response.result
                                        switch result {
                                        case .success(let val):
                                            let json = JSON(val)
                                            complition(.success(self.getImageInfo(json: json)))
                                        case .failure(let err):
                                            complition(.failure(err))
                                        }
                                    })
                                case .failure(let err):
                                    complition(.failure(err))
                                }
            })
        }
        
    }
    
    private func getImageInfo(json: JSON) -> (imageURL:String,code:Int,message:String) {
       
        let code = json["code"].intValue
        let message = json["message"].stringValue
        let data = JSON(json["data"])
        let url = data["image"].stringValue
        return (url,code,message)
    }
    
}
