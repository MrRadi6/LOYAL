//
//  EditProfileViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var userImageView: ProfilePicture!
    @IBOutlet weak var addNewImageButton: UIButton!
    @IBOutlet weak var nameTextField: BorderTextField!
    @IBOutlet weak var emailTextField: BorderTextField!
    @IBOutlet weak var saveButton: LoginButton!
    @IBOutlet weak var navBar: EditProfileNavBar!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertHeightConstraint: NSLayoutConstraint!
    
    fileprivate let activityIndicator = UIActivityIndicatorView()
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate var isUploadingImage = false
    fileprivate var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertHeightConstraint.constant = 0
        navBar.parentViewController = self
        configureUserInfo()
        configureBackgroundView()
        setProfilePictureImage()
        
        addNewImageButton.addTarget(self, action: #selector(handleTakeImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(handleSaveData), for: .touchUpInside)
        nameTextField.addTarget(target: self, action: #selector(handleVerify), forEvent: .editingChanged)
        navBar.addTarget(target: self, action: #selector(handleDismiss))
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTextFields()
    }
    
    private func configureTextFields() {
        nameTextField.setTitle(title: NSLocalizedString("name", comment: "name"))
        nameTextField.setPlaceHolder(placeholder: NSLocalizedString("name", comment: "name"))
        
        emailTextField.setTitle(title: NSLocalizedString("email", comment: "email"))
        emailTextField.setPlaceHolder(placeholder: NSLocalizedString("email", comment: "email"))
        
    }
    
    @objc func handleDismiss() {
        dismiss(animated: false, completion: nil)
    }
    
    private func configureBackgroundView() {
        backgroundView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleKeyboardDismiss))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func setProfilePictureImage() {
        userImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTakeImage))
        userImageView.addGestureRecognizer(tapGesture)
        
        if let imageURL = UserData.getUserData()?.image {
            DownloadAPI.init().downloadImage(urlString: imageURL) { [unowned self] (result) in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        self.userImageView.image = image
                    }
                case .failure(let error):
                    print("FAILED TO DOWNLOAD USER IMAGE: \(error)")
                }
            }
        }
    }
    
    private func configureUserInfo() {
        guard let userData = UserData.getUserData() else {
            fatalError("USER DATA NOT SET IN USER DEFAULTS")
        }
        nameTextField.setText(text: userData.name)
        emailTextField.setText(text: userData.email)
        emailTextField.setInactive()
        nameTextField.setDelegate(delegate: self)
    }
    
    private func showImagePicker() {
        let language = Verification.init().getCurrentLanguage()
        let title = (language == .English) ? "Profile Picture" : "الصوره الشخصيه"
        let message = (language == .English) ? "Choose Profile Picture From" : "اختر صورة من"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cameraTitle = (language == .English) ? "Camera" : "كاميرا"
        let cameraAction = UIAlertAction(title: cameraTitle, style: .default) { [unowned self] (_) in
//            self.imagePicker.sourceType = .camera
//            self.imagePicker.allowsEditing = true
//            self.present(self.imagePicker, animated: false, completion: nil)
            
        }
        let gallaryTitle = (language == .English) ? "Photos" : "مكتبة الصور"
        let gallaryAction = UIAlertAction(title: gallaryTitle, style: .default) { [unowned self] (_) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: false, completion: nil)
        }
        
        let closeTitle = (language == .English) ? "Close" : "أغلق"
        let closeAction = UIAlertAction(title: closeTitle, style: .default) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc private func handleTakeImage() {
        userImageView.flash()
        showImagePicker()
    }
    
    @objc private func handleSaveData() {
        guard let userData = UserData.getUserData() else {
            fatalError("USER DATA NOT SET IN USER DEFAULTS")
        }
        let token = userData.token
        let language = Verification.init().getCurrentLanguage()
        if isUploadingImage {
            let alertString = language == .English ? "Image still uploading" : "لا تزال الصورة قيد التحميل"
            enableResponseAlert(message: alertString)
            return
        }
        else {
            disableResponseAlert()
        }
        if !Connection.init().checkInterConnectivity(){
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                
            }
            return
        }
        
        let loadingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingScreen") as! LoadingViewController
        present(loadingVC, animated: false, completion: nil)
        
        UpdateProfile.init(token: token, name: nameTextField.getText(), language: language, image: imageURL).update { (code, message,name,image) in
            print(message)
            if code == 200 {
                self.disableResponseAlert()
                guard let name = name , let image = image else {
                    loadingVC.dismiss(animated: false, completion: nil)
                    return
                }
                UserData.init(id: userData.id, email: userData.email, phone: userData.phone, country_code: userData.country_code, image: image, name: name, token: userData.token,qr_code: userData.qr_code).saveUserData()
                NotificationCenter.default.post(name: .didUpdateProfile, object: nil)
                loadingVC.dismiss(animated: false, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
            else if code == 400 {
                loadingVC.dismiss(animated: false, completion: nil)
                self.enableResponseAlert(message: message)
            } else if code == 500 {
                self.enableResponseAlert(message: message)
                loadingVC.dismiss(animated: false, completion: nil)
            }
            else {
                self.enableResponseAlert(message: message)
                loadingVC.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @objc private func handleKeyboardDismiss() {
        DispatchQueue.main.async {
            self.nameTextField.resignResponder()
        }
    }
    
    @objc private func handleVerify() {
        guard let userData = UserData.getUserData() else {
            fatalError("USER DATA NOT SET")
        }
        if nameTextField.getText().count == 0 {
            let language = Verification.init().getCurrentLanguage()
            let alertString = (language == .English) ? "Name can’t be empty or only space" : "لا يمكن أن يكون الاسم فارغًا أو مساحة فقط"
            DispatchQueue.main.async {
                self.nameTextField.enableAlert(message: alertString)
                self.saveButton.isEnabled = false
                self.saveButton.backgroundColor = UIColor(named: "inActiveColor")
            }
            
        }
        else if nameTextField.getText() == userData.name && imageURL == nil{
            
            let language = Verification.init().getCurrentLanguage()
            let alertString = (language == .English) ? "Name was never changed" : "الاسم لم يتغير ابدا"
            DispatchQueue.main.async {
                self.nameTextField.enableAlert(message: alertString)
                self.saveButton.isEnabled = false
                self.saveButton.backgroundColor = UIColor(named: "inActiveColor")
            }
        }
            
        else {
            DispatchQueue.main.async {
                self.nameTextField.disableAlert()
                self.saveButton.isEnabled = true
                self.saveButton.backgroundColor = UIColor(named: "PrimaryColor")
            }
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
        }
    }

}

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.nameTextField.resignResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.nameTextField.resignResponder()
        }
        return true
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let placeholder = UIImage(named: "profile_picture_placeholder")
        
        if let data = image?.jpegData(compressionQuality: 0.8) {
            let language = Verification.init().getCurrentLanguage()
            userImageView.startUploading()
            
            if !Connection.init().checkInterConnectivity(){
                imagePicker.dismiss(animated: false, completion: nil)
                userImageView.finishUploading()
                return
            }
            
            userImageView.setImage(userImage: image)
            isUploadingImage = true
            userImageView.startUploading()
            
            UploadAPI(imageData: data, language: language).uploadImage { [unowned self] (result) in
                switch result {
                case .success(let val):
                    DispatchQueue.main.async {
                        self.userImageView.finishUploading()
                    }
                    if val.code == 200 {
                        self.imageURL = val.imageURL
                        self.isUploadingImage = false
                        self.userImageView.finishUploading()
                        DispatchQueue.main.async {
                            self.disableResponseAlert()
                            self.handleVerify()
                        }
                    } else {
                        self.userImageView.finishUploading()
                        DispatchQueue.main.async {
                            self.userImageView.setImage(userImage: placeholder)
                            self.enableResponseAlert(message: val.message)
                        }
                    }
                    
                case .failure(let err):
                    self.isUploadingImage = false
                    self.userImageView.finishUploading()
                    DispatchQueue.main.async {
                        self.userImageView.setImage(userImage: placeholder)
                        self.userImageView.finishUploading()
                    }
                    print("failed tp generate to upload image \(err.localizedDescription)")
                }
            }
            
        } else {
            debugPrint("failed to get data from image in imagePicker")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
