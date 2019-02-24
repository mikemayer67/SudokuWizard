//
//  DigitButtonBox.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 2/22/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

@objc protocol DigitButtonBoxDelegate
{
  func digitButtonBox(selected digit:Digit)
  func digitButtonBox(unselected digit:Digit)
}

@IBDesignable
class DigitButtonBox: UIView
{
  let buttonSep = CGFloat(0.1)
  
  @IBInspectable var tint : UIColor = UIColor.black {
    didSet { for b in buttons { b.tint = tint } }
  }
  
  @IBInspectable var baseColor : UIColor = UIColor.white {
    didSet { for b in buttons { b.baseColor = baseColor } }
  }
  
  @IBInspectable var highlightColor : UIColor = UIColor.yellow {
    didSet { for b in buttons { b.highlightColor = highlightColor } }
  }
  
  @IBInspectable var inactiveColor : UIColor = UIColor.gray {
    didSet { for b in buttons { b.inactiveColor = inactiveColor } }
  }
  
  @IBOutlet weak var heightConstraint : NSLayoutConstraint!
  
  @IBOutlet weak var delegate : DigitButtonBoxDelegate?
  
  private(set) var buttons = [DigitButton]()
  
  var digits = DigitSet()
  
  var enabled = false
  {
    didSet {
      guard enabled != oldValue else { return }
      for btn in buttons { btn.isEnabled = enabled }
      if enabled {
        for btn in buttons { btn.isSelected = digits.has(digit: btn.digit) }
      }
      else {
        for btn in buttons { btn.isSelected = false }
      }
    }
  }
  
  var multipleSelectionAllowed = false
  {
    didSet {
      guard multipleSelectionAllowed != oldValue else { return }
      guard multipleSelectionAllowed else { return }
      if digits.count > 1 { deselectAll() }
    }
  }
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    for d : Digit in 1...9
    {
      let btn = DigitButton(d)
      
      btn.tint = tint
      btn.baseColor = baseColor
      btn.highlightColor = highlightColor
      btn.inactiveColor = inactiveColor
      
      btn.isEnabled = false
      
      btn.addTarget(self, action: #selector(handleDigitButton(_:)), for: .touchUpInside)
      
      self.addSubview(btn)
      
      buttons.append(btn)
    }
  }
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    layoutButtons()
  }
  
  func layoutButtons()
  {
    let width = bounds.width
    guard width > 0.0 else { return }
    
    let size = width / (9.0 + 10.0*buttonSep)
    let sep  = buttonSep * size
    
//    heightConstraint.constant = size
    
    var xo = sep;
    for btn in buttons
    {
      btn.frame = CGRect(x:xo, y:0.0, width: size, height:size)
      xo += sep + size
    }
  }
  
  @objc func handleDigitButton(_ sender:DigitButton)
  {
    let d = sender.digit
    
    let digitWasSet = digits.has(digit: d)
    
    if sender.isSelected
    {
      guard digitWasSet else { return }
      digits.clear(d)
      buttons[ Int(d) - 1 ].isSelected = false
      delegate?.digitButtonBox(unselected: d)
    }
    else
    {
      if digitWasSet { return }
      if multipleSelectionAllowed {
        digits.set(d)
        buttons[ Int(d) - 1 ].isSelected = true
      }
      else {
        select(digit: d)
      }
      delegate?.digitButtonBox(selected: d)
    }
  }
  
  func deselectAll()
  {
    for btn in buttons { btn.isSelected = false }
    digits = DigitSet(false)
  }
  
  func select(digit:Digit?)
  {
    guard let d = digit else { deselectAll(); return }
    
    if digits.count == 1, digits.has(digit: d) { return }
    
    deselectAll()
    digits.set(d)
    buttons[ Int(d) - 1 ].isSelected = true
  }
}
