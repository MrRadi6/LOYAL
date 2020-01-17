//
//  ChangePhoneViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class ChangePhoneViewController: UIViewController {

    @IBOutlet weak var navBar: EditProfileNavBar!
    @IBOutlet weak var countryButton: CountryCodeButton!
    @IBOutlet weak var phoneView: BorderTextField!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var countryCodeFlag: UIImageView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendSMSButton: LoginButton!
    @IBOutlet weak var mainContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Verification.init().configureViewWithTime(viewController: self)
        countryButton.layer.borderColor = UIColor.gray.cgColor
        navBar.parentViewController = self
        phoneView.setDelegate(delegate: self)
        phoneView.setTitle(title: NSLocalizedString("Phone", comment: "Phone"))
        phoneView.setPlaceHolder(placeholder: NSLocalizedString("Phone", comment: "Phone"))
        sendSMSButton.addTarget(self, action: #selector(handleSendSMS), for: .touchUpInside)
        phoneView.addTarget(target: self, action: #selector(handleVerifyPhoneNumber), forEvent: .editingChanged)
        configureCurrentCountryCode()
        disableResponseAlert()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        mainContainer.addGestureRecognizer(tapGesture)
        navBar.addTarget(target: self, action: #selector(handleDismiss))
        
        // Do any additional setup after loading the view.
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func handleSendSMS() {
        guard  let userData = UserData.getUserData() else {
            fatalError("USET DATA NOT SET YET IN USER DEFAULTS")
        }
        let language = Verification.init().getCurrentLanguage()
        let token = userData.token
        let countryCode = userData.country_code
        
        if !Verification.init().verifyNumber(number: phoneView.getText()) {
            return
        }
        
        if !Connection.init().checkInterConnectivity() {
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                
            }
            return
        }
        let loadingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingScreen") as! LoadingViewController
        present(loadingVC, animated: false, completion: nil)
        
        UpdatePhone.init(token: token, countryCode: countryCode, phoneNumber: phoneView.getText(), language: language).uodatePhoenNumber { (code, message) in
            print(code)
            print(message)
            if code == 200 {
                self.disableResponseAlert()
                let verifyVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerifyPhoneViewController") as! VerifyPhoneViewController
                loadingVC.dismiss(animated: false, completion: {
                    self.present(verifyVC, animated: true, completion: {
                        verifyVC.delegate = self
                        verifyVC.countryCode = countryCode
                        verifyVC.phoneNumber = self.phoneView.getText()
                    })
                })
            }
            else {
               self.enableResponseAlert(message: message)
                loadingVC.dismiss(animated: false, completion: nil)
            }
        }
        
    }
    
    @objc private func handleVerifyPhoneNumber() {
        if !Verification.init().verifyNumber(number: phoneView.getText()) {
            let language = Verification.init().getCurrentLanguage()
            let alertString = language == .English ? "phone should be from 8 to 14 numbers" : "يجب أن يكون الهاتف من 8 إلى 14 رقمًا"
            phoneView.enableAlert(message: alertString)
        }
        else {
            phoneView.disableAlert()
        }
        
        if phoneView.getText().isEmpty {
            disableSendButton()
        }
        else {
           enableSendButton()
        }
    }
    
    @objc private func handleDismissKeyboard() {
        DispatchQueue.main.async {
            self.phoneView.resignResponder()
        }
    }
    
    private func enableResponseAlert(message: String) {
        DispatchQueue.main.async {
            self.alertHeightConstraint.constant = 60
            self.alertLabel.text = message
        }
    }
    
    private func disableResponseAlert() {
        DispatchQueue.main.async {
            self.alertHeightConstraint.constant = 0
            self.alertLabel.text = ""
        }
    }
    
    private func enableSendButton() {
        sendSMSButton.isEnabled = true
        sendSMSButton.backgroundColor = UIColor(named: "PrimaryColor")
    }
    
    private func disableSendButton() {
        sendSMSButton.isEnabled = false
        sendSMSButton.backgroundColor = UIColor(named: "inActiveColor")
        
    }
    
    private func configureCurrentCountryCode(){
        guard let userCountryCode = UserData.getUserData()?.country_code else {
            fatalError("USER DATA NOT SET IN USER DEFAULTS")
        }
        print(userCountryCode)
        let countryName = Countries.init().getCountryNameFromDialCode(code: userCountryCode)
       setountryButton(countryName: countryName, CountryCode: userCountryCode)
    }
    
    private func setountryButton(countryName: String, CountryCode: String) {
        countryCodeLabel.text = "+\(CountryCode)"
        if let image = UIImage(named: countryName){
            countryCodeFlag.image = image
        } else {
            countryCodeFlag.image = UIImage(named: "defaultFlag")
        }
    }

}

extension ChangePhoneViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.phoneView.resignResponder()
        }
        return true
    }
}

extension ChangePhoneViewController : VerifyPhoneDelegate {
    func verifiyPhone(code: Int, message: String, userData: UserData) {
        print(code)
        print(message)
        if code == 200 {
            self.disableResponseAlert()
            userData.saveUserData()
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.enableResponseAlert(message: message)
        }
    }
    
    
}
