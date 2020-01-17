//
//  ProfileViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/19/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import GSKStretchyHeaderView

class ProfileViewController: UIViewController {

    @IBOutlet weak var editTableView: UITableView!
    @IBOutlet weak var editNavBar: EditNavBar!
    private var stretchyHeader : GSKStretchyHeaderView!
    weak var pointsView: PointsView?
    private var userTotalPoints = 0
    private var expireText = ""
    private var homeData: HomeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editNavBar.parentViewController = self
        editTableView.register(UINib(nibName: "EditProfileCell", bundle: nil), forCellReuseIdentifier: "EditProfileCell")
        editTableView.register(UINib(nibName: "VouchersHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "VouchersHeader")
        initializeStrectchyHeader()
        getUserInfo()
        getHomeInfo()
        // Do any additional setup after loading the view.
    }
    
    private func initializeStrectchyHeader() {
        let headerSize = CGSize(width: editTableView.frame.width, height: 200)
        stretchyHeader = GSKStretchyHeaderView(frame: CGRect(x: 0, y: 0, width: headerSize.width, height: headerSize.height))
        stretchyHeader.contentView.makeShadow(radius: 4)
        stretchyHeader.stretchDelegate = self
        editTableView.addSubview(stretchyHeader)
        configureStretchyHeader()
    }
    private func configureStretchyHeader(){
        
        stretchyHeader.expansionMode = .topOnly
        stretchyHeader.minimumContentHeight = 0
        stretchyHeader.maximumContentHeight = 200
        stretchyHeader.contentShrinks = true
        stretchyHeader.contentExpands = true
        stretchyHeader.contentAnchor =  .top
        stretchyHeader.contentView.backgroundColor = UIColor(named: "PrimaryColor")
        
        pointsView = Bundle.main.loadNibNamed("PointsView", owner: self, options: nil)?.first as? PointsView
        pointsView?.parentVC = self
        stretchyHeader.contentView.addSubview(pointsView!)
        
        pointsView?.translatesAutoresizingMaskIntoConstraints = false
        pointsView?.leadingAnchor.constraint(equalTo: stretchyHeader.contentView.leadingAnchor).isActive = true
        pointsView?.trailingAnchor.constraint(equalTo: stretchyHeader.contentView.trailingAnchor).isActive = true
        pointsView?.topAnchor.constraint(equalTo: stretchyHeader.contentView.topAnchor).isActive = true
        pointsView?.bottomAnchor.constraint(equalTo: stretchyHeader.contentView.bottomAnchor).isActive = true

    }
    
    private func getUserInfo() {
        if !Connection.init().checkInterConnectivity() {
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
            }
            return
        }
        guard let token = UserData.getUserData()?.token else {
            fatalError("TOKEN IS NIL IN EDIT PROFILE VIEW CONTROLLER (getTotalPoints")
        }
        let language = Verification.init().getCurrentLanguage()
        
        HomeContent.init(token: token, language: language).getHomeContent {  [unowned self] code, data, message in
            if code == 200 {
                
                if let data = data {
                    let points = (Verification.init().getCurrentLanguage() == .English) ? "\(data.total_points ?? 0)" : "\(data.total_points ?? 0)".translateNumbersToArabic()
                    self.pointsView?.latestExpirePoint = data.getLatestExpirePoints().first
                    self.pointsView?.pointsLabel.text = "\(points) \(NSLocalizedString("points", comment: "points"))"
                } else {
                    self.pointsView?.latestExpirePoint = nil
                }
            }
        }
    }
    
    private func getHomeInfo() {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController as? TabbarViewController, let homeVC = rootVC.viewControllers?[0] as? HomeViewController else {
            print("Cant initializa home Controlller instance in Profile")
            return
        }
        homeData = homeVC.getHomeData()
    }
    
    private func changeLanguage() {
        let currentLanguage = Verification.init().getCurrentLanguage()
        let languageAbbr = (currentLanguage == .English) ? "ar" : "en"
        
        if currentLanguage == .English {
            confirmChangeLanguage(title: "App Language", message: "application will be closed to set the chosen language",acceptTitle: "OK",cancelTitle: "Cancel",languageAbbr: languageAbbr)
        } else {
            confirmChangeLanguage(title: "لغة التطبيق", message: "سيتم إغلاق التطبيق لضبط اللغة المختارة",acceptTitle: "حسنا",cancelTitle: "إلغاء",languageAbbr: languageAbbr)
        }
    }
    
    private func confirmChangeLanguage(title: String, message: String,acceptTitle: String,cancelTitle: String ,languageAbbr: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: acceptTitle, style: .default) { [unowned self] (action) in
            UserDefaults.standard.set([languageAbbr], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            self.dismiss(animated: false, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    exit(0)
                }
            })
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func signout() {
        if !Connection.init().checkInterConnectivity() {
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                
            }
            return
        }
        let currentLanguage = Verification.init().getCurrentLanguage()
        let title = (currentLanguage == .English) ? "Signout" : "تسجيل الخروج"
        let acceptTitle = (currentLanguage == .English) ? "Confirm" : "تاكيد الخروج"
        let cancelTitle = (currentLanguage == .English) ? "Cancel" : "إلغاء"
        let message = (currentLanguage == .English) ? "Are you sure you want to sign out?" : "هل أنت متأكد أنك تريد الخروج؟"
        
