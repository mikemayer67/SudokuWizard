//
//  PuzzleBackgroundView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 2/8/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

@IBDesignable
class EditorBackgroundView : UIView
{
  @IBOutlet weak var controller : NewPuzzleViewController!
  
  @IBInspectable var startColor : UIColor = UIColor.white {
    didSet { self.updateGradient() }
  }
  
  @IBInspectable var endColor : UIColor = UIColor.black {
    didSet { self.updateGradient() }
  }
  
  override func 

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    controller.handleBackgroundTap()
  }
  
  var curGradientLayer : CAGradientLayer?
  
  func updateGradient()
  {
    let gl = CAGradientLayer()
    gl.colors = [startColor.cgColor,endColor.cgColor]
    gl.startPoint = CGPoint(x: 0.5, y: 0.0)
    gl.endPoint = CGPoint(x: 0.5, y: 1.0)
    gl.frame = self.bounds
    
    if curGradientLayer != nil { curGradientLayer!.removeFromSuperlayer() }
    curGradientLayer = gl
    
    layer.addSublayer(gl)
  }
}
