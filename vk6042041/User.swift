//
//  User.swift
//  vk6042041
//
//  Created by james404 on 30/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import Foundation
import UIKit

enum SerializationError: Error {
  case missing(String)
}

fileprivate func errorForUserWithId(id: String, missingField: String) -> String {
   return " for user with ID = \(id) error:  missing field = \(missingField)"
}

fileprivate func tryToDecodeElseReturnDefault(defaultValue: String, values: KeyedDecodingContainer<User.CodingKeys>, key: User.CodingKeys) -> String {
  
  var resultString: String
  
  if let photo_200_try = try? values.decode(String.self, forKey: key) {
    resultString = photo_200_try
  }  else {
    resultString = defaultValue
  }
  
  return resultString
  
}

protocol TypeWithOptional_user_Property {
  var user: User? {get}
}


struct User: Decodable  {
  
  let id : Int
  let first_name: String
  let last_name: String
  let screen_name: String
  let photo: String
  let photo_50: String
  let photo_100: String
  let photo_200: String
  let photo_max: String
  let bdate: String

  
  public enum CodingKeys: String, CodingKey {
   case id
    case first_name
    case last_name
    case screen_name
    case photo
    case photo_50
    case photo_100
    case photo_200
    case photo_max
    case bdate
   }
  
  
  init(from decoder: Decoder) throws  {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(Int.self, forKey: .id)
    
    photo = tryToDecodeElseReturnDefault(defaultValue: "", values: values, key: .photo)
    first_name  = tryToDecodeElseReturnDefault(defaultValue: "", values: values, key: .first_name)
    last_name   = tryToDecodeElseReturnDefault(defaultValue: "", values: values, key: .last_name)
    screen_name = tryToDecodeElseReturnDefault(defaultValue: "", values: values, key: .screen_name)
    photo_50  = tryToDecodeElseReturnDefault(defaultValue: photo, values: values, key: .photo_50)
    photo_100 = tryToDecodeElseReturnDefault(defaultValue: photo, values: values, key: .photo_100)
    photo_200 = tryToDecodeElseReturnDefault(defaultValue: photo, values: values, key: .photo_200)
    photo_max = tryToDecodeElseReturnDefault(defaultValue: photo, values: values, key: .photo_max)
    
    bdate = tryToDecodeElseReturnDefault(defaultValue: ConstantsStruct.UserDefaults.DEFAULT_BIRTH_DATE, values: values, key: .bdate)


   }
  
 
  public func getImageURL(withSizeParam fieldName: String) -> URL? {
    
        if  let url = URL(string: fieldName) {
          return url
        } else {
          return nil
        }

   }
  
  static func  updateImageForUserView(_ someType: TypeWithOptional_user_Property, imageView: UIImageView, imagePlaceHolder: UIImage, addActivitiIndicator: Bool = false) {
    imageView.image = imagePlaceHolder
    // load image.
    
    if addActivitiIndicator {
      imageView.addActivityIndicator()
    }
    
    if let imageURL = someType.user?.photo_200 {
      ImageManager.sharedInstance.downloadImageFromURL(imageURL) { (success, image,imageURL ) -> Void in
        if success && image != nil && someType.user!.photo_200 == imageURL {
          if addActivitiIndicator {
            imageView.removeActivitiIndicator()
          }
          imageView.image = image
        }
      }
    }
  }

}

 
