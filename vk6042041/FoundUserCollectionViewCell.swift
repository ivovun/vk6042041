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
  
  @IBOutlet weak var rowNumberLabel: UILabel!
    override func prepareForReuse() {
    userImageView.image = nil
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
  
  //
 
  private func updateUI() {
    
    if ConstantsStruct.TestParameters.showCellRowNumber {
//      rowNumberLabel.adjustsFontSizeToFitWidth = true
//      rowNumberLabel.adjustsLetterSpacingToFitWidth = true
      rowNumberLabel?.text = "\(rowNumber ?? 0)"
    } else {
      rowNumberLabel?.text  = ""
    }

//    userImageView?.image = nil
//
//
//
//    if let user = user {
//      userImageView?.loadImageUsingUrlString(urlString:  user.photo_200)
//    }
//
//    if let user = user,  let profileImageURL = URL(string: user.photo_200)   {
//      // FIXME: blocks main thread
//
////      if let imageData = try? Data(contentsOf: profileImageURL) {
////        userImageView?.image = UIImage(data: imageData)
////      }
//      userImageView.imageFromServerURL(urlString: user.photo_200)
//    }
    
  }
}

//extension UIImageView {
//  public func imageFromServerURL(urlString: String) {
//
//    URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
//
//      if error != nil {
//        print(error)
//        return
//      }
//      DispatchQueue.main.async {
//        let image = UIImage(data: data!)
//        self.image = image
//      }
//
//    }).resume()
//  }
//
//}

