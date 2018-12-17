//
//  SlideInPresentationAnimator.swift
//  MedalCount
//
//  Created by vladimirfilippov on 02/12/2018.
//  Copyright © 2018 Ron Kliffer. All rights reserved.
//

import UIKit

class SlideInPresentationAnimator: NSObject {
  
  //1
  //MARK: - Properties
  //Declare a direction property that tells the animation controller the direction from which it should animate the view controller’s view.
  let direction: PresentationDirection
  
  //2
  //Declare an isPresentation property to tell the animation controller whether to present or dismiss the view controller.
  let isPresentation: Bool
  
  //3
  // MARK: - Initialisers
  init(direction: PresentationDirection, isPresentation: Bool) {
    self.direction = direction
    self.isPresentation = isPresentation
    super.init()
  }

}



extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    // 1
    //If this is a presentation, the method asks the transitionContext for the view controller associated with the .to key, aka the view controller you’re moving to. If dismissal, it asks the transitionContext for the view controller associated with the .from, aka the view controller you’re moving from.
    let key = isPresentation ? UITransitionContextViewControllerKey.to
      : UITransitionContextViewControllerKey.from
    
    let controller = transitionContext.viewController(forKey: key)!
    
    // 2
    //If the action is a presentation, your code adds the view controller’s view to the view hierarchy; this code uses the transitionContext to get the container view
    if isPresentation {
      transitionContext.containerView.addSubview(controller.view)
    }
    
    // 3
    //Calculate the frames you’re animating from and to. The first line asks the transitionContext for the view’s frame when it’s presented. The rest of the section tackles the trickier task of calculating the view’s frame when it’s dismissed. This section sets the frame’s origin so it’s just outside the visible area based on the presentation direction.
    let presentedFrame = transitionContext.finalFrame(for: controller)
    var dismissedFrame = presentedFrame
    switch direction {
    case .left:
      dismissedFrame.origin.x = -presentedFrame.width
    case .right:
      dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
    case .top:
      dismissedFrame.origin.y = -presentedFrame.height
    case .bottom:
      dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
    }
    
    // 4
    //Determine the transition’s initial and final frames. When presenting the view controller, it moves from the dismissed frame to the presented frame — vice versa when dismissing
    let initialFrame = isPresentation ? dismissedFrame : presentedFrame
    let finalFrame = isPresentation ? presentedFrame : dismissedFrame
    
    // 5
    //Lastly, this method animates the view from initial to final frame. Note that it calls completeTransition(_:) on the transitionContext to show the transition has finished.
    let animationDuration = transitionDuration(using: transitionContext)
    controller.view.frame = initialFrame
    
    UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [], animations: {
      controller.view.frame = finalFrame

    }) { finished in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

    }
    
//    UIView.animate(withDuration: animationDuration, animations: {
//      controller.view.frame = finalFrame
//    }) { finished in
//      transitionContext.completeTransition(finished)
//    }
  }
}
