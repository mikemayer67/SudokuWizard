//
//  Enums.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/21/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

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
  
  func sudokuGrid() -> SudokuGrid
  {
    var rval = SudokuGrid(repeating: [Digit?](repeating: nil, count: 9), count: 9)
    
    var i = 0
    for c in self.utf8 {
      guard i < 81 else { fatalError("Puzzle length too long") }
      let d = Digit(c)
      switch d {
      case utf8_zero, utf8_dot:           rval[i/9][i%9] = nil
      case (utf8_zero+1)...(utf8_zero+9): rval[i/9][i%9] = d-utf8_zero
      default: fatalError("digits must each be in range 0-9 or '.'")
      }
      i += 1
    }
    guard i == 81 else { fatalError("Puzzle length too short") }
    
    return rval
  }
}
