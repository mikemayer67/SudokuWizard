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
//   Conflicted  = Has same digit as another cell in row, column, or box
//   Highlighted = Contains currently "active" digit
//
// Possible state combinations

//    State   Selected   Conflicted   Highlighted        bg    fg    font
//    ------  --------   ----------   -----------        ---   ---   ----
//
//    locked                                              -     L      L
//    locked                 X                            C     C      L
//    locked                              X               H     L      L
//    locked                 X            X               H     C      L
//
//    empty                                               -     -      -
//    empty        X                                      S     -      -
//
//    filled       X                                      S     -      -
//    filled       X         X                            S     C      -
//    filled       X                      X               S     -      -
//    filled       X         X            X               S     C      -
//
//    filled                                              -     -      -
//    filled                 X                            C     C      -
//    filled                              X               H     -      -
//    filled                 X            X               H     C      -

import UIKit


protocol SudokuWizardCellViewDelegate
{
  func sudokuWizardCellTapped(_ cellView:SudokuWizardCellView)
  func sudokuWizardCellPressed(_ cellView:SudokuWizardCellView)
}

// MARK: -

class SudokuWizardCellView: UIView, UIGestureRecognizerDelegate
{
  enum MarkStyle : Int {
    case digits = 0
    case dots = 1
  }
  
  enum CellState {
    case empty
    case locked(Int)
    case filled(Int)
  }
  
  // MARK: -
  
  let defaultBackgroundColor   = UIColor.white
  let selectedBackgroundColor  = UIColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 1.0)
  let conflictBackgroundColor  = UIColor(red: 1.0, green: 0.7, blue: 0.8, alpha: 1.0)
  let highlightBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1.0)

  let defaultDigitColor        = UIColor(red:0.0, green: 0.0, blue: 0.75, alpha: 1.0)
  let lockedDigitColor         = UIColor.black
  let conflictedDigitColor     = UIColor(red:0.5, green: 0.0, blue: 0.0, alpha: 1.0)
  
  let markColor                = UIColor(white: 0.5, alpha: 1.0)
  
  let defaultDigitFont         = UIFont.systemFont(ofSize: 12.0).fontName
  let lockedDigitFont          = UIFont.boldSystemFont(ofSize: 12.0).fontName
  let markDigitFont            = UIFont.systemFont(ofSize: 8.0).fontName
  
  // MARK: -
  
  var state       = CellState.empty  { didSet { setNeedsDisplay() } }
  var selected    = false            { didSet { setNeedsDisplay() } }
  var highlighted = false            { didSet { setNeedsDisplay() } }
  var conflicted  = false            { didSet { setNeedsDisplay() } }
  
  var markStyle   = MarkStyle.digits { didSet { setNeedsDisplay() } }
  
  override var bounds : CGRect       { didSet { setNeedsDisplay() } }
  
  // MARK: -
  
  var delegate      : SudokuWizardCellViewDelegate?
  
  var tapRecognizer : UITapGestureRecognizer!
  var pressRecongnizer : UILongPressGestureRecognizer!
  
  var row : Int?
  var col : Int?
  
  private(set) var marks = [Bool]()  // Note that these are offset by 1 from digit they represent
  
  init(row:Int, col:Int)
  {
    self.row = row
    self.col = col
    
    super.init(frame:CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    
    completeSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    completeSetup()
  }
  
  func completeSetup()
  {
    for _ in 0..<9 { marks.append(false) }
    
    tapRecognizer = UITapGestureRecognizer( target:self, action:#selector(handleTap(_:)) )
    tapRecognizer.delegate = self
    
    pressRecongnizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)) )
    pressRecongnizer.delegate = self
    
    addGestureRecognizer(tapRecognizer)
    addGestureRecognizer(pressRecongnizer)
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
  
  func hasMark(_ mark:Int) -> Bool  {
    guard mark > 0, mark < 10 else { fatalError(String(format:"Invalid mark index: %d",mark)) }
    return marks[mark-1]
  }
  
  // MARK: -
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    switch state
    {
    case .locked(_): return false
    default:         return true
    }
  }
  
  @objc func handleTap(_ sender:UITapGestureRecognizer) {
    delegate?.sudokuWizardCellTapped(self)
  }
  
  @objc func handlePress(_ sender:UILongPressGestureRecognizer)
  {
    if sender.state == .began
    {
      delegate?.sudokuWizardCellPressed(self)
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
    else if conflicted  { conflictBackgroundColor.setFill()  }
    else                { defaultBackgroundColor.setFill()   }
    path.fill()

    var fontName : String!
    var fgColor  : UIColor?
    var digit    : String?
    
    switch state
    {
    case let .locked(d):
      fontName = lockedDigitFont
      fgColor  = conflicted ? conflictedDigitColor : lockedDigitColor
      digit    = d.description
      
    case let .filled(d):
      fontName = defaultDigitFont
      fgColor  = conflicted ? conflictedDigitColor : defaultDigitColor
      digit    = d.description
      
    case .empty:
      fgColor  = markColor
    }
    
    if let d = digit
    {
      var attr = [NSAttributedString.Key : Any]()
      
      attr[.font] = UIFont(name:fontName, size:12.0)
      attr[.foregroundColor] = fgColor
      
      let unscaledBounds = d.size(withAttributes: attr)
      let frac = max( unscaledBounds.width / cw, unscaledBounds.height / ch )
      
      attr[.font] = UIFont(name:fontName, size: 9.0 / frac)
      
      let scaledBounds = d.size(withAttributes: attr)
      let pt = CGPoint(x: (cw - scaledBounds.width)/2, y: (ch-scaledBounds.height)/2)
      
      d.draw(at:pt, withAttributes:attr)
    }
    else if markStyle == .digits
    {
      var attr = [NSAttributedString.Key : Any]()
      
      attr[.font] = UIFont(name: markDigitFont, size: 12.0)
      attr[.foregroundColor] = markColor
      
      let unscaledBounds = "0".size(withAttributes: attr)
      let frac = max( unscaledBounds.width / cw, unscaledBounds.height / ch )
      
      attr[.font ] = UIFont(name: markDigitFont, size: 3.0/frac)
      
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
