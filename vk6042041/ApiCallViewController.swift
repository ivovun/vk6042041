//
//  ApiCallViewController.swift
//  vk6042041
//
//  Created by james404 on 25/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

class ApiCallViewController: UIViewController {
  
  var callingRequest: VKRequest?
  @IBOutlet weak var callResult: UITextView!
  
  @IBOutlet weak var methodName: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.methodName.text = self.callingRequest?.methodName
    self.callingRequest?.debugTiming = true
    self.callingRequest?.requestTimeout = 10
    self.callingRequest?.execute(resultBlock: { [unowned self] (response) in
      self.callResult.text = "Result: \(String(describing: response))"
      self.callingRequest = nil
      }, errorBlock: { (error : Error?) in
      self.callResult.text = error as! String
      self.callingRequest = nil
    })
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  deinit {
    self.callingRequest = nil
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
