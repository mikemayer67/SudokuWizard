//
//  Transitions.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/20/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation
import UIKit

class CustomTransition : NSObject, UIViewControllerAnimatedTransitioning {
  
  let duration : Double
  let operation : UINavigationController.Operation
  
  init(_ operation:UINavigationController.Operation, duration:Double = 0.35)
  {
    self.duration = duration
    self.operation = operation
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
  {
    if performTransition(using: transitionContext) == false
    {
      let toVC     = transitionContext.viewController(forKey: .to)!
      let toView   = toVC.view!
      toView.frame = transitionContext.finalFrame(for: toVC)
      transitionContext.completeTransition(true)
    }
  }
  
  func performTransition(using transitionContext: UIViewControllerContextTransitioning) -> Bool {
    return false
  }
}

class SettingsTransition : CustomTransition
{
  init(_ operation : UINavigationController.Operation)
  {
    super.init(operation)
  }
  
  override func performTransition(using transitionContext: UIViewControllerContextTransitioning) -> Bool
  {
    let fromVC   = transitionContext.viewController(forKey: .from)!
    let toVC     = transitionContext.viewController(forKey: .to)!
    
    let fromView = fromVC.view!
    let toView   = toVC.view!
    
    let bounds     = UIScreen.main.bounds
    let finalFrame = transitionContext.finalFrame(for: toVC)
    
    transitionContext.containerView.addSubview(toView)
    
    toView.frame = finalFrame.offsetBy(dx: bounds.width, dy: 0.0)
    
    switch operation
    {
    case .push:
      UIView.animate(withDuration: duration, animations: {
        toView.frame = finalFrame
        fromView.frame = finalFrame.offsetBy(dx: -bounds.width/4.0, dy: 0.0)
      },completion: { _ in
        transitionContext.completeTransition(true)
      } )
      
    case .pop:
      transitionContext.containerView.sendSubviewToBack(toView)
      toView.frame = finalFrame.offsetBy(dx: -bounds.width/4.0, dy: 0.0)
      
      UIView.animate(withDuration: duration, animations: {
        toView.frame = finalFrame
        fromView.frame = finalFrame.offsetBy(dx: bounds.width, dy: 0.0)
      }, completion: { _ in
        transitionContext.completeTransition(true) }
      )
      
    default:
      return false
    }
    
    return true
  }
}


class NewPuzzleTransition : CustomTransition
{
  init(_ operation : UINavigationController.Operation)
  {
    super.init(operation,duration: 0.35)
  }
  
  override func performTransition(using transitionContext: UIViewControllerContextTransitioning) -> Bool
  {
    guard let fromVC = transitionContext.viewController(forKey:.from),
      let toVC = transitionContext.viewController(forKey: .to),
      let toView = toVC.view,
      let fromView = fromVC.view
      else { return false }
    
    let containerView = transitionContext.containerView
    
    let midView = UIView(frame: containerView.frame)
    midView.backgroundColor = fromVC.navigationController?.navigationBar.barTintColor ?? UIColor.red
    containerView.insertSubview(midView, at: 0)

    if operation == .push { containerView.addSubview(toView) }
    else                  { containerView.insertSubview(toView, at: 1) }

    let f = 0.6
    toView.alpha = 0.0
    UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .calculationModeCubic, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: f, animations: {
        fromView.alpha = 0.0
      })
      UIView.addKeyframe(withRelativeStartTime: 1.0-f, relativeDuration: f, animations: {
        toView.alpha = 1.0
      })
    }) { (_) in
      fromView.alpha = 1.0
      transitionContext.completeTransition(true)
      midView.removeFromSuperview()
    }
    
    return true
  }
}
