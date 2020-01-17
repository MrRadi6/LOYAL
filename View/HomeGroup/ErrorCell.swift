//
//  ErrorCell.swift
//  Loyal
//
//  Created by Ahmed Samir on 7/18/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class ErrorCell: UITableViewCell {
    
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorButtonHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        errorButton.layer.borderWidth = 1
        errorButton.layer.borderColor = UIColor(named: "SecondryColor")?.cgColor
        
        errorImage.image = UIImage(named: "no_data_image")
        errorTitle.text = NSLocalizedString("No Data at The Moment", comment: "No Data at The Moment")
        errorButton.setTitle(NSLocalizedString("Retry", comment: "Retry"), for: .normal)
    }
    
    func addTarget(target: Any?, action: Selector, forEvent: UIControl.Event) {
        errorButton.addTarget(target, action: action, for: forEvent)
    }
    
    func hideButton() {
        errorButtonHeightConstraint.constant = 0
        errorButton.setTitle("", for: .normal)
    }
    
    func showButton() {
        errorButtonHeightConstraint.constant = 30
        errorButton.setTitle(NSLocalizedString("Retry", comment: "Retry"), for: .normal)
    }
}
