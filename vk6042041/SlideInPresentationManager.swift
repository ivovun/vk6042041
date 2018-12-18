//
//  SlideInPresentationManager.swift
//  MedalCount
//
//  Created by vladimirfilippov on 29/11/2018.
//  Copyright © 2018 Ron Kliffer. All rights reserved.
//

import UIKit

enum PresentationDirection {
  case left
  case top
  case right
  case bottom
}

class SlideInPresentationManager: NSObject {
  
  
  
  var direction = PresentationDirection.left
  // to indicate if the presentation supports compact height.
  var disableCompactHeight = false
  
  
}


extension SlideInPresentationManager:UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                               presentingViewController: presenting,
                                                               direction: direction)
    presentationController.delegate = self
    
    return presentationController
  }
  
  //returns the animation controller for presenting the view controller
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    guard let  presented = presented as? HasSwipeInterractionControllerProperty else {
      return SlideInPresentationAnimator(direction: direction, isPresentation: true, interactionController: nil )
    }
    
    return SlideInPresentationAnimator(direction: direction, isPresentation: true, interactionController: presented.swipeInteractionController )
  }
  
  //returns the animation controller for dismissing the view controller
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    guard let  dismissed = dismissed as? HasSwipeInterractionControllerProperty else {
      return SlideInPresentationAnimator(direction: direction, isPresentation: true, interactionController: nil )
    }
    
    return SlideInPresentationAnimator(direction: direction, isPresentation: false, interactionController: dismissed.swipeInteractionController )
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
      guard let animator = animator as? SlideInPresentationAnimator,
        let interactionController = animator.interactionController,
        interactionController.interactionInProgress
        else {
          return nil
      }
      return interactionController
  }
  
  
}

extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
  
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    
    if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
      return .overFullScreen
    } else {
      return .none
    }
    
  }
  
  
  //use case where you’d have a view that can only show in regular height. Maybe there’s something on there that’s just too tall to fit in a compact height
  func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
    guard style == .overFullScreen  else { return nil }
    
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RotateViewController")
    
  }
  
}
