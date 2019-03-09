//
//  EditorBackgroundView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 2/8/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

protocol EditorBackgroundViewDelegate
{
  func handleBackgroundTap()
}

@IBDesignable
class EditorBackgroundView : UIView
{
  @IBOutlet weak var controller : NewPuzzleViewController!
  
  @IBInspectable var bottomColor : UIColor = UIColor.white {
    didSet { self.updateGradient() }
  }
  
  @IBInspectable var topColor : UIColor = UIColor.black {
    didSet { self.updateGradient() }
  }
  
  var delegate : EditorBackgroundViewDelegate?
  
  override class var layerClass : AnyClass
  {
    return CAGradientLayer.self
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.handleBackgroundTap()
  }
  
  var curGradientLayer : CAGradientLayer?
  
  func updateGradient()
  {
    if let gl = layer as? CAGradientLayer
    {
      gl.colors = [topColor.cgColor,bottomColor.cgColor]
      gl.startPoint = CGPoint(x: 0.5, y: 0.0)
      gl.endPoint = CGPoint(x: 0.5, y: 1.0)
      gl.frame = self.bounds
    }
  }
}