        confirmSignout(title: title, message: message, acceptTitle: acceptTitle, cancelTitle: cancelTitle)

    }
    
    private func confirmSignout(title: String, message: String,acceptTitle: String,cancelTitle: String) {
        guard  let token = UserData.getUserData()?.token else {
            fatalError("USER IS NOT LOGGED IN USER DEFAULTS")
        }
        let currentLanguage = UserDefaults.standard.value(forKey: "AppleLanguages") as! [String]
        let language :Language = (currentLanguage[0] == "en") ? .English : .Arabic
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: acceptTitle, style: .default) { [unowned self] (action) in
            Logout.init(token: token, language: language).logout(complition: { (data, code, message) in
                if code == 200 {
                    UserData.signoutUser()
                    self.present(loginVC, animated: false) { [unowned self] in
                        UIApplication.shared.keyWindow?.rootViewController = loginVC
                        self.presentedViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                }
                else if code == 500 {
                    Verification.init().makeConnectionAlert(parentView: self, error: .InternelServerError, message: message, complition: {
                        
                    })
                }
                else {
                    Verification.init().makeConnectionAlert(parentView: self, error: .BadRequest, message: message, complition: {
                        
                    })
                }
            })
            
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell") as! EditProfileCell
        let verification = Verification()
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let title = (verification.getCurrentLanguage() == .English) ? "Edit Profile" : "تعديل الملف الشخصي"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2854")
            case 1:
                let title = (verification.getCurrentLanguage() == .English) ? "Change Phone Number" : "غير رقم الهاتف"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2853")
            case 2:
                let title = (verification.getCurrentLanguage() == .English) ? "Change Password" : "غير كلمة السر"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2852")
            case 3:
                let title = (verification.getCurrentLanguage() == .English) ? "Sign out" : "خروج"
                cell.cellTitle.text = title
                cell.cellTitle.textColor = #colorLiteral(red: 0.6901960784, green: 0, blue: 0.1254901961, alpha: 1)
                cell.iconImageViwe.image = UIImage(named: "logout")
            default:
                fatalError("INDEX PATH ITEM Out OF RANGE")
            }
        }
        else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let title = (verification.getCurrentLanguage() == .English) ? "Change Language to Arabic" : "تغيير اللغة إلى الإنجليزية"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2851")
            case 1:
                let title = (verification.getCurrentLanguage() == .English) ? "About Developers" : "حول المطورين"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2850")
            case 2:
                let title = (verification.getCurrentLanguage() == .English) ? "Terms & Conditions" : "الشروط والأحكام"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2849")
            case 3:
                let title = (verification.getCurrentLanguage() == .English) ? "Privacy Policy" : "سياسة خاصة"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2848")
            case 4:
                let title = (verification.getCurrentLanguage() == .English) ? "Report Issue" : "ابلغ عن مشكلة"
                cell.cellTitle.text = title
                cell.iconImageViwe.image = UIImage(named: "Group 2847")
            default:
                fatalError("INDEX PATH ITEM Out OF RANGE")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let storyboard = UIStoryboard.init(name: "EditProfile", bundle: nil)
        
        switch indexPath.section {
        case 0:
            if indexPath.item == 0 {
               let editVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                present(editVC, animated: true) {
                    
                }
            }
            else if indexPath.item == 1{
                let changePhoneVC = storyboard.instantiateViewController(withIdentifier: "ChangePhoneViewController") as! ChangePhoneViewController
                present(changePhoneVC, animated: true) {
                    
                }
                
            }
            else if indexPath.item == 2{
                let changePasswordVC = storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
                present(changePasswordVC, animated: true) {
                    
                }
            }
            else if indexPath.item == 3{
                signout()
            }
        case 1:
            if indexPath.item == 0 {
                changeLanguage()
            }
            else if indexPath.item == 1{
                let developerVC = storyboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
                if let about = homeData?.about {
                    present(developerVC, animated: true) {
                        developerVC.titleLabel.title = NSLocalizedString("About Developers", comment: "About Developers")
                        developerVC.textView.attributedText = about.html2AttributedString
                    }
                }
                
            }
            else if indexPath.item == 2{
                let termsVC = storyboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
                if let terms_conditions = homeData?.terms_conditions {
                    present(termsVC, animated: true) {
                        termsVC.titleLabel.title = NSLocalizedString("Terms & Conditions", comment: "Terms & Conditions")
                        termsVC.textView.attributedText = terms_conditions.html2AttributedString
                    }
                }
            }
            else if indexPath.item == 3{
                let privacyVC = storyboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
                if let policis = homeData?.policies {
                    present(privacyVC, animated: true) {
                        privacyVC.titleLabel.title = NSLocalizedString("Privacy Policy", comment: "Privacy Policy")
                        privacyVC.textView.attributedText = policis.html2AttributedString
                    }
                }
            }
            else if indexPath.item == 4{
                let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
                present(reportVC, animated: true) {
                    
                }
            }
        default:
            fatalError("SECTION  NUMBER IS NOT VALID IN PROFILE")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "VouchersHeader") as! VouchersHeader
        let verification = Verification()
        if section == 0 {
            let title = (verification.getCurrentLanguage() == .English) ? "Profile" : "الملف الشخصي"
            header.setHeaderText(title: title, size: 24,weight: .medium)
            return header
        }
        else if section == 1 {
            let title = (verification.getCurrentLanguage() == .English) ? "Settings" : "الإعدادات"
            header.setHeaderText(title: title,size: 24,weight: .medium)
            return header
        }
        
        return nil
    }
    
    
}

extension ProfileViewController: GSKStretchyHeaderViewStretchDelegate {
    func stretchyHeaderView(_ headerView: GSKStretchyHeaderView, didChangeStretchFactor stretchFactor: CGFloat) {
        pointsView?.alpha = stretchFactor
        if stretchFactor < 0.1 {
            editNavBar.setNavBarForCollapse()
        
        } else {
            editNavBar.setNavBarForExpand()
        }
    }
    
    
}
