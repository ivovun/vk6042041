//
//  SlideInPresentationController.swift
//  MedalCount
//
//  Created by vladimirfilippov on 30/11/2018.
//  Copyright © 2018 Ron Kliffer. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
  //1
  //MARK: - Properties
  fileprivate var dimmingView: UIView!
  private var direction: PresentationDirection
  override var frameOfPresentedViewInContainerView: CGRect  {
    //1
    var frame: CGRect = .zero
    frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
    
    //2
    switch direction {
    case .right:
      frame.origin.x = containerView!.frame.width * (4.0 / 7.0)
    case .bottom:
      frame.origin.y = containerView!.frame.height * (1.0 / 3.0)
    default:
      frame.origin = .zero
    }
    
    return frame
  }
  
  //2
  init(presentedViewController: UIViewController,
       presentingViewController: UIViewController?,
       direction: PresentationDirection ) {
    
    //3
    self.direction = direction
    
    
    //4
    super.init(presentedViewController: presentedViewController, presenting: presentedViewController )
    
    //5
    setupDimmingView()
    
  }
  
  
  override func presentationTransitionWillBegin() {
    //1
    containerView?.insertSubview(dimmingView, at: 0)
    
    //2
    NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView" : dimmingView]))
    NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView" : dimmingView]))
    
    //3
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 1.0
    })
  }
  
  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 0.0
    })
  }
  
  override func containerViewWillLayoutSubviews() {
    
    direction = UIApplication.shared.statusBarOrientation.isLandscape ? .right : .bottom
    
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    switch direction {
    case .left, .right:
      return CGSize(width: parentSize.width * (1.0 / 3.0), height: parentSize.height)
    default:
      return CGSize(width: parentSize.width, height: parentSize.height * (2.0/3.0))
    }
  }
  
}


extension SlideInPresentationController {
  
  func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recogniszer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }
  
  @objc dynamic func handleTap(recogniszer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated: true)
  }
  
}
