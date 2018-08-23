//
//  extensions.swift
//  vk6042041
//
//  Created by james404 on 21/07/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import Foundation
import UIKit

// MARK: UIView extensions
class fadeViewForActivivtyIndicator: UIView {}
class activityIndicatorForView: UIActivityIndicatorView {}

extension UIView {
  
  func addActivityIndicator() {
    
    let fadeView:UIView = fadeViewForActivivtyIndicator()
    fadeView.frame = self.frame
    fadeView.backgroundColor = UIColor.white
    fadeView.alpha = 0.4
    
    // add fade view to main view
    self.addSubview(fadeView)
    
    let activityIndicator = activityIndicatorForView(activityIndicatorStyle: .whiteLarge)
    self.addSubview(activityIndicator)
    activityIndicator.hidesWhenStopped = true
    activityIndicator.center = self.center
    activityIndicator.startAnimating()
 
  }
  
  func removeActivitiIndicator()  {
    
    for subView in self.subviews {
      if let fadeView = subView as? fadeViewForActivivtyIndicator {
        fadeView.removeFromSuperview()
      } else if let activityIndicator = subView as? activityIndicatorForView {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
       }
     }
   }
  
}
