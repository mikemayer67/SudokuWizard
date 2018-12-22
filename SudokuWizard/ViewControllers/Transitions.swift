//
//  Transitions.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/20/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation
import UIKit

class SettingsTransition : NSObject, UIViewControllerAnimatedTransitioning
{
  let duration = 0.35
  var operation : UINavigationController.Operation
  
  init(_ operation : UINavigationController.Operation)
  {
    self.operation = operation
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
  {
    let fromVC   = transitionContext.viewController(forKey: .from)!
    let toVC     = transitionContext.viewController(forKey: .to)!
    let cv       = transitionContext.containerView
    let fromView = fromVC.view!
    let toView   = toVC.view!
    
    let bounds = UIScreen.main.bounds
    let finalFrame = transitionContext.finalFrame(for: toVC)
    
    cv.addSubview(toView)
    
    switch operation {
    case .push:
      toView.frame = finalFrame.offsetBy(dx: bounds.width, dy: 0.0)
      
      UIView.animate(withDuration: duration, animations: {
        toView.frame = finalFrame
        fromView.frame = finalFrame.offsetBy(dx: -bounds.width/4.0, dy: 0.0)
      },completion: { _ in
        transitionContext.completeTransition(true)
      } )
      
    case .pop, .none:
      
      cv.sendSubviewToBack(toView)
      toView.frame = finalFrame.offsetBy(dx: -bounds.width/4.0, dy: 0.0)

      UIView.animate(withDuration: duration, animations: {
        toView.frame = finalFrame
        fromView.frame = finalFrame.offsetBy(dx: bounds.width, dy: 0.0)
      }, completion: { _ in transitionContext.completeTransition(true) }
      )
    }
  }

}
