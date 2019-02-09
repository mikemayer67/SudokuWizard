//
//  StatusView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 2/8/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

@IBDesignable
class StatusView: UIView
{
  var label : UILabel?
  
  @IBInspectable var prefix   : String  = ""   { didSet { update() } }
  @IBInspectable var text     : String  = ""   { didSet { update() } }
  
  @IBInspectable var widthPad : CGFloat = 15.0 {
    didSet {
      updateLabelConstraints()
    }
  }
  
  @IBInspectable var heightPad : CGFloat = 10.0 {
    didSet {
      updateLabelConstraints()
    }
  }
  
  func update()
  {
    var status = ""
    if !prefix.isEmpty { status = prefix + ": " }
    status = status + text
    label?.text = status
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
    
    self.addSubview(label!)
    
    label?.translatesAutoresizingMaskIntoConstraints = false
    updateLabelConstraints()
    
    updateShadow()
  }
  
  override var bounds : CGRect {
    didSet { updateShadow() }
  }
  
  func updateLabelConstraints()
  {
    label?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: widthPad).isActive = true
    label?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -widthPad).isActive = true
    label?.topAnchor.constraint(equalTo: self.topAnchor, constant: heightPad).isActive = true
    label?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -heightPad).isActive = true
  }
  
  func updateShadow()
  {
    let r  = bounds.height/4.0
    let sp = UIBezierPath(roundedRect: bounds, cornerRadius: r)
    layer.cornerRadius = r
    layer.shadowPath = sp.cgPath
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width:3.0,height:3.0)
    layer.shadowRadius = 5.0
    layer.masksToBounds = false
  }
}
