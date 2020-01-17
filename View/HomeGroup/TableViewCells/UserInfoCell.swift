//
//  UserInfoCell.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/17/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {
    
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var PointCounterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureShade()
        configureStyle()
        selectionStyle = .none
    }
    
    private func configureStyle() {
        pointsLabel.text = NSLocalizedString("points", comment: "points you have")
        if Verification.init().isMorningTime() {
            setMorningSettings()
        } else {
            setNightSettings()
        }
    }
    
    private func setMorningSettings() {
        contentView.backgroundColor = UIColor.white
        TimeLabel.textColor = UIColor(named: "PrimaryColor")
        pointsLabel.textColor = UIColor(named: "PrimaryColor")
        NameLabel.textColor = UIColor(named: "PrimaryColor")
        PointCounterLabel.textColor = UIColor(named: "PrimaryColor")
        let welcomeMessage = (Verification.init().getCurrentLanguage() == .English) ? "Good Morning" : "صباح الخير"
        TimeLabel.text = welcomeMessage
    }
    
    private func setNightSettings() {
        contentView.backgroundColor = UIColor(named: "PrimaryColor")
        TimeLabel.textColor = UIColor.white
        pointsLabel.textColor = UIColor.white
        NameLabel.textColor = UIColor.white
        PointCounterLabel.textColor = UIColor.white
        let welcomeMessage = (Verification.init().getCurrentLanguage() == .English) ? "Good Evening" : "مساء الخير"
        TimeLabel.text = welcomeMessage
    }
    
    private func configureShade(){
        layer.cornerRadius = 4
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        
    }
}
