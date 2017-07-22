//
//  mainVC.swift
//  vfaces
//
//  Created by james404 on 18/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

class mainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout ))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

  
    // MARK: - Navigation
  @objc func logout(sender: Any) {
    VKSdk.forceLogout()
    self.navigationController?.popToRootViewController(animated: true)
  }
   /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
