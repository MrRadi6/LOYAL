//
//  TermsViewController.swift
//  Loyal
//
//  Created by Ahmed Samir on 8/21/19.
//  Copyright © 2019 MrRadix. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var navbar : EditProfileNavBar!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.parentViewController = self
        navbar.addTarget(target: self, action: #selector(handleDismiss))
        // Do any additional setup after loading the view.
    }
    
    @objc func handleDismiss() {
        dismiss(animated: false, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
