//
//  IconButton.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 2/24/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

@IBDesignable
class IconButton: UIButton
{
  @IBInspectable var baseColor   : UIColor = UIColor.white  { didSet { self.setNeedsDisplay() } }
  
  @IBInspectable var numSegments : Int = 1
  @IBInspectable var segment     : Int = 1
  
  var trueTint : UIColor!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    trueTint = tintColor
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.shadowPath = fillPath.cgPath
    layer.shadowOffset = CGSize(width:2.0, height:2.0)
    layer.shadowRadius = 6.0
    layer.masksToBounds = false
    
    layer.shadowOpacity = isEnabled ? 0.5 : 0.0
  }

  var inverted = false
  {
    didSet {
      tintColor = inverted ? baseColor : trueTint
      self.setNeedsDisplay()
    }
  }
  
  override var isEnabled : Bool
  {
    didSet {
      layer.shadowOpacity = isEnabled ? 0.5 : 0.0
    }
  }
  
  lazy var fillPath : UIBezierPath = {
    var rval = borderPath
    if numSegments > 1
    {
      switch segment {
      case 1:           rval.close()
      case numSegments: rval.close()
      default:          rval = UIBezierPath(rect: frame)
      }
    }
    return rval
  }()
  
  lazy var borderPath : UIBezierPath =
  {
    let width = bounds.width
    let height = bounds.height
    
    let size   = min( width, height ) - 1.0
    let radius = 0.25 * size
    
    let deg90 = 0.5*CGFloat.pi
    let deg180 = CGFloat.pi
    let deg270 = 1.5*CGFloat.pi
    
    var rval : UIBezierPath!
    switch(segment,numSegments)
    {
    case (_,1):
      rval = UIBezierPath(
        roundedRect: CGRect(x: 0.5*(width-size), y: 0.5*(height-size), width: size, height: size),
        cornerRadius: radius)
      
    case(1,_):
      
      var pt = CGPoint(x:width, y:0.0)
      
      rval = UIBezierPath()
      rval.move(to: pt )
      pt.x -= width - radius
      rval.addLine(to: pt )
      pt.y += radius
      rval.addArc(withCenter: pt, radius: radius,
                  startAngle: deg270, endAngle: deg180, clockwise: false)
      pt.x -= radius
      pt.y += height - 2.0*radius
      rval.addLine(to: pt)
      pt.x += radius
      rval.addArc(withCenter: pt, radius: radius,
                  startAngle: deg180, endAngle: deg90, clockwise: false)
      pt.y += radius
      pt.x += width - radius
      rval.addLine(to: pt)
      
    case(numSegments,_):
      
      var pt = CGPoint( x:0.0, y:0.0 )
      
      rval = UIBezierPath()
      rval.move(to: pt )
      pt.x += width - radius
      rval.addLine(to: pt )
      pt.y += radius
      rval.addArc(withCenter: pt, radius: radius,
                  startAngle: deg270, endAngle: 0.0, clockwise: true)
      pt.x += radius
      pt.y += height - 2.0*radius
      rval.addLine(to: pt)
      pt.x -= radius
      rval.addArc(withCenter: pt, radius: radius,
                  startAngle: 0.0, endAngle: deg90, clockwise: true)
      pt.y += radius
      pt.x -= width - radius
      rval.addLine(to: pt)
      
    default:
      rval = UIBezierPath()
      var pt = CGPoint( x:0.0, y:0.0 )
      rval.move(to: pt)
      pt.x += width
      rval.addLine(to: pt)
      pt.y += height
      rval.move(to: pt)
      pt.x -= width
      rval.addLine(to: pt)
    }
    return rval
  }()
  
  lazy var sepPath : UIBezierPath? = {
    guard numSegments > 1 else { return nil }
    
    let width = bounds.width
    let height = bounds.height
    
    var rval = UIBezierPath()
    switch(segment)
    {
    case 1:
      var pt = CGPoint( x:width, y:0.0 )
      rval.move(to: pt )
      pt.y += height
      rval.addLine(to: pt)
      
    case numSegments:
      var pt = CGPoint( x:0.0, y:0.0 )
      rval.move(to: pt )
      pt.y += height
      rval.addLine(to: pt)
      
    default:
      var pt = CGPoint( x:0.0, y: 0.0 )
      rval.move(to: pt )
      pt.y += height
      rval.addLine(to: pt)
      pt.x += width
      rval.move(to: pt )
      pt.y -= height
      rval.addLine(to: pt)
    }
    return rval
  }()
  
  override func draw(_ rect : CGRect)
  {
    super.draw(rect)
    
    if inverted { trueTint.setFill()   ; baseColor.setStroke() }
    else        { trueTint.setStroke() ; baseColor.setFill()   }

    fillPath.fill()
    borderPath.stroke()
    sepPath?.stroke()
  }
}
