//
//  ConstantsStruct.swift
//  vk6042041
//
//  Created by james404 on 27/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

//
//  constants.swift
//  vk6042041
//
//  Created by james404 on 27/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import Foundation
import UIKit

struct ConstantsStruct {
  
  struct CellIdentifiers {
    static let Blue = "BlueCellIdentifier"
    static let Large = "LargeCellIdentifier"
  }
  
  struct FontSizes {
    static let Large: CGFloat = 14.0
    static let Small: CGFloat = 10.0
  }
  
  
  struct Emojis {
    static let Happy = "😄"
    static let Sad = "😢"
  }
  
  struct SegueIdentifiers {
    static let API_CALL = "API_CALL"
    static let Detail = "DetailViewController"
  }
  
  struct VK_API_FIELDS {
    
    static let id = "id"
    static let first_name = "first_name"
    static let last_name  = "last_name"
    
    //photo
    static let photo = "photo"
    static let photo_50 = "photo_50"
    static let photo_100 = "photo_100"
    static let photo_200 = "photo_200"
    static let photo_200_orig = "photo_200_orig"
    static let photo_400 = "photo_400"
    static let photo_400_orig = "photo_400_orig"
    static let VK_API_SEARCH_FIELDS = [photo,photo_50,photo_100,photo_200, photo_400_orig].joined(separator: ",")
  }
  
}
