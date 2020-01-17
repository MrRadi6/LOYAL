//
//  RewardsViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/6/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class RewardsViewController: UIViewController {
    
    @IBOutlet weak var rewardsTableView: UITableView!
    @IBOutlet weak var navBar: CustomNavBar!
    
    private let refreshControl = UIRefreshControl()
    private var isLoading = false
    private var isSuccessCall = true
    private var isfetchingMore = false
    private var currentPage = 1
    private var rewardArray: [TrendingReward] = []
    private var latestExpiringPoints: [LatestExpirePoints] = []
    private var userTotalPoints = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.parentViewController = self
        Verification.init().configureViewWithTime(viewController: self)
        rewardsTableView.separatorInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 10)
        rewardsTableView.register(UINib(nibName: "PointsSection", bundle: nil), forCellReuseIdentifier: "PointsSection")
        rewardsTableView.register(UINib(nibName: "RewardsDetailsItem", bundle: nil), forCellReuseIdentifier: "RewardsDetailsItem")
        rewardsTableView.register(UINib(nibName: "RewardsDetailtsSkeleton", bundle: nil), forCellReuseIdentifier: "RewardsDetailtsSkeleton")
        rewardsTableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")
        
        rewardsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .didRedeemVoucher, object: nil)
        fetchData()
    }
    
    @objc private func fetchData() {
        isLoading = true
        isfetchingMore = true
        currentPage = 1
        rewardArray = []
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.rewardsTableView.reloadData()
        }
        
        if !Connection.init().checkInterConnectivity(){
            isfetchingMore = false
            isLoading = false
            isSuccessCall = false
            rewardsTableView.reloadData()
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                DispatchQueue.main.async {
                    self.rewardsTableView.reloadData()
                }
            }
            return
        }
        
        guard let token = UserData.getUserData()?.token else {
            fatalError("TOKEN IS NIL IN REWARDS VIEW CONTROLLER (FETCH DATA")
        }
        let language = Verification.init().getCurrentLanguage()
        
        RewardsContent.init(token: token, language: language).getRewards(page: currentPage) { [unowned self] (code, rewards, message) in
            if code == 200 {
                self.getTotalPoints()
                self.currentPage += 1
                if let rewards = rewards {
                    self.rewardArray = rewards
                    self.isSuccessCall = true
                } else {
                    print("REWARDS IS NIL IN FETCH DATA REWARDS VIEW CONTROLLER")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.isLoading = false
                    self.isfetchingMore = false
                    self.rewardsTableView.reloadData()
                })
                
            }
            else if code == 401{
                self.isSuccessCall = false
                Verification.init().makeConnectionAlert(parentView: self, error: .BadRequest, message: nil) {
                    self.isLoading = false
                    self.isfetchingMore = false
                    self.rewardsTableView.reloadData()
                }
            }
            else{
                self.isSuccessCall = false
                Verification.init().makeConnectionAlert(parentView: self, error: .InternelServerError, message: message) {
                    self.isLoading = false
                    self.isfetchingMore = false
                    self.rewardsTableView.reloadData()
                }
            }
        }
    }
    
    private func getTotalPoints() {
        
        guard let token = UserData.getUserData()?.token else {
            fatalError("TOKEN IS NIL IN REWARDS VIEW CONTROLLER (getTotalPoints")
        }
        let language = Verification.init().getCurrentLanguage()
        
        HomeContent.init(token: token, language: language).getHomeContent { [unowned self] code, data, message in
            if code == 200 {
                if let point = data?.total_points {
                     self.userTotalPoints = point
                     self.rewardsTableView.reloadData()
                } else {
                    self.userTotalPoints = 0
                    self.rewardsTableView.reloadData()
                }
            }
        }
    }
    
    private func batchFetch() {
        
        guard let token = UserData.getUserData()?.token else {
            fatalError("TOKEN IS NIL IN REWARDS VIEW CONTROLLER (BATCH FETCH")
        }
        let language = Verification.init().getCurrentLanguage()
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        
        if !Connection.init().checkInterConnectivity(){
            isfetchingMore = false
            isLoading = false
            isSuccessCall = false
            rewardsTableView.reloadData()
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                DispatchQueue.main.async {
                    self.rewardsTableView.reloadData()
                }
            }
            return
        }
        
        isfetchingMore = true
        
        RewardsContent.init(token: token, language: language).getRewards(page: currentPage) { [unowned self] (code, rewards, message) in

            if code == 200 {
                if let rewards = rewards {
                    self.currentPage += 1
                    self.addNewData(data: rewards)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.isfetchingMore = false
                    })
                    self.rewardsTableView.reloadData()
                } else {
                    print("REWARDS IS NIL IN FETCH DATA REWARDS VIEW CONTROLLER")
                }

            }
            else if code == 401 {
                self.isSuccessCall = false
                self.rewardsTableView.reloadData()
                Verification.init().makeConnectionAlert(parentView: self, error: .BadRequest, message: nil) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.isfetchingMore = false
                    })
                }
            }
            else  {
                self.isSuccessCall = false
                self.rewardsTableView.reloadData()
                Verification.init().makeConnectionAlert(parentView: self, error: .InternelServerError, message: message) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.isfetchingMore = false
                    })
                }
            }
        }
    }
    
    private func addNewData(data: [TrendingReward]) {
        for reward in data {
            rewardArray.append(reward)
        }
    }
    
    private func getLatestExpirePoints() -> LatestExpirePoints?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabController = appDelegate.window?.rootViewController as! TabbarViewController
        let homeVC = tabController.viewControllers?[0] as! HomeViewController
        return homeVC.getLatestExpirePoints()
    }
    
    
}

