//
//  SWCellView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class SWCellView: UIView
{
  enum MarkType {
    case digits
    case dots
  }
  
  var conflicted = false
  {
    didSet { self.setNeedsDisplay() }
  }
  
  var locked = false
  {
    didSet { self.setNeedsDisplay() }
  }
  
  var value = 0
  {
    didSet { self.setNeedsDisplay() }
  }
  
  var marks = [ false, false, false, false, false, false, false, false, false ]
  
  var markType = MarkType.digits
  {
    didSet { self.setNeedsDisplay() }
  }
  
  func set(mark:Int, on:Bool = true)
  {
    marks[mark-1] = on
    self.setNeedsDisplay()
  }
  
  func unset(mark:Int)
  {
    set(mark:mark, on:false)
  }
  
  override var bounds : CGRect
  {
    didSet { self.setNeedsDisplay() }
  }
  
  override func draw(_ rect: CGRect)
  {
    let path = UIBezierPath(rect: rect)
    path.lineWidth = 2.0
    
    let cw = self.bounds.width
    let ch = self.bounds.height
    
    if conflicted { UIColor(red: 1.0, green: 0.7, blue: 0.8, alpha: 1.0).setFill() }
    else          { UIColor.white.setFill() }
    path.fill()
    UIColor.blue.setStroke()
    path.stroke()

    if value > 0
    {
      let d = value.description
      
      var attr = [ NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12.0),
                   NSAttributedString.Key.foregroundColor: locked ? UIColor.black : UIColor.blue ]
      
      let unscaledBounds = d.size(withAttributes: attr)
      let frac = max( unscaledBounds.width / cw, unscaledBounds.height / ch )
      
      attr[ NSAttributedString.Key.font ] = UIFont.boldSystemFont(ofSize: 9.0 / frac )
      
      let scaledBounds = d.size(withAttributes: attr)
      let pt = CGPoint(x: (cw - scaledBounds.width)/2, y: (ch-scaledBounds.height)/2)
      
      d.draw(at:pt, withAttributes:attr)
    }
    else if markType == .digits
    {
      var attr = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12.0),
                   NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0) ]
      
      let unscaledBounds = "0".size(withAttributes: attr)
      let frac = max( unscaledBounds.width / cw, unscaledBounds.height / ch )
      
      attr[ NSAttributedString.Key.font ] = UIFont.boldSystemFont(ofSize: 3.0 / frac )
      
      let xo = cw / 6.0
      let yo = ch / 6.0
      let dx = cw / 3.0
      let dy = ch / 3.0
      
      var row = 0
      var col = 0
      for d in 1...9 {
        if marks[d-1] {
          let scaledBounds = d.description.size(withAttributes: attr)
          let pt = CGPoint(x:xo + CGFloat(col)*dx - scaledBounds.width/2 ,
                           y:yo + CGFloat(row)*dy - scaledBounds.height/2 )
          
          d.description.draw(at:pt, withAttributes:attr)
          col += 1
          if col > 2 { col = 0; row += 1 }
        }
      }
    }
    else
    {
      let xo = cw / 6.0
      let yo = ch / 6.0
      let dx = cw / 3.0
      let dy = ch / 3.0
      let sx = dx / 5.0
      let sy = dy / 5.0
      
      UIColor(white: 0.5, alpha: 1.0).setFill()

      for i in 0...8 {
        if marks[i] {
          let row = i / 3
          let col = i % 3
          let path = UIBezierPath(ovalIn:CGRect(x: xo + CGFloat(col)*dx - sx/2,
                                                y: yo + CGFloat(row)*dy - sy/2,
                                                width: sx,
                                                height: sy))
          path.fill()
        }
      }
    }
  }
  
}


