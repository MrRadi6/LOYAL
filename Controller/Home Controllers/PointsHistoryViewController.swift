//
//  PointsHistoryViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/25/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class PointsHistoryViewController: UIViewController {

    @IBOutlet weak var pointsTableView : UITableView!
    @IBOutlet weak var pointsContainer : UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pointsTableViewHeightConstraints: NSLayoutConstraint!
    
    var latestExpiringPoints: [LatestExpirePoints] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(tapGesture)
        pointsContainer.layer.cornerRadius = 4
        pointsTableView.register(UINib(nibName: "PointsHistoryCell", bundle: nil), forCellReuseIdentifier: "PointsHistoryCell")
//        pointsTableView.register(UINib(nibName: "PointsHistoryHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "PointsHistoryHeader")
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    func configureTableViewHeight() {
        
        let height = pointsTableView.contentSize.height * 2.8
        if height < 200 {
            pointsTableViewHeightConstraints.constant = 200
            
        }
        else if height > view.frame.height * 0.8 {
            pointsTableViewHeightConstraints.constant = view.frame.height * 0.8
        }
        else {
            pointsTableViewHeightConstraints.constant = height
        }
        print(height)
        
    }
    
    @objc private func handleDismiss() {
        self.dismiss(animated: false, completion: nil)
    }

}


extension PointsHistoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestExpiringPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointsHistoryCell", for: indexPath) as! PointsHistoryCell
        cell.pointsData = latestExpiringPoints[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
}
