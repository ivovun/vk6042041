//
//  UIViewControllerExtensions.swift
//  vfaces
//
//  Created by james404 on 13/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import Foundation
import UIKit
import VK_ios_sdk

extension UIViewController {
  func presentAlert( withTitle: String?, withMessage: String?) {
    let alert = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
    
    alert.addAction(okButton)
    self.present(alert, animated: true, completion: nil)
   }
  
  @objc func vk_Logout(sender: Any) {
    VKSdk.forceLogout()
    if let sender = sender as? UIViewController {
      sender.navigationController?.popToRootViewController(animated: true)
    }
  }
}
