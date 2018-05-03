//
//  FoundUserCollectionViewCell.swift
//  vk6042041
//
//  Created by james404 on 21/08/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit

class FoundUserCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var userImageView: UIImageView!
  
 
  override func prepareForReuse() {
    userImageView.image = nil
  }
  
  
  // public API of this UICollectionViewCell subclass
  // each cell in the CollectionView has its own instance of this class
  // and each instance will have its own user to show
  // as set by this var

  
  var user: User? {
    didSet {
      updateUI()
     }
  }
  
  private func updateUI() {
    
    userImageView?.image = nil
    if let profileImageURL = user?.getImageURL(withSizeParam: ConstantsStruct.Vf_user_fields.photo_100) {
      // FIXME: blocks main thread

      if let imageData = try? Data(contentsOf: profileImageURL) {
        userImageView?.image = UIImage(data: imageData)
      }
    }
    
  }
}
