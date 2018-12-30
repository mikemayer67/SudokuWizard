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
    let finalFrame    = transitionContext.finalFrame(for: toVC)
    
    switch operation
    {
    case .push:
      containerView.addSubview(toView)
      toView.layer.cornerRadius = 10.0
      toView.transform = CGAffineTransform(translationX: 0.0, y: -finalFrame.height/2.0).scaledBy(x: 0.01, y: 0.01)
      
      UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
        toView.layer.cornerRadius = 0.0
        toView.transform = CGAffineTransform.identity
      }) { _ in
        transitionContext.completeTransition(true)
      }
      
    case .pop:
      containerView.insertSubview(toView, at: 0)
      
      UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
        fromView.transform = CGAffineTransform(translationX: 0.0, y: -finalFrame.height/2.0).scaledBy(x: 0.1, y: 0.1)
        fromView.layer.cornerRadius = 10.0
        fromView.alpha = 0.0
      }) { _ in
        transitionContext.completeTransition(true)
        fromView.transform = CGAffineTransform.identity
        fromView.layer.cornerRadius = 0.0
        fromView.alpha = 1.0
      }
      
    default:
      return false
    }
    
    return true
  }
}
