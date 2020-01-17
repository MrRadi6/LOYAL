//
//  Connection.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/6/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import  UIKit

class Connection {
    
    func checkInterConnectivity(parentView: UIViewController) -> Bool{
        let reachability = try! Reachability()
        var isReachable = false
        
        if !reachability.isReachable {
            makeConnectionAlert(parentView: parentView)
        } else {
            isReachable = true
        }
        
        return isReachable
    }
    
    func checkInterConnectivity() -> Bool {
        let reachability = try! Reachability()
        return reachability.isReachable
    }
    
    private func makeConnectionAlert(parentView: UIViewController) {
        var title: String
        var message: String
        var actionTitle: String
        
        let language: [String] = UserDefaults.standard.value(forKey: "AppleLanguages") as! [String]
        if language[0] == "en" {
            title = "Internet Connection"
            message = "There is a problem with your internet connection, Reconnect and try again"
            actionTitle = "OK"
        } else {
            title = "اتصال إنترنت"
            message = "هناك مشكلة في اتصالك بالإنترنت، أعد الاتصال وحاول مرة أخرى"
            actionTitle = "حسنا"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        DispatchQueue.main.async {
            parentView.present(alert, animated: true, completion: nil)
        }
        
    }

}
