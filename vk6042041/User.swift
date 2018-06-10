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

struct User: Codable  {
  
  let id : Int
  let first_name: String
  let last_name: String
  let screen_name: String
  let photo: String
  let photo_50: String
//  let photo_100: String
//  let photo_200: String
//  let photo_max: String
//
//
//  var usersFields :  [String : String?] = [:]
  
//  public init(id: Int,
//              first_name: String,
//              last_name: String,
//              photo_50: String,
//              photo_100:String,
//              photo_200:String,
//              photo_max:String) {
//
//    self.id = id
//    self.first_name = first_name
//    self.last_name  = last_name
//    self.photo_50   = photo_50
//    self.photo_100  = photo_100
//    self.photo_200  = photo_200
//    self.photo_max  = photo_max
  
  //}
  
  // делал по принципу описанному в JSON Tutorial- raywenderlich.com   https://www.raywenderlich.com/150322/swift-json-tutorial-2
//  public init(json: [String: Any]) throws {
//    guard let id_ = json[ConstantsStruct.Vf_user_fields.id] as? Int else {
//      throw SerializationError.missing(ConstantsStruct.Vf_user_fields.id)
//    }
//    
//    id = id_
//    
//    /*
//    "id": 2943,
//    "first_name": "Вася",
//    "last_name": "Бабич",
//    "photo_50": "https://pp.userap...994/R5SaCBEYgBQ.jpg",
//    "photo_100": "https://pp.userap...993/6iAXd5OccfY.jpg",
//    "photo_200": "https://pp.userap...992/EA-w_d7LZT4.jpg",
//    "photo_max": "https://pp.userap...991/dArGDkkpjE8.jpg",
//    "verified": 0
//     */
//    
//    guard let _first_name = json[ConstantsStruct.Vf_user_fields.first_name] as? String else {
//      throw SerializationError.missing(errorForUserWithId(id: "\(id_)", missingField: ConstantsStruct.Vf_user_fields.first_name))
//    }
//    
//    guard let _last_name = json[ConstantsStruct.Vf_user_fields.last_name] as? String else {
//      throw SerializationError.missing(errorForUserWithId(id: "\(id_)", missingField: ConstantsStruct.Vf_user_fields.last_name))
//    }
//    
//    usersFields = [
//      ConstantsStruct.Vf_user_fields.first_name : _first_name ,
//      ConstantsStruct.Vf_user_fields.last_name  : _last_name ,
//      ConstantsStruct.Vf_user_fields.photo_50   : json[ConstantsStruct.Vf_user_fields.photo_50]  as? String  ,
//      ConstantsStruct.Vf_user_fields.photo_100  : json[ConstantsStruct.Vf_user_fields.photo_100] as? String ,
//      ConstantsStruct.Vf_user_fields.photo_200  : json[ConstantsStruct.Vf_user_fields.photo_200] as? String ,
//      ConstantsStruct.Vf_user_fields.photo_max  : json[ConstantsStruct.Vf_user_fields.photo_max] as? String ,
//    ]
//    
//      first_name = ""
//      last_name = ""
//      photo_50 = ""
//      photo_100 = ""
//      photo_200 = ""
//      photo_max = ""
//
//  }
  
  public func getImageURL(withSizeParam fieldName: String) -> URL? {
    
    return nil
    
//    if let urlString = usersFields[fieldName] as? String, let url = URL(string: urlString) {
//      return url
//    } else {
//      return nil
//    }
  }
}

//extension User: CustomStringConvertible {
//  public var description: String
//  {
//    
//    //resultString =
//    
////    var resultString = "ID = \(id)\n"
////
////      for (key, element) in usersFields {
////        resultString += "\(key) = \( element ?? "")\n"
////      }
////
//    return self
//  }
//}
