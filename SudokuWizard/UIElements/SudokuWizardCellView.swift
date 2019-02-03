//
//  SudokuWizardCellView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

// Possible cell state attributes
//   Locked      = Uneditable (this is a given in the puzzle)
//   Empty       = Editable without a value (but may have marks)
//   Filled      = Editable with a value (no marks allowed)
//   Selected    = Currently active cell
//   Errant      = Something(*) is wrong with value in cell
//   Highlighted = Contains currently "active" digit
//
//   (* SudokuWizardGridView options define what errant means)
//
// Possible state combinations

//    State   Selected   Errant   Highlighted        bg    fg    font
//    ------  --------   ------   -----------        ---   ---   ----
//
//    locked                                          -     L      L
//    locked               X                          E     E      L
//    locked                          X               H     L      L
//    locked               X          X               H     E      L
//
//    empty                                           -     -      -
//    empty        X                                  S     -      -
//
//    filled       X                                  S     -      -
//    filled       X       X                          S     E      -
//    filled       X                  X               S     -      -
//    filled       X       X          X               S     E      -
//
//    filled                                          -     -      -
//    filled               X                          C     E      -
//    filled                          X               H     -      -
//    filled               X          X               H     E      -

import UIKit

// MARK: -

protocol SudokuWizardCellViewDelegate
{
  func sudokuWizardCellView(selected cell:SudokuWizardCellView)
  func sudokuWizardCellView(touch:UITouch, outside cell:SudokuWizardCellView)
}

// MARK: -

class SudokuWizardCellView: UIView, UIGestureRecognizerDelegate
{
  enum CellState {
    case empty
    case locked(Digit)
    case filled(Digit)
  }
  
  static var maximumTapPressDelay : TimeInterval = 0.5
  
  var delegate : SudokuWizardCellViewDelegate?
  
  // MARK: -
  
