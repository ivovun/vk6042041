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
    self.callingRequest?.execute(resultBlock:
      { [unowned self] (response) in
        
        let resultText = "Result: \(String(describing: response))"
        //      print(response?.json as Any  )
        //print(resultText)
        //      let parser = JsonParser(newJson: response?.json)
        //      print(parser ?? "no items")
        //print(response?.json["items"])
        //print(response?.responseString ?? "no")
        
        
        
        if let jsonString = response?.responseString {
          if let data = jsonString.data(using: .utf8) {
            
            do {
              let info = try  JSONDecoder().decode(UsersInfo.self, from: data)
              
              print(info )
              //let _ = UsersInfo(data: response?.json)
              self.callResult.text = resultText
              self.callingRequest = nil

              
            } catch DecodingError.dataCorrupted(let context) {
              print(context)
            } catch DecodingError.keyNotFound(let key, let context) {
              print("Key '\(key)' not found:", context.debugDescription)
              print("codingPath:", context.codingPath)
            } catch DecodingError.valueNotFound(let value, let context) {
              print("Value '\(value)' not found:", context.debugDescription)
              print("codingPath:", context.codingPath)
            } catch DecodingError.typeMismatch(let type, let context)  {
              print("Type '\(type)' mismatch:", context.debugDescription)
              print("codingPath:", context.codingPath)
            } catch {
              print("error: ", error)
            }
            
            
//            if let info = try?  JSONDecoder().decode(UsersInfo.self, from: data)  {
//              //let info = UsersInfo(jsonString: response?.responseString)
//              //print(info ?? " no users data")
//              print(info )
//              //let _ = UsersInfo(data: response?.json)
//              self.callResult.text = resultText
//              self.callingRequest = nil
//            } else  {
//              print( " decoding error ")
//              return
//            }
          }
        }
        
        
        
//        guard let jsonString = response?.responseString ,
//          let data = jsonString.data(using: .utf8) ,
//          let info = try?  JSONDecoder().decode(UsersInfo.self, from: data) else  {
//            print( " decoding error ")
//            return
//        }
//
//        //let info = UsersInfo(jsonString: response?.responseString)
//        //print(info ?? " no users data")
//        print(info )
//        //let _ = UsersInfo(data: response?.json)
//        self.callResult.text = resultText
//        self.callingRequest = nil
        
        
      }, errorBlock: { (error : Error?) in
        self.callResult.text = error as? String
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
