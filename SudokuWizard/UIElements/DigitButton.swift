//
//  DigitButton.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 2/8/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

class DigitButton: UIButton
{
  let digit : Digit
  
  let fontName = UIFont.systemFont(ofSize: 12.0).fontName
  
  var borderPath : UIBezierPath?
  
  var tint = UIColor.black {
    didSet { self.setNeedsDisplay() }
  }
  
  var highlightTint : UIColor {
    var red = CGFloat(0.0)
    var green = CGFloat(0.0)
    var blue = CGFloat(0.0)
    var alpha = CGFloat(0.0)
    tint.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return UIColor(red: 0.5*(1.0+red), green: 0.5*(1.0+green), blue: 0.5*(1.0+blue), alpha: alpha)
  }
  
  required init(_ digit:Digit)
  {
    self.digit = digit
    super.init(frame:.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var isEnabled : Bool {
    didSet {
      if isEnabled != oldValue {
      
        if let bp = borderPath, isEnabled {
          layer.shadowPath = bp.cgPath
          layer.shadowOpacity = 0.5
          layer.shadowOffset = CGSize(width:2.0, height:2.0)
          layer.shadowRadius = 6.0
          layer.masksToBounds = false
        }
        else
        {
          layer.shadowOpacity = 0.0
        }
      }
    }
  }
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted != oldValue { setNeedsDisplay() }
    }
  }
  
  override func draw(_ rect: CGRect)
  {
    super.draw(rect)
    
    let center = CGPoint(x: rect.origin.x + 0.5*rect.width, y: rect.origin.y + 0.5*rect.height)
    let radius = 0.5 * min( rect.width, rect.height )
    
    borderPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: 2*CGFloat.pi, clockwise: true)
    
    ( isHighlighted ? highlightTint : isSelected ? tint : UIColor.white ).setFill()
    borderPath?.fill()
    
    if isEnabled {
      tint.setStroke()
      borderPath?.stroke()
    }
    
    let digitColor = ( isEnabled ? (isSelected ? UIColor.white : tint) : UIColor.gray )
    let inset : CGFloat = (isEnabled ? 3.0 : 5.0)
    digit.description.draw(in: rect.insetBy(dx: inset, dy: inset), fontName: fontName, color: digitColor)
  }
}