  let defaultBackgroundColor   = UIColor.white
  let selectedBackgroundColor  = UIColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 1.0)
  let errantBackgroundColor    = UIColor(red: 1.0, green: 0.7, blue: 0.8, alpha: 1.0)
  let highlightBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1.0)
  
  let defaultDigitColor        = UIColor(red:0.0, green: 0.0, blue: 0.75, alpha: 1.0)
  let lockedDigitColor         = UIColor.black
  let errantDigitColor         = UIColor(red:0.5, green: 0.0, blue: 0.0, alpha: 1.0)
  
  let markColor                = UIColor(white: 0.5, alpha: 1.0)
  
  let defaultDigitFont         = UIFont.systemFont(ofSize: 12.0).fontName
  let lockedDigitFont          = UIFont.boldSystemFont(ofSize: 12.0).fontName
  let markDigitFont            = UIFont.systemFont(ofSize: 8.0).fontName
  
  // MARK: -
  
  var state       = CellState.empty  { didSet { setNeedsDisplay() } }
  var highlighted = false            { didSet { setNeedsDisplay() } }
  var errant      = false            { didSet { setNeedsDisplay() } }
  
  var correctDigit : Digit?
  
  var digit : Digit?
  {
    switch state {
    case let .locked(v): return v
    case let .filled(v): return v
    default: return nil
    }
  }
  
  var selected = false {
    didSet {
      setNeedsDisplay()
      if selected { delegate?.sudokuWizardCellView(selected:self) }
    }
  }
  
  var markStyle = SudokuWizard.MarkStyle.digits { didSet { setNeedsDisplay() } }
  
  override var bounds : CGRect  { didSet { setNeedsDisplay() } }
  
  
  // MARK: -
  
  var row : Int?
  var col : Int?
  
  var editable : Bool
  {
    didSet {
      if editable != oldValue {
        if markable { markable = false }
      }
    }
  }
  
  var markable : Bool
  {
    didSet {
      if markable != oldValue {
        if markable { if editable == false { markable = false } }
        else { clearAllMarks() }
      }
    }
  }
  
  private(set) var marks = [Bool](repeating: false, count: 9)  // Note that these are offset by 1 from digit they represent
  
  init(row:Int, col:Int, editable:Bool=true, markable:Bool=true)
  {
    self.row = row
    self.col = col
    self.markable = markable && editable
    self.editable = editable
    super.init(frame:CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    self.markable = true
    self.editable = true
    super.init(coder:aDecoder)
  }
  
  // MARK: -
  
  func set(mark:Int) {
    guard mark > 0, mark < 10 else { fatalError(String(format:"Invalid mark index: %d",mark)) }
    marks[mark-1] = true
    self.setNeedsDisplay()
  }
  
  func clear(mark:Int)  {
    guard mark > 0, mark < 10 else { fatalError(String(format:"Invalid mark index: %d",mark)) }
    marks[mark-1] = false
    self.setNeedsDisplay()
  }
  
  func set(marks:[Bool])
  {
    var needsDisplay = false
    for i in 0...8 {
      if marks[i] != self.marks[i] {
        self.marks[i] = marks[i]
        needsDisplay = true
      }
    }
    if needsDisplay { self.setNeedsDisplay() }
  }
  
  func clearAllMarks()
  {
    var needsDisplay = false
    for i in 0...8 {
      if marks[i] {
        marks[i] = false
        needsDisplay = true
      }
    }
    if needsDisplay { self.setNeedsDisplay() }
  }
  
  func hasMark(_ mark:Int) -> Bool  {
    guard mark > 0, mark < 10 else { fatalError(String(format:"Invalid mark index: %d",mark)) }
    return marks[mark-1]
  }
  
  func hasSomeMark() -> Bool {
    for i in 0..<9 {
      if marks[i] { return true }
    }
    return false
  }
  
  // MARK:
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    if selected == false { selected = true }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    if let t = touches.first { track(touch:t) }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    if let t = touches.first { track(touch:t) }
  }
  
  func track(touch:UITouch)
  {
    if self.bounds.contains(touch.location(in: self))
    {
      if !selected { selected = true }
    }
    else
    {
      if selected { selected = false }
      delegate?.sudokuWizardCellView(touch: touch, outside: self)
    }
  }
  
  // MARK: -
  
  override func draw(_ rect: CGRect)
  {
    let path = UIBezierPath(rect: rect)
    
    let cw = self.bounds.width
    let ch = self.bounds.height
    
    if      selected    { selectedBackgroundColor.setFill()  }
    else if highlighted { highlightBackgroundColor.setFill() }
    else if errant      { errantBackgroundColor.setFill()  }
    else                { defaultBackgroundColor.setFill()   }
    path.fill()
    
    switch state
    {
    case let .locked(d):
      d.description.draw(in: self.bounds.insetBy(dx: 0.1*bounds.width, dy: 0.1*bounds.height),
                         fontName: lockedDigitFont,
                         color: errant ? errantDigitColor : lockedDigitColor)
      
    case let .filled(d):
      d.description.draw(in: self.bounds.insetBy(dx: 0.1*bounds.width, dy: 0.1*bounds.height),
                         fontName: defaultDigitFont,
                         color: errant ? errantDigitColor : defaultDigitColor)
      
    case .empty:
      switch markStyle
      {
      case .digits:
        var box = CGRect(x: 0.0, y: 0.0, width: 0.25*bounds.width, height: 0.25*bounds.height)
        
        let fontSize = "0".fontSizeToFit(rect:box, fontName:markDigitFont);
        
        let xo = cw / 24.0
        let yo = ch / 24.0
        let dx = cw / 3.0
        let dy = ch / 3.0
        
        var row = 0
        var col = 0
        for d in 1...9 {
          if marks[d-1] {
            box.origin.x = xo + CGFloat(col)*dx
            box.origin.y = yo + CGFloat(row)*dy
            d.description.draw(in: box, fontName: markDigitFont, size:fontSize)
            
            col += 1
            if col == 3 { col = 0; row += 1 }
          }
        }
        
      case .dots:
        let xo = cw / 6.0
        let yo = ch / 6.0
        let dx = cw / 3.0
        let dy = ch / 3.0
        let sx = dx / 3.0
        let sy = dy / 3.0
        
        markColor.setFill()
        
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
}
