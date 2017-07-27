//
//  VKStartScreenVC.swift
//  vfaces
//
//  Created by james404 on 13/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk
 
//var SCOPE = [String]()
//let VK_APP_ID = "6042041"

class VKStartScreenVC: UIViewController, VKSdkUIDelegate, VKSdkDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
      //SCOPE = [VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES]
      VKSdk.initialize(withAppId: GlobalConstantsForObjCAndSwift.VK_APP_ID ).register(self)
      VKSdk.instance().uiDelegate = self
      VKSdk.wakeUpSession(GlobalConstantsForObjCAndSwift.SCOPE) { (state, error) in
        if state == VKAuthorizationState.authorized {
          print("hey! you are authorised!")
          self.startWorking()
        } else if error != nil {
          self.presentAlert(withTitle: "Error", withMessage: error.debugDescription)
        }
      }
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  // MARK: - VKSdkUIDelegate
  func vkSdkShouldPresent(_ controller: UIViewController!) {
    self.navigationController?.topViewController?.present(controller, animated: true, completion: nil)
  }
  
  func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
    let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
    vc?.present(in: self.navigationController?.topViewController)
  }
  
  // MARK: - VKSdkDelegate
  func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
    if (result.token != nil) {
      print("authorisation success!!!")
      startWorking()
    } else if result.error != nil {
      self.presentAlert(withTitle: nil, withMessage: "Access denied\n\(result.error)")
     }
  }
 
  func vkSdkUserAuthorizationFailed() {
    self.presentAlert(withTitle: nil, withMessage: "Access denied")
    self.navigationController?.popToRootViewController(animated: true)
  }

  @IBAction func authorize(_ sender: Any?) {
    VKSdk.authorize(GlobalConstantsForObjCAndSwift.SCOPE)
  }
  
  @IBAction func logout(_ sender: UIButton) {
    VKSdk.forceLogout()
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
    self.authorize(nil)
  }
  
  
    // MARK: - Navigation
  
  func startWorking() {
    performSegue(withIdentifier: GlobalConstantsForObjCAndSwift.SHOW_TEST_VC_SEGUE, sender: self)
  }
  
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

 
