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
  
  var borderPath : UIBezierPath!
  
  var tint           = UIColor.black  { didSet { self.setNeedsDisplay() } }
  var baseColor      = UIColor.white  { didSet { self.setNeedsDisplay() } }
  var highlightColor = UIColor.yellow { didSet { self.setNeedsDisplay() } }
  var inactiveColor  = UIColor.gray   { didSet { self.setNeedsDisplay() } }
  
  override var isSelected : Bool      { didSet { self.setNeedsDisplay() } }
  
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
    let radius = 0.5 * min( rect.width, rect.height ) - 1.0
    
    let buttonBox = CGRect(x: center.x - radius, y: center.y - radius, width: 2.0*radius, height: 2.0*radius)
    
    if borderPath == nil
    {
      borderPath = UIBezierPath(roundedRect: buttonBox, cornerRadius: 0.5*radius)
    }
    
    var fontColor = inactiveColor
    var bgColor = baseColor
    var fgColor = tint

    if isEnabled
    {
      if isHighlighted { bgColor = highlightColor }
      if isSelected { (bgColor,fgColor) = (fgColor,bgColor) }
      fontColor = fgColor
    }
    
    bgColor.setFill()
    borderPath.fill()
    
    if isEnabled
    {
      highlightColor.setStroke()
      borderPath.stroke()
    }
    
    let inset : CGFloat = (isEnabled ? 3.0 : 5.0)
    digit.description.draw(in: rect.insetBy(dx: inset, dy: inset), fontName: fontName, color: fontColor)
  }
}
