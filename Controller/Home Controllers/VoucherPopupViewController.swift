//
//  VoucherPopupViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/18/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class VoucherPopupViewController: UIViewController {

    @IBOutlet weak var voucerID: UILabel!
    @IBOutlet weak var voucherImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissQR))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc private func handleDismissQR() {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func dismissButtonPressed(sender: UIButton) {
        dismiss(animated: false) {
            
        }
    }
    

}
