//
//  ReportViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import SwiftyJSON

enum responseStatus {
    case Success
    case Failure
}

class ReportViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navbar: EditProfileNavBar!
    @IBOutlet weak var alertTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertContainer: UIView!
    
    private var isUploadingAttactment = false
    private let imagePicker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AddReportCell", bundle: nil), forCellReuseIdentifier: "AddReportCell")
        tableView.keyboardDismissMode = .onDrag
        navbar.parentViewController = self
        navbar.addTarget(target: self, action: #selector(handleDismiss))
        configureGallaryImagePicker()
        disableResponseAlert()
        // Do any additional setup after loading the view.
    }
    
    private func configureGallaryImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
    private func enableResponseAlert(message: String,status: responseStatus) {
        DispatchQueue.main.async {
            self.alertLabel.text = message
            self.alertHeightConstraint.constant = 60
            self.alertTopConstraint.constant = 50
            self.alertContainer.backgroundColor = (status == .Success) ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : #colorLiteral(red: 0.6901960784, green: 0, blue: 0.1254901961, alpha: 1)
        }
    }
    
    private func disableResponseAlert(){
        DispatchQueue.main.async {
            self.alertHeightConstraint.constant = 0
            self.alertTopConstraint.constant = 0
            self.alertLabel.text = ""
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func attachDocument() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func submitReport() {
        guard let token = UserData.getUserData()?.token else {
            fatalError("USER DATA NOT SET IN USER DEFAULTS")
        }
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddReportCell
        let language = Verification.init().getCurrentLanguage()
        if cell.getReportText().isEmpty {
            return
        }
        
        if !Connection.init().checkInterConnectivity() {
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                
            }
            return
        }
        if isUploadingAttactment {
            let alertString = language == .English ? "The File is still uploading" : "لا يزال الملف قيد التحميل"
            enableResponseAlert(message: alertString,status: .Failure)
            return
        } else {
            disableResponseAlert()
        }
        let loadingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingScreen") as! LoadingViewController
        present(loadingVC, animated: false, completion: nil)
        let reportText = cell.getReportText()
        let imageURL = cell.documentURL
        SendReport.init(token: token, message: reportText, language: language, image: imageURL).sendReport { (code, message) in
            if code == 200 {
                self.enableResponseAlert(message: message, status: .Success)
                loadingVC.dismiss(animated: false, completion: {
                    cell.clearData()
                })
            }
            else {
                loadingVC.dismiss(animated: false, completion: {
                     self.enableResponseAlert(message: message,status: .Failure)
                })
            }
        }
        
    }

}

extension ReportViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AddReportCell = tableView.dequeueReusableCell(withIdentifier: "AddReportCell") as! AddReportCell
        cell.addSubmitAction(self, #selector(submitReport))
        cell.addAttachAction(self, action: #selector(attachDocument))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 640
    }
    
}

extension ReportViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

extension ReportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            print("failed to get image from image picker")
            return
        }
        if !Connection.init().checkInterConnectivity() {
            imagePicker.dismiss(animated: true) {
                Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                }
            }
            return
        }
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddReportCell
        cell.setAttachmentImage(image)
        
        imagePicker.dismiss(animated: true) {
            self.uploadDocument()
        }
    }
    
    private func uploadDocument() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddReportCell
        let language = Verification.init().getCurrentLanguage()
        if let data = cell.getDocumentData() {
            isUploadingAttactment = true
            cell.startUploadingProgress()
            UploadAPI.init(imageData: data, language: language).uploadImage { (result) in
                switch result {
                case .success(let value):
                    if value.code == 200 {
                        self.isUploadingAttactment = false
                        cell.finishUploadingProgerss()
                        self.enableResponseAlert(message: value.message, status: .Success)
                        cell.documentURL = value.imageURL
                    }
                    else {
                        cell.finishUploadingProgerss()
                        self.enableResponseAlert(message: value.message, status: .Failure)
                        self.isUploadingAttactment = false
                    }
                case .failure(let error):
                    cell.finishUploadingProgerss()
                    let message = (language == .English) ? "Client Error" : "خطا في التطبيق"
                    print(error.localizedDescription)
                    self.enableResponseAlert(message: message,status: .Failure)
                    self.isUploadingAttactment = false
                    
                }
            }
        }
    }
}
