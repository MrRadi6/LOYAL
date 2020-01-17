//
//  HistoryViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var navbar: CustomNavBar!
    @IBOutlet weak var historyTableView: UITableView!
    private var latestPointsArray: [LatestExpirePoints] = []
    private var isLoading = true
    private var isSuccesfullCall = true
    private var isEmptyData = false
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.parentViewController = self
        Verification.init().configureViewWithTime(viewController: self)
        historyTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        historyTableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")
        historyTableView.register(UINib(nibName: "RewardsDetailtsSkeleton", bundle: nil), forCellReuseIdentifier: "RewardsDetailtsSkeleton")
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .didRedeemVoucher, object: nil)
        historyTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        fetchData()
    }
    
    @objc private func fetchData() {
        guard let token = UserData.getUserData()?.token else {
            fatalError("USER DATA NOT SET YET IN USER DEFAULTS")
        }
        let language = Verification.init().getCurrentLanguage()
        
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        
        if !Connection.init().checkInterConnectivity() {
            Verification.init().makeConnectionAlert(parentView: self, error: .ReachibilityError, message: nil) {
                self.isSuccesfullCall = false
                self.isEmptyData = true
                DispatchQueue.main.async {
                    self.historyTableView.reloadData()
                }
            }
            return
        }
        isLoading = true
        historyTableView.reloadData()
        HistoryContent.init(token: token, language: language).getHistoryPoints { (code, data, message) in
            if code == 200 {
                if let data = data {
                    if data.count == 0 {
                        self.isLoading = false
                        self.isSuccesfullCall = true
                        self.isEmptyData = true
                        self.historyTableView.reloadData()
                    }
                    else {
                        self.latestPointsArray = data
                        self.isLoading = false
                        self.isSuccesfullCall = true
                        self.isEmptyData = false
                        self.historyTableView.reloadData()
                    }
                }
                else {
                    self.isLoading = false
                    self.isSuccesfullCall = false
                    self.isEmptyData = true
                    self.historyTableView.reloadData()
                }
            }
            else if code == 401 {
                print(message)
                self.isLoading = false
                self.isSuccesfullCall = false
                self.isEmptyData = true
                self.historyTableView.reloadData()
            }
            else {
                print(message)
                self.isLoading = false
                self.isSuccesfullCall = false
                self.isEmptyData = true
                self.historyTableView.reloadData()
            }
        }
        
        
    }

}

extension HistoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 5
        }
        else if !isSuccesfullCall || isEmptyData {
            return 1
        }
        return latestPointsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading && !isEmptyData{
            let cell: RewardsDetailtsSkeleton = tableView.dequeueReusableCell(withIdentifier: "RewardsDetailtsSkeleton", for: indexPath) as! RewardsDetailtsSkeleton
            cell.isUserInteractionEnabled = false
            DispatchQueue.main.async {
                cell.stopSkeletonAnimation()
                cell.startSkeletonAnimation()
            }
            return cell
        }
        else if !isSuccesfullCall{
            let cell : ErrorCell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
            cell.showButton()
            cell.addTarget(target: self, action: #selector(fetchData), forEvent: .touchUpInside)
            cell.isUserInteractionEnabled = true
            return cell
        }
        else if isEmptyData {
            let cell : ErrorCell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
            cell.hideButton()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        cell.pointsData = latestPointsArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isSuccesfullCall || isEmptyData{
            return view.frame.height - 60
        }
        return 125
    }
}
