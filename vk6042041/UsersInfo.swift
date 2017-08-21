//
//  UsersInfo.swift
//  vk6042041
//
//  Created by james404 on 05/08/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit
import VK_ios_sdk

class UsersInfo {
  
  let users: [User]
  var errorDescription: String?
  
  
    

  init?(jsonString: String?) {
    
     //VKApi.users().search(ConstantsStruct.Searches.defaultGirlsSearch)
    
    guard let jsonString = jsonString ,
      let data = jsonString.data(using: .utf8) ,
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      return nil
    }
    
    guard  let response = json?["response"] as? [String:Any],
      let count = response["count"] as? Int,
      count > 0 ,
      let items = response["items"] as? [[String: Any]]
      else {
        return nil
    }
    
    var _users: [User] = []
    
    for (_, user_dict) in items.enumerated() {
      
      do {
        let user = try User(json: user_dict)
        //print(user)
        _users.append(user)

      } catch let error {
        print(error)
        return nil
      }
     }
    
    users = _users
   }
  
  
}

extension UsersInfo: CustomStringConvertible {
  public var description: String {
    
    var resultString = " no users "
    
    resultString = ""
    for (index, el) in users.enumerated() {
      resultString += "\(index). \n    \(el)"
    }
    
    return resultString
  }
}
