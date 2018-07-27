//
//  SelectedUserHeaderUICollectionReusableView.swift
//  vk6042041
//
//  Created by james404 on 20/07/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import UIKit

class UserInfoSectionHeaderUICollectionReusableView: UICollectionReusableView {
  
 
  @IBOutlet weak var userPhoto_200: UIImageView!
  @IBOutlet weak var age: UILabel!
  @IBOutlet weak var bdate: UILabel!
  @IBOutlet weak var last_name: UILabel!
  @IBOutlet weak var first_name: UILabel!
  @IBOutlet weak var screen_name: UILabel!
  var user: User! {
    didSet {
      if superview?.window != nil {
        
        last_name.text = user.last_name
        first_name.text = user.first_name
        screen_name.text = user.screen_name
        bdate.text = user.bdate 
        age.text = ""
        
        

      }
    }
  }
  
  
  
}
