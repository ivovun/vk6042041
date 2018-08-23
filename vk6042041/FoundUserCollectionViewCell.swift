//
//  FoundUserCollectionViewCell.swift
//  vk6042041
//
//  Created by james404 on 21/08/2017.
//  Copyright © 2017 Vladimir Filippov. All rights reserved.
//

import UIKit

class FoundUserCollectionViewCell: UICollectionViewCell, TypeWithOptional_user_Property {
  
  @IBOutlet weak var userImageView: UIImageView!
  
  @IBOutlet weak var rowNumberLabel: UILabel!
    
  override func prepareForReuse() {
    userImageView.image = nil
    rowNumber = nil
    user = nil
  }
  
  
  // public API of this UICollectionViewCell subclass
  // each cell in the CollectionView has its own instance of this class
  // and each instance will have its own user to show
  // as set by this var

  var rowNumber:Int? = 0
  var user: User?
  {
    didSet {
      updateUI()
     }
  }
  
 
  private func updateUI() {
    
    if ConstantsStruct.TestParameters.showCellRowNumber {
//      rowNumberLabel.adjustsFontSizeToFitWidth = true
//      rowNumberLabel.adjustsLetterSpacingToFitWidth = true
      rowNumberLabel?.text = "\(rowNumber ?? 0)"
    } else {
      rowNumberLabel?.text  = ""
    }
  
    User.updateImageForUserView(self, imageView: userImageView, imagePlaceHolder: ConstantsStruct.Images.kLazyLoadPlaceholderImage)
 
  }
  
  
  
}


