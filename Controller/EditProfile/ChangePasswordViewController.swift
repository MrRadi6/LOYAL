//
//  ChangePasswordViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordView: BorderTextField!
    @IBOutlet weak var newPasswordView: BorderTextField!
    @IBOutlet weak var confirmPasswordView: BorderTextField!
    @IBOutlet weak var changePasswordButton: LoginButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewContainer: UIView!
    @IBOutlet weak var navBar: EditProfileNavBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.parentViewController = self
        disableResponseAlert()
        configureMainView()
        configureTextFields()
        changePasswordButton.addTarget(self, action: #selector(handleChangePassword), for: .touchUpInside)
        navBar.addTarget(target: self, action: #selector(handleDismiss))
        // Do any additional setup after loading the view.
    }
    
    private func configureMainView() {
        mainViewContainer.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCloseKeyboard))
        mainViewContainer.addGestureRecognizer(tapGesture)
    }
    
    private func configureTextFields() {
        oldPasswordView.setDelegate(delegate: self)
        newPasswordView.setDelegate(delegate: self)
        confirmPasswordView.setDelegate(delegate: self)
        
        oldPasswordView.addTargetForButton(target: self, action: #selector(handleShowOldPassword), forEvent: .touchUpInside)
        newPasswordView.addTargetForButton(target: self, action: #selector(handleShowNewPassword), forEvent: .touchUpInside)
        confirmPasswordView.addTargetForButton(target: self, action: #selector(handleShowConfirmPassword), forEvent: .touchUpInside)
        
        oldPasswordView.addTarget(target: self, action: #selector(handleVerifyOldPassword), forEvent: .editingChanged)
        newPasswordView.addTarget(target: self, action: #selector(handleVerifyNewPassword), forEvent: .editingChanged)
        confirmPasswordView.addTarget(target: self, action: #selector(handleVerifyConfirmPassword), forEvent: .editingChanged)
        
        oldPasswordView.setTitle(title: NSLocalizedString("Old password", comment: "Old password"))
        oldPasswordView.setPlaceHolder(placeholder: NSLocalizedString("Old password", comment: "Old password"))
        
        newPasswordView.setTitle(title: NSLocalizedString("New password", comment: "New password"))
        newPasswordView.setPlaceHolder(placeholder: NSLocalizedString("New password", comment: "New password"))
        
        confirmPasswordView.setTitle(title: NSLocalizedString("Confirm New password", comment: "Confirm New password"))
        confirmPasswordView.setPlaceHolder(placeholder: NSLocalizedString("Confirm New password", comment: "Confirm Old password"))
    }
    
    @objc func handleDismiss() {
        dismiss(animated: false, completion: nil)
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
        }
    }
    
    @objc private func handleChangePassword() {
        guard let token = UserData.getUserData()?.token else {
            fatalError("USER DATA NOT SET IN USER DEFAULTS")
        }
        let language = Verification.init().getCurrentLanguage()
        if !Verification.init().verifyPassword(password: oldPasswordView.getText()) || !Verification.init().verifyPassword(password: newPasswordView.getText()) || newPasswordView.getText() != confirmPasswordView.getText() {
            handleVerifyOldPassword()
            handleVerifyNewPassword()
            handleVerifyConfirmPassword()
            return
        }
        if !Connection.init().checkInterConnectivity(){
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                
            }
            return
        }
        
        let loadingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingScreen") as! LoadingViewController
        present(loadingVC, animated: false, completion: nil)
        
        ChangePassword.init(token: token, oldPassword: oldPasswordView.getText(), newPassword: newPasswordView.getText(), language: language).changePassword { (code, message) in
            if code == 200 {
                print(code)
                print(message)
                loadingVC.dismiss(animated: false, completion: {
                    self.disableResponseAlert()
                    self.dismiss(animated: false, completion: nil)
                })
                
            }
            else if code == 401 {
                loadingVC.dismiss(animated: false, completion: {
                    self.enableResponseAlert(message: "Client Error")
                })
            }
            else {
                loadingVC.dismiss(animated: false, completion: {
                    self.enableResponseAlert(message: message)
                })
            }
        }
        
    }
    
    @objc private func handleCloseKeyboard() {
        DispatchQueue.main.async {
            self.oldPasswordView.resignResponder()
            self.newPasswordView.resignResponder()
            self.confirmPasswordView.resignResponder()
        }
    }
    
    @objc private func handleShowOldPassword() {
        oldPasswordView.flipSecureText()
    }
    
    @objc private func handleShowNewPassword() {
        newPasswordView.flipSecureText()
    }
    
    @objc private func handleShowConfirmPassword() {
        confirmPasswordView.flipSecureText()
    }
    
    @objc private func handleVerifyOldPassword() {
        checkUserInputs()
        if !Verification.init().verifyPassword(password: oldPasswordView.getText()) {
            let language = Verification.init().getCurrentLanguage()
            let alertString = language == .English ? "Enter valid password, min 8 characters" : "أدخل كلمة مرور صالحة ، بحد أدنى 8 أحرف"
            oldPasswordView.enableAlert(message: alertString)
        } else {
            oldPasswordView.disableAlert()
        }
    }
    
    @objc private func handleVerifyNewPassword() {
        checkUserInputs()
        if !Verification.init().verifyPassword(password: newPasswordView.getText()) {
            let language = Verification.init().getCurrentLanguage()
            let alertString = language == .English ? "Enter valid password, min 8 characters" : "أدخل كلمة مرور صالحة ، بحد أدنى 8 أحرف"
            newPasswordView.enableAlert(message: alertString)
        }
        else {
            newPasswordView.disableAlert()
        }
    }
    
    @objc private func handleVerifyConfirmPassword() {
        checkUserInputs()
        if newPasswordView.getText() != confirmPasswordView.getText() {
            let language = Verification.init().getCurrentLanguage()
            let alertString = language == .English ? "Password dose not match" : "كلمة السر غير متطابقة"
            confirmPasswordView.enableAlert(message: alertString)
        } else {
            confirmPasswordView.disableAlert()
        }
    }
    
    private func checkUserInputs() {
        if oldPasswordView.getText().count > 0 && newPasswordView.getText().count > 0 && confirmPasswordView.getText().count > 0 {
            enableChangePasswordButton()
        } else {
            disableChangePasswordButton()
        }
    }
    
    private func disableChangePasswordButton() {
        DispatchQueue.main.async {
            self.changePasswordButton.isEnabled = false
            self.changePasswordButton.backgroundColor = UIColor(named: "inActiveColor")
        }
    }
    
    private func enableChangePasswordButton() {
        DispatchQueue.main.async {
            self.changePasswordButton.isEnabled = true
            self.changePasswordButton.backgroundColor = UIColor(named: "PrimaryColor")
        }
    }

}

extension ChangePasswordViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       handleCloseKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleCloseKeyboard()
        return true
    }
}
