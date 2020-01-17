//
//  CustomNavBar.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class CustomNavBar: UINavigationBar {
    
    var parentViewController: UIViewController?
    
    private weak var profileImage: UIButton! = {
       let view = UIButton()
        let image = UIImage(named: "profile_picture_placeholder")!
        view.imageView?.contentMode = .scaleAspectFill
        view.setImage(image, for: .normal)
        view.imageView?.layer.masksToBounds = true
        view.imageView?.layer.cornerRadius = 14
        view.addTarget(self, action: #selector(handleShowProfile), for: .touchUpInside)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureNavBarForTime()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("NAV BAR LOADED........................")
        configureProfileImage()
        configureNavBarForTime()
        setProfilePictureImage()
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        NotificationCenter.default.addObserver(self, selector: #selector(setProfilePictureImage), name: .didUpdateProfile, object: nil)
        
        
    }
    
    
    @objc private func setProfilePictureImage() {
        if let imageURL = UserData.getUserData()?.image {
            DownloadAPI.init().downloadImage(urlString: imageURL) { [unowned self] (result) in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        self.addProfileImage(image: image)
                    }
                    else {
                        let image = UIImage(named: "profile_picture_placeholder")
                        self.profileImage.setImage(image, for: .normal)
                    }
                case .failure(let error):
                    let image = UIImage(named: "profile_picture_placeholder")
                    self.profileImage.setImage(image, for: .normal)
                    print("FAILED TO DOWNLOAD USER IMAGE: \(error)")
                }
            }
        }
        else {
            let image = UIImage(named: "profile_picture_placeholder")
            profileImage.setImage(image, for: .normal)
        }
    }
    
    private func configureNavBarForTime() {
        if Verification.init().isMorningTime() {
            barStyle = .default
            barTintColor = UIColor.white
            titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "PrimaryColor")!,NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20)!]
        } else {
            barStyle = .black
            barTintColor = UIColor(named: "PrimaryColor")
            titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20)!]
        }
    }
    
    
    private func addProfileImage(image: UIImage?) {
        if let image = image {
            profileImage.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "profile_picture_placeholder")
            profileImage.setImage(image, for: .normal)
        }
    }
    
    private func configureProfileImage(){
        addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: centerYAnchor,constant: profileImage.frame.height * -0.5).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 28).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 28).isActive = true
        
    }
    
    @objc private func handleShowProfile(){
        
        let profileVC = UIStoryboard(name: "HomeStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        if let parentVC = parentViewController {
            parentVC.present(profileVC, animated: true) {
                // PERFORM INITIALIZATION FOR PROFILEVC
            }
        } else {
            fatalError("PARENT VC NOT SET IN NAV BAR")
        }
    }
}
