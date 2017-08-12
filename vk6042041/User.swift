//
//  User.swift
//  vk6042041
//
//  Created by james404 on 30/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import Foundation

enum SerializationError: Error {
  case missing(String)
}

fileprivate func errorForUserWithId(id: String, missingField: String) -> String {
   return " for user with ID = \(id) error:  missing field = \(missingField)"
}

struct User  {
  
  
  // делал по принципу описанному в JSON Tutorial- raywenderlich.com   https://www.raywenderlich.com/150322/swift-json-tutorial-2
  let id : Int
  var usersFields :  [String : String?] = [:]
  
  public init(json: [String: Any]) throws {
    guard let id_ = json[ConstantsStruct.Vf_user_fields.id] as? Int else {
      throw SerializationError.missing(ConstantsStruct.Vf_user_fields.id)
    }
    
    id = id_
    
    /*
    "id": 2943,
    "first_name": "Вася",
    "last_name": "Бабич",
    "photo_50": "https://pp.userap...994/R5SaCBEYgBQ.jpg",
    "photo_100": "https://pp.userap...993/6iAXd5OccfY.jpg",
    "photo_200": "https://pp.userap...992/EA-w_d7LZT4.jpg",
    "photo_400_orig": "https://pp.userap...991/dArGDkkpjE8.jpg",
    "verified": 0
     */
    
    guard let first_name = json[ConstantsStruct.Vf_user_fields.first_name] as? String else {
      throw SerializationError.missing(errorForUserWithId(id: "\(id_)", missingField: ConstantsStruct.Vf_user_fields.first_name))
    }
    
    guard let last_name = json[ConstantsStruct.Vf_user_fields.last_name] as? String else {
      throw SerializationError.missing(errorForUserWithId(id: "\(id_)", missingField: ConstantsStruct.Vf_user_fields.last_name))
    }
    
    usersFields = [
      ConstantsStruct.Vf_user_fields.first_name : first_name ,
      ConstantsStruct.Vf_user_fields.last_name  : last_name ,
      ConstantsStruct.Vf_user_fields.photo_50   : json[ConstantsStruct.Vf_user_fields.photo_50]  as? String  ,
      ConstantsStruct.Vf_user_fields.photo_100  : json[ConstantsStruct.Vf_user_fields.photo_100] as? String ,
      ConstantsStruct.Vf_user_fields.photo_200  : json[ConstantsStruct.Vf_user_fields.photo_200] as? String ,
      ConstantsStruct.Vf_user_fields.photo_max  : json[ConstantsStruct.Vf_user_fields.photo_max] as? String ,
    ]
 
  }
}

extension User: CustomStringConvertible {
  public var description: String
  {
    
    var resultString = "ID = \(id)\n"
    
      for (key, element) in usersFields {
        resultString += "\(key) = \( element ?? "")\n"
      }
    
    return resultString
  }
}
