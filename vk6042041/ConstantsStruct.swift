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
import VK_ios_sdk


struct ConstantsStruct {
  
  
  
  struct CellIdentifiers {
    static let FoundUsersCollectionViewCell = "foundUsersCollectionViewCell"
    static let SelectedUserCollectionViewCell = "selectedUserCollectionViewCell"
    static let UserInfoSectionHeaderUICollectionReusableView = "UserInfoSectionHeaderUICollectionReusableView"
  }
  
  struct FontSizes {
    static let Large: CGFloat = 14.0
    static let Small: CGFloat = 10.0
  }
  
  
  struct Sizes {
    static let searchBarHeight: CGFloat = 56.0
    static let constraintTolerance: CGFloat = 10.0
    static let maxPortionOfCellHeightThatCanBeClipped: CGFloat =  0.2

  }
  
 
  struct SegueIdentifiers {
    static let API_CALL = "API_CALL"
    static let SHOW_COLLECTION_VIEW_SEARCH = "ShowFoundUsersCVC"
    static let SHOW_USER_INFO = "showUserInfo"
    
     
    static let Detail = "DetailViewController"
  }
  
  struct LazyTags {
    static let tagForCollectionHeaderImageView = 1

  }
  
  struct SearchParameters {
    static let max_VK_API_COUNT = 900 // 900 60 22
    static let min_VK_API_COUNT = 8 // меньше 10 не запрашивать  так как у меня проерка на makeNewSearchIfNeeded
    static let max_quantityOfsearches = 10  //// 1000 / 57 = 18 хотя потом нужно будет отменить при смене параметров поиска
    static let maxNumberOfColumns = 20
  }
  
  struct UserDefaults {
    static let DEFAULT_BIRTH_DATE = "1.1.0001"
  }
  
  struct Durations {
    static let pinchCellResizeInSeconds = 1.0
    static let correctContentOffsetForPinchOrRotate = 0.5
  }
  
  struct Images {
    static let kLazyLoadPlaceholderImage = UIImage(named: "placeholder")!

  }
  
  struct TestParameters {
    static let showCellRowNumber = true
  }

  struct SearchesDefaults {
    static let SearchParameters = [
      //  VK_API_ONLINE:1,
      VK_API_OFFSET: 0,
      VK_API_COUNT: max(ConstantsStruct.SearchParameters.max_VK_API_COUNT, ConstantsStruct.SearchParameters.min_VK_API_COUNT),
//      "count": 157,
      VK_API_AGE_FROM: 22,
      VK_API_AGE_TO: 32,
//      VK_API_BIRTH_DAY: 22,
      VK_API_BIRTH_MONTH: 11,
      VK_API_CITY: 1,
      VK_API_COUNTRY:1,
      VK_API_ONLINE:0,
      VK_API_PHOTO:1,
      VK_API_SEX:2,
      VK_API_STATUS:1,
      VK_API_HAS_PHOTO:1,
       VK_API_FIELDS: "\(VK_API_PHOTO), \(ConstantsStruct.Vf_user_fields.squarePhotosCommaSeparatedString)"
      ] as [String : Any]
    static var numberOfPhotosColumns = 3
  }
  
  struct Vf_user_fields {
    
    static let id = "id"
    static let first_name = "first_name"
    static let last_name  = "last_name"
    static let screen_name  = "screen_name"
    static let bdate  = "bdate"
    
    
    
    //photo  описания фото тут https://vk.com/dev/objects/user_2
    //квадратные
    static let photo     = "photo"
    static let photo_50  = "photo_50"
    static let photo_100 = "photo_100"
    static let photo_200 = "photo_200"
    static let photo_max = "photo_max"
    
    //не квадратные
    static let photo_200_orig = "photo_200_orig"
    static let photo_400_orig = "photo_400_orig"
    static let photo_max_orig = "photo_max_orig"
    
    static let squarePhotosCommaSeparatedString = [id,first_name,screen_name,last_name, photo, photo_200].joined(separator: ",")
//    static let squarePhotosCommaSeparatedString = [id,first_name,screen_name,last_name, photo, VK_API_PHOTO,photo_50,photo_100,photo_200, photo_max].joined(separator: ",")
//    static let squarePhotosCommaSeparatedString = [id,first_name,screen_name,last_name, photo_200].joined(separator: ",")
  }
  
}
