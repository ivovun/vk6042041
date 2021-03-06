//
//  GlobalConstantsForObjCAndSwift.swift
//  vfaces
//
//  Created by james404 on 16/07/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import Foundation
import VK_ios_sdk

@objc class GlobalConstantsForObjCAndSwift : NSObject {
  
  static let VK_APP_ID : String =  { return "6042041" }()
  
  static let SCOPE : [String] = { return [VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES] }()
  
  static let SHOW_MAIN_VC_SEGUE: String = { return "Show mainVC"}()
  static let SHOW_TEST_VC_SEGUE: String = { return "Show TestVC"}()
  
  
}