extension RewardsViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if !isSuccessCall {
                return 1
            }
            else if !isLoading {
                return rewardArray.count
            }
            else {
                return 10
            }
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == 0 {
            let cell: PointsSection = tableView.dequeueReusableCell(withIdentifier: "PointsSection") as! PointsSection
            cell.totalPoints.text = (Verification.init().getCurrentLanguage() == .English) ? "\(userTotalPoints)" : "\(userTotalPoints)".translateNumbersToArabic()
            cell.parentViewController = self
            cell.latestExpirePoint = getLatestExpirePoints()
            return cell
        }
            
        else if !isSuccessCall && indexPath.section == 1 {
            let cell : ErrorCell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
            cell.addTarget(target: self, action: #selector(fetchData), forEvent: .touchUpInside)
            return cell
        }
            
        else {
            if isLoading {
                let cell : RewardsDetailtsSkeleton = tableView.dequeueReusableCell(withIdentifier: "RewardsDetailtsSkeleton") as! RewardsDetailtsSkeleton
                cell.isUserInteractionEnabled = false
                DispatchQueue.main.async {
                    cell.stopSkeletonAnimation()
                    cell.startSkeletonAnimation()
                }
                return cell
            } else {
                let cell: RewardsDetailsItem = tableView.dequeueReusableCell(withIdentifier: "RewardsDetailsItem") as! RewardsDetailsItem
                let verification = Verification()
                let reward = rewardArray[indexPath.row]
                let points = (verification.getCurrentLanguage() == .English) ? "\(reward.points)" : "\(reward.points)".translateNumbersToArabic()
                cell.totalPointsLabel.text = "\(points) \(NSLocalizedString("points", comment: "points"))"
                cell.rewardBackgoundImageView.image = reward.backgroundImage
                cell.rewardDetails.text = (verification.getCurrentLanguage() == .English) ? reward.title : reward.title.translateNumbersToArabic()
                return cell
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isSuccessCall || indexPath.section == 0{
            return
        }
        tableView.deselectRow(at: indexPath, animated: false)
        let reward = rewardArray[indexPath.row]
        let rewardVC = UIStoryboard(name: "HomeStoryboard", bundle: nil).instantiateViewController(withIdentifier: "RewardsDetailsViewController") as! RewardsDetailsViewController
        rewardVC.reward = reward
        present(rewardVC, animated: true, completion: {
            
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isSuccessCall && indexPath.section == 1 {
            return tableView.frame.height - 130
        }
        return 125
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let presentedDataHeight = (contentHeight - (scrollView.frame.height) > 0) ? contentHeight - (scrollView.frame.height) : 0
        
        if offsetY > presentedDataHeight && !isfetchingMore{
            batchFetch()
        }
    }
    
}
