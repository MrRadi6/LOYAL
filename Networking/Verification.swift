//
//  Verification.swift
//  LoyalApp
//
//  Created by Ahmed Samir on 7/4/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import Foundation
import UIKit

struct Verification {
    
    func verifyPassword(password: String) -> Bool {
        return password.count >= 8
    }
    
    func verifyNumber(number: String) -> Bool {
        let numberRegex = "^\\d{8,14}"
        return NSPredicate(format: "SElF MATCHES %@", numberRegex).evaluate(with: number)
    }
    
    func validateName(name: String) -> Bool{
        return ( name != " " && name != "")
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9]+\\.[A-Za-z]{2,62}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    func isMorningTime() -> Bool {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: date) == "AM"
    }
    
    func configureViewWithTime(viewController: UIViewController){
        viewController.view.backgroundColor = (isMorningTime()) ? UIColor.white : UIColor(named: "PrimaryColor")
    }
    
    func getCurrentLanguage() -> Language{
        let language: [String] = UserDefaults.standard.value(forKey: "AppleLanguages") as! [String]
        if language[0] == "ar"{
            return .Arabic
        }
        return .English
    }
    
    func calcRemaininDays(validTo: String) -> Int{
        var days = 0
        let formatter = DateFormatter()
        let currentData = Date()
        let calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let validData = formatter.date(from: validTo) {
            let date1 = calendar.startOfDay(for: currentData)
            let date2 = calendar.startOfDay(for: validData)
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            days = components.day ?? 0
        }
        return days
    }
    
    func getFormatedDateAndTimeString(rawDate: String) -> String {
        let dateString = getFormatedDate(rawDate: rawDate)
        let timeString = getFormatedTime(rawDate: rawDate)
        let formatedDate = "\(dateString) \(NSLocalizedString("atTime", comment: "atTime")) \(timeString)"
        return formatedDate
        
    }
    
    func getFormatedDate(rawDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: rawDate) {
            formatter.dateFormat = "MMM d, yyyy"
            let formatedDate = formatter.string(from: date)
            return (getCurrentLanguage() == .English) ? formatedDate : formatedDate.translateNumbersToArabic()
        }
        else {
            return "date unavailable"
        }
    }
    
    func getFormatedTime(rawDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: rawDate) {
            formatter.dateFormat = "h:mm a"
            let formatedTime = formatter.string(from: date)
            return (getCurrentLanguage() == .English) ? formatedTime : formatedTime.translateNumbersToArabic()
        }
        else {
            return "date unavailable"
        }
    }
    
    func makeConnectionAlert(parentView: UIViewController,error:AlertError,message: String?,complition: @escaping () -> ()) {
        
        var actionTitle: String = "OK"
        var title:String
        var alertMessage: String
        
         if getCurrentLanguage() == .Arabic {
            actionTitle = "حسنا"
            switch error {
                
            case .InternelServerError:
                title = "خطأ في الخادم الداخلي"
                alertMessage = message ?? "حدث خطأ في الخادم"
            case .BadRequest:
                title = "خطأ العميل"
                alertMessage = message ?? "فشل الاتصال بالخادم"
            case .ReachibilityError:
                title = "لا يوجد اتصال إنترنت"
                alertMessage = "هناك مشكلة في اتصالك بالإنترنت ، أعد الاتصال وحاول مرة أخرى"
            }
        }
        else {
            switch error {
            case .InternelServerError:
                title = "Internel Server Error"
                alertMessage = message ?? "An Error occured in Server"
            case .BadRequest:
                title = "Client Error"
                alertMessage = message ?? "Failed to connecto to the server"
            case .ReachibilityError:
                title = "No Internet Connection"
                alertMessage = "There is a problem with your internet connection, Reconnect and try again"
            }
            
        }
        
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        parentView.present(alert, animated: true){
            complition()
        }
        
    }
}
