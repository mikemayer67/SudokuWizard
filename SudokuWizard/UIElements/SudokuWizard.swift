//
//  Enums.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/21/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation
import UIKit

typealias Digit        = UInt8
typealias SudokuGrid   = [[Digit?]]

struct RowCol
{
  var row : Int
  var col : Int
  init(_ row:Int,_ col:Int) { self.row = row; self.col = col }
  var box : Int { return 9*row + col }
  mutating func transpose() { let t = row; row = col; col = t }
}

typealias RowColDigit = (row:Int, col:Int, digit:Digit)

fileprivate let utf8_zero = Digit(UnicodeScalar("0").value)
fileprivate let utf8_dot  = Digit(UnicodeScalar(".").value)

enum SudokuWizardError : Error
{
  case InvalidPuzzle(String)
}

class SudokuWizard
{
  enum MarkStyle : Int {
    case digits = 0
    case dots = 1
  }
  
  enum MarkStrategy : Int
  {
    case manual
    case allowed
    case conflicted
  }
  
  enum ErrorFeedback : Int
  {
    case none
    case error
    case conflict
  }
}

extension String
{
  init(sudokuGrid grid:SudokuGrid)
  {
    self = ""
    for row in grid {
      for digit in row {
        if let d = digit {
          guard d>=1 && d<=9 else { fatalError("digits must each be in range 0-9") }
          self += "\(UnicodeScalar(utf8_zero+d))"
        } else {
          self += "\(UnicodeScalar(utf8_dot))"
        }
      }
    }
  }
  
  func sudokuGrid() throws -> SudokuGrid
  {
    var rval = SudokuGrid(repeating: [Digit?](repeating: nil, count: 9), count: 9)
    
    var i = 0
    for c in self.utf8 {
      guard i < 81 else { throw SudokuWizardError.InvalidPuzzle("Puzzle length too long") }
      let d = Digit(c)
      switch d {
      case utf8_zero, utf8_dot:           rval[i/9][i%9] = nil
      case (utf8_zero+1)...(utf8_zero+9): rval[i/9][i%9] = d-utf8_zero
      default: throw SudokuWizardError.InvalidPuzzle("digits must each be in range 0-9 or '.'")
      }
      i += 1
    }
    guard i == 81 else { throw SudokuWizardError.InvalidPuzzle("Puzzle length too short") }
    
    return rval
  }
  
  func fontSizeToFit(rect:CGRect, fontName:String) -> CGFloat
  {
    let refSize = CGFloat(12)
    
    var attr = [NSAttributedString.Key : Any]()
    attr[.font] = UIFont(name:fontName, size:refSize)
    
    let bounds = self.size(withAttributes: attr)
    let frac = min( rect.width/bounds.width, rect.height/bounds.height )
    
    return frac * refSize
  }
  
  func draw(in rect:CGRect, fontName:String, color:UIColor = .black)
  {
    let size = self.fontSizeToFit(rect: rect, fontName: fontName)
    self.draw(in:rect, fontName:fontName, color:color, size:size )
  }
  
  func draw(in rect:CGRect, fontName:String, size:CGFloat)
  {
    self.draw(in:rect, fontName:fontName, color:.black, size:size)
  }
  
  func draw(in rect:CGRect, fontName:String, color:UIColor = .black, size:CGFloat)
  {
    var attr = [NSAttributedString.Key : Any]()
    attr[.font] = UIFont(name:fontName, size:size)
    attr[.foregroundColor] = color
    
    let bounds = self.size(withAttributes: attr)
    let xo = rect.origin.x + (rect.width - bounds.width)/2.0
    let yo = rect.origin.y + (rect.height - bounds.height)/2.0
    
    self.draw( at:CGPoint(x: xo, y: yo), withAttributes:attr )
  }

}
