//
//  UsersPresenter.swift
//  vk6042041
//
//  Created by james404 on 04/08/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import UIKit

class UsersPresenter: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout   {
  
  var needCalculateItemSize = true
  
  var numberOfPhotosColumns = ConstantsStruct.SearchesDefaults.numberOfPhotosColumns {
    didSet{
      ConstantsStruct.SearchesDefaults.numberOfPhotosColumns = numberOfPhotosColumns
      needCalculateItemSize = true
      
      //calculateItemSize()
    }
  }

  
  private func calculateItemSize() -> CGSize {
    
    //return CGSize(width:  itemWidth, height: itemWidth)


    if needCalculateItemSize == false {
      return CGSize(width:  itemWidth, height: itemWidth)
    }
    needCalculateItemSize = false

    itemWidth = windowTraitParameters.minSize / CGFloat( numberOfPhotosColumns)

//    let layout  = collectionViewLayout as! UICollectionViewFlowLayout
//    UIView.animate(withDuration: ConstantsStruct.Durations.pinchCellResizeInSeconds) {
//      layout.itemSize = CGSize(width: self.itemWidth, height: self.itemWidth)
//    }
    return CGSize(width:  itemWidth, height: itemWidth)
  }


  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    seacrhController = collectionView.window
   }
  
  private var itemWidth: CGFloat = 0.0
  weak var seacrhController : UIViewController?
  var showStatusBar: Bool = true
  
  var windowTraitParameters: ( maxSize: CGFloat, minSize: CGFloat, inPortrait: Bool,topPadding:CGFloat, rightPadding:CGFloat, maxAllowableCollectionViewHeight: CGFloat, maxAllowableCollectionViewWidth: CGFloat)
  {
    let maxSize: CGFloat
    let minSize: CGFloat
    let inPortrait: Bool
    var maxAllowableCollectionViewHeight: CGFloat
    let maxAllowableCollectionViewWidth: CGFloat
    
    let window = UIApplication.shared.keyWindow
    let topPadding = window!.safeAreaInsets.top
    //    let bottomPadding = window!.safeAreaInsets.bottom
    let rightPadding = window!.safeAreaInsets.right
    
    if window!.frame.height > window!.frame.width {
      maxSize = window!.frame.height
      minSize = window!.frame.width
      inPortrait = true
    } else {
      inPortrait = false
      maxSize = window!.frame.width
      minSize = window!.frame.height
    }
    
    if inPortrait {
      maxAllowableCollectionViewHeight = maxSize
      maxAllowableCollectionViewHeight = maxAllowableCollectionViewHeight + itemWidth / 5
      
      maxAllowableCollectionViewWidth = minSize
    } else {
      maxAllowableCollectionViewHeight = minSize
      maxAllowableCollectionViewWidth = maxSize
    }
    
    if let navBar = seacrhController?.navigationController?.navigationBar {
      if !navBar.isHidden {
        maxAllowableCollectionViewHeight = maxAllowableCollectionViewHeight - navBar.frame.height
      }
    }
    if showStatusBar {
      maxAllowableCollectionViewHeight  = maxAllowableCollectionViewHeight - UIApplication.shared.statusBarFrame.height
    }
    
    return (maxSize, minSize, inPortrait,topPadding, rightPadding ,maxAllowableCollectionViewHeight, maxAllowableCollectionViewWidth )
  }

  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return calculateItemSize()
  }

}
