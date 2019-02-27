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
      guard isEnabled != oldValue else { return }
      
      if isEnabled {
        layer.shadowPath = borderPath.cgPath
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
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted != oldValue { setNeedsDisplay() }
    }
  }
  
  lazy var borderPath : UIBezierPath = {
    let center = CGPoint(x: 0.5*bounds.width, y: 0.5*bounds.height)
    let radius = 0.5 * min( bounds.width, bounds.height ) - 1.0
    
    let buttonBox = CGRect(x: center.x - radius, y: center.y - radius, width: 2.0*radius, height: 2.0*radius)
    
    return UIBezierPath(roundedRect: buttonBox, cornerRadius: 0.5*radius)
  } ()
  

  
  override func draw(_ rect: CGRect)
  {
    super.draw(rect)
    
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
