//
//  RewardsDetailsViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/7/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit
import GSKStretchyHeaderView

class RewardsDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var rewardTableView: UITableView!
    @IBOutlet weak var footer: UIView!
    
    var reward: TrendingReward?
    var isSuccessCall = true
    private var stretchyHeader : GSKStretchyHeaderView!
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame.self = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let buttonImage = UIImage(named: "white-arrow_back-24px")!.imageFlippedForRightToLeftLayoutDirection()
        button.setImage(buttonImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleViewDismiss), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let imageView: UIImageView =  {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let imageMask: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "RewardMask")!
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 42, weight: .medium)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFooter()
        Verification.init().configureViewWithTime(viewController: self)
        let headerSize = CGSize(width: rewardTableView.frame.width, height: 150)
        stretchyHeader = GSKStretchyHeaderView(frame: CGRect(x: 0, y: 0, width: headerSize.width, height: headerSize.height))
        stretchyHeader.stretchDelegate = self
        rewardTableView.register(UINib(nibName: "RewardBody", bundle: nil), forCellReuseIdentifier: "RewardBody")
        rewardTableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")
        rewardTableView.addSubview(stretchyHeader)
        configureStretchyHeader()
        
        if let reward = reward {
            self.titleLabel.text = reward.title
        }
        
        
    }
    
    private func configureFooter() {
        guard let reward = reward else {
            fatalError("REWARD DID NOT SET")
        }
        let customFooter = Bundle.main.loadNibNamed("RewardDetailsFooter", owner: self, options: nil)?.first as! RewardDetailsFooter
        customFooter.addTargetToButton(target: self, action: #selector(handleredeemReward), forAction: .touchUpInside)
        let points = (Verification.init().getCurrentLanguage() == .English) ? "\(reward.points)" : "\(reward.points)".translateNumbersToArabic()
        customFooter.pointsLabel.text = "\(points) \(NSLocalizedString("points", comment: "Points"))"
        customFooter.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(customFooter)
        customFooter.leadingAnchor.constraint(equalTo: footer.leadingAnchor).isActive = true
        customFooter.trailingAnchor.constraint(equalTo: footer.trailingAnchor).isActive = true
        customFooter.topAnchor.constraint(equalTo: footer.topAnchor).isActive = true
        customFooter.bottomAnchor.constraint(equalTo: footer.bottomAnchor,constant: 40).isActive = true
    }
    
    private func configureStretchyHeader(){
        guard let reward = reward else {
            fatalError("REWARD ITEM DID NOT SET YET IN REWARD DETAILS")
        }
        
        stretchyHeader.expansionMode = .topOnly
        stretchyHeader.minimumContentHeight = 80
        stretchyHeader.maximumContentHeight = 200
        stretchyHeader.contentShrinks = true
        stretchyHeader.contentExpands = true
        stretchyHeader.contentAnchor = .top
        stretchyHeader.contentView.backgroundColor = UIColor(named: "PrimaryColor")
        
        imageView.image = reward.backgroundImage
//        if let index = reward.title.firstIndex(of: " ") {
//            let distance = reward.title.distance(from: reward.title.startIndex, to: index)
//            titleLabel.text = "\(reward.title.prefix(distance)) Discount"
//
//        }
        
        
        
        
        stretchyHeader.contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: stretchyHeader.contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: stretchyHeader.contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: stretchyHeader.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: stretchyHeader.contentView.trailingAnchor).isActive = true
        
        imageView.addSubview(imageMask)
        imageMask.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        imageMask.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        imageMask.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        imageMask.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true

        stretchyHeader.contentView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: stretchyHeader.contentView.leadingAnchor,constant: backButton.frame.width * 1.5).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: stretchyHeader.contentView.trailingAnchor,constant: backButton.frame.width * -1.5).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: stretchyHeader.contentView.centerYAnchor,constant: 20).isActive = true
        
        stretchyHeader.contentView.addSubview(backButton)
        backButton.leadingAnchor.constraint(equalTo: stretchyHeader.contentView.leadingAnchor, constant: 16).isActive = true
        backButton.topAnchor.constraint(equalTo: stretchyHeader.contentView.topAnchor, constant: 40 + backButton.frame.height * 0.5).isActive = true
    }
    
    @objc private func handleViewDismiss(){
        self.dismiss(animated: true) {
        }
    }
    
    @objc private func handleredeemReward() {
        showConfirmationAlert()
    }
    
    private func showConfirmationAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Redeem Reward", comment: "Redeem Reward"), message: NSLocalizedString("confirmPhrase", comment: "confirmPhrase"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive)
        let redeemAction = UIAlertAction(title: NSLocalizedString("Redeem", comment: "Redeem"), style: .default) { (action) in
            self.redeemReward()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(redeemAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func redeemReward() {
        guard let token = UserData.getUserData()?.token else {
            fatalError("TOKEN NOT SET IN REWARD DETAILS")
        }
        guard let rewardID = reward?.id else {
            fatalError("REWARD NOT SET IN REWARDS DETAILS")
        }
        let language = Verification.init().getCurrentLanguage()
        
        if !Connection.init().checkInterConnectivity(parentView: self) {
            isSuccessCall = false
            rewardTableView.reloadData()
            return
        }
        
        RedeemReward.init(token: token, language: language).redeem(id: rewardID) { [unowned self] (code, message) in
            print(code)
            print(message)
            if code == 200 {
                NotificationCenter.default.post(name: .didRedeemVoucher, object: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let tabController = appDelegate.window?.rootViewController as! TabbarViewController
                let voucherVC = tabController.viewControllers![2] as! VouchersViewController
                voucherVC.isFromRedeem = true
                tabController.selectedIndex = 2
                self.dismiss(animated: true, completion: nil)
            }
            else {
                Verification.init().makeConnectionAlert(parentView: self, error: .BadRequest, message: message, complition: {
                    self.isSuccessCall = true
                    self.rewardTableView.reloadData()
                })
            }
        }
        
    }
    
}


extension RewardsDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isSuccessCall {
            let cell : ErrorCell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
            cell.addTarget(target: self, action: #selector(handleredeemReward), forEvent: .touchUpInside)
            return cell
        }
       else {
            let cell : RewardBody = tableView.dequeueReusableCell(withIdentifier: "RewardBody") as! RewardBody
            cell.setDetails(details: reward!.description)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isSuccessCall {
            return tableView.frame.height - 200
        }
        
        let size = CGSize(width: view.frame.width, height: 1000)
        let attributes = [kCTFontAttributeName : UIFont.systemFont(ofSize: 18)]
        let estimateFrame = NSString(string: reward!.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        
        return (estimateFrame.height > tableView.frame.height) ? estimateFrame.height + 100 : view.frame.height - 350
    }
    
}

extension RewardsDetailsViewController: GSKStretchyHeaderViewStretchDelegate {
    
    func stretchyHeaderView(_ headerView: GSKStretchyHeaderView, didChangeStretchFactor stretchFactor: CGFloat) {
        imageView.alpha = stretchFactor
        var textFactor = stretchFactor
        if stretchFactor < 0.5 {
            textFactor = 0.5
        } else if stretchFactor > 1 {
            textFactor = 1
            
        }
        titleLabel.font = UIFont.systemFont(ofSize: 42 * textFactor, weight: .medium)
    }
    
    
}
