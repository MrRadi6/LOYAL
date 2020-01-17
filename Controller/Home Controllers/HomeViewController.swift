//
//  HomeViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import SkeletonView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var navBar: CustomNavBar!
    private let refreshControl = UIRefreshControl()
    private let connection = Connection()
    private var homeContent: HomeData?
    private var userData: UserData?
    private var isLoadiing = false
    private var isSuccessCall = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Verification.init().configureViewWithTime(viewController: self)
        navBar.parentViewController = self
        fetchData()
        userData = UserData.getUserData()
        tableView.register(UINib(nibName: "UserInfoCell", bundle: nil), forCellReuseIdentifier: "UserInfoCell")
        tableView.register(UINib(nibName: "RewardsCell", bundle: nil), forCellReuseIdentifier: "RewardsCell")
        tableView.register(UINib(nibName: "VoucherCell", bundle: nil), forCellReuseIdentifier: "VoucherCell")
        tableView.register(UINib(nibName: "AdsCell", bundle: nil), forCellReuseIdentifier: "AdsCell")
        tableView.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
        tableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")
        
        // register SkeletonView cells and collections
        tableView.register(UINib(nibName: "AdsSkeleton", bundle: nil), forCellReuseIdentifier: "AdsSkeleton")
        tableView.register(UINib(nibName: "RewardCollectionSkeleton", bundle: nil), forCellReuseIdentifier: "RewardCollectionSkeleton")
        tableView.register(UINib(nibName: "VoucherCollectionSkeleton", bundle: nil), forCellReuseIdentifier: "VoucherCollectionSkeleton")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .didRedeemVoucher, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdate), name: .didUpdateProfile, object: nil)
        fetchData()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    @objc private func handleUserUpdate() {
        guard let userData = UserData.getUserData() else {
            fatalError("USER DATA NOT SET IN USER DEFAULTS")
        }
        print("START UPDATE USER INFO SECTION")
        DispatchQueue.main.async {
            self.userData = userData
            self.tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
        }
    }
    
    @objc private func fetchData() {
        guard let token = UserData.getUserData()?.token else {
            fatalError("TOKEN IS NIL IN HOME VIEW CONTROLLER")
        }
        let language = Verification.init().getCurrentLanguage()        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        self.isLoadiing = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if !connection.checkInterConnectivity(){
            self.isLoadiing = false
           
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            return
        }
       
        HomeContent.init(token: token, language: language).getHomeContent { [unowned self] code, data, message in
            
            if code == 200 {
                self.homeContent = data
                self.isSuccessCall = true
                self.isLoadiing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                    self.tableView.reloadData()
                })
                
            }
                
            else if code == 401 {
                self.isSuccessCall = false
                self.homeContent = nil
                Verification.init().makeConnectionAlert(parentView: self, error: .BadRequest, message: nil) {
                    self.isLoadiing = false
                    self.tableView.reloadData()
                }
            }
            else {
                self.isSuccessCall = false
                self.homeContent = nil
                Verification.init().makeConnectionAlert(parentView: self, error: .InternelServerError, message: message) {
                    self.isLoadiing = false
                    self.tableView.reloadData()
                }
            }
            
            
        }
    }
    
    func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: date)
    }
    
    func getTotalPoints() -> Int {
        return homeContent?.getTotalPoint() ?? 0
    }
    
    func getLatestExpirePoints() -> LatestExpirePoints?{
        if let lastExiprePoints = homeContent?.getLatestExpirePoints() {
            return (lastExiprePoints.count > 0) ? lastExiprePoints[0] : nil
        }
        return nil
    }
    
    func getLatestExpiringPointsArray() -> [LatestExpirePoints] {
        if let homeContent = homeContent {
            return homeContent.getLatestExpirePoints()
        }
        else {
            return []
        }
    }
    
    func getHomeData() -> HomeData? {
        return homeContent
    }

}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if connection.checkInterConnectivity() && isSuccessCall {
            return 5
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell : UserInfoCell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell") as! UserInfoCell
            if let userData = userData {
                cell.NameLabel.text = userData.name
                let totalPoints = homeContent?.getTotalPoint() ?? 0
                cell.PointCounterLabel.text =  (Verification.init().getCurrentLanguage() == .English) ? "\(totalPoints)" : "\(totalPoints)".translateNumbersToArabic()
                cell.isUserInteractionEnabled = false
            }
            return cell
            
        case 1:
            let cell : ErrorCell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
            cell.addTarget(target: self, action: #selector(fetchData), forEvent: .touchUpInside)
            return cell
            
        case 2:
            if !isLoadiing {
                let cell : AdsCell = tableView.dequeueReusableCell(withIdentifier: "AdsCell") as! AdsCell
                cell.ads = homeContent?.getAds()
                return cell
            } else {
                let cell : AdsSkeleton = tableView.dequeueReusableCell(withIdentifier: "AdsSkeleton") as! AdsSkeleton
                cell.isUserInteractionEnabled = false
                DispatchQueue.main.async {
                    cell.stopSkeletonAnimation()
                    cell.startSkeletonAnimation()
                }
                return cell
            }
            
            
        case 3:
            if !isLoadiing {
                let cell : RewardsCell = tableView.dequeueReusableCell(withIdentifier: "RewardsCell") as! RewardsCell
                cell.rewards = homeContent?.getTrendingReward()
                cell.parentViewController = self
                return cell
            } else {
                let cell : RewardCollectionSkeleton = tableView.dequeueReusableCell(withIdentifier: "RewardCollectionSkeleton") as! RewardCollectionSkeleton
                cell.isUserInteractionEnabled = false
                cell.startSkeleton()
                return cell
            }
            
        case 4:
            if !isLoadiing {
                let cell : VoucherCell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell") as! VoucherCell
                cell.vouchers = homeContent?.getLatestVoucher()
                cell.parentView = self
                return cell
            } else {
                let cell : VoucherCollectionSkeleton = tableView.dequeueReusableCell(withIdentifier: "VoucherCollectionSkeleton") as! VoucherCollectionSkeleton
                cell.isUserInteractionEnabled = false
                cell.startSkeleton()
                return cell
            }
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        case 1:
            return connection.checkInterConnectivity() && isSuccessCall ? 0 : tableView.frame.height - 80
        case 2:
            return view.frame.height * 0.27
        case 3:
            return 120
        case 4:
            return 160
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 3:
            let header : SectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
            header.sectionTitle.text = NSLocalizedString("Trending Rewards", comment: "Trending Rewards Title")
            return header
            
        case 4:
            let header : SectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
            header.sectionTitle.text = NSLocalizedString("Latest Vouchers", comment: "Latest Vouchers Title")
            return header
            
        default:
           return nil
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 50
        }
        else if section == 4 {
            return 50
        }
        return 0
    }

}


