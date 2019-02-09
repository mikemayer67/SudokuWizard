//
//  SudokuSolver.swift
//  
//
//  Created by Mike Mayer on 10/26/18.
//

import Foundation

enum DLXSudokuError : Error
{
  case InvalidStartingGrid
}

class DLXSudoku : DLX
{
  typealias Digit = UInt8
  typealias Grid  = [[Digit?]]
  
  init( _ grid:Grid ) throws
  {
    var uncovered = [[Int]]();
    
    for row in 0...8 {
      for col in 0...8 {
        for digit : Digit in 1...9 {
          uncovered.append( [ DLXSudoku.RowColumnConstraint(row:row,col:col),
                              DLXSudoku.RowDigitConstraint(row:row,digit:digit),
                              DLXSudoku.ColDigitConstraint(col:col,digit:digit),
                              DLXSudoku.BoxDigitConstraint(row:row,col:col,digit:digit) ] )
        }
      }
    }
    
    try super.init(uncovered)
    
    for row in 0...8 {
      for col in 0...8 {
        if let digit = grid[row][col]
        {
          let cols = [ DLXSudoku.RowColumnConstraint(row:row, col:col),
                       DLXSudoku.RowDigitConstraint(row:row, digit:digit),
                       DLXSudoku.ColDigitConstraint(col:col, digit:digit),
                       DLXSudoku.BoxDigitConstraint(row:row, col:col, digit:digit) ]
          for col in cols {
            var c = self.right as? DLXColumnNode
            while c != nil, c!.col != col {
              c = c!.right as? DLXColumnNode
            }
            if c == nil { throw DLXSudokuError.InvalidStartingGrid }
            
            c!.cover()
          }
        }
      }
    }
  }
  
  convenience init( _ givens:[(row:Int,col:Int,digit:Digit)] ) throws
  {
    var grid = [[Digit?]](repeating: [Digit?](repeating: nil, count: 9), count: 9)
    for rcd in givens {
      grid[rcd.row][rcd.col] = rcd.digit
    }
    try self.init(grid)
  }
  
  func sudokuSolution(_ n:Int) -> SudokuGrid
  {
    var rval = SudokuGrid(repeating: Digits(repeating: nil, count: 9), count: 9)
    
    if n < solutions.count {
      let rows = solutions[n]
      for row in rows {
        let r = row/81
        let c = (row%81)/9
        let d = row%9 + 1
        rval[r][c] = Digit(d)
      }
    }
    return rval
  }
  
  class func RowColumnConstraint(row:Int,col:Int) -> Int {
    return 9*row + col
  }
  
  class func RowDigitConstraint(row:Int,digit:Digit) -> Int {
    return 81 + 9*row + Int(digit-1)
  }
  
  class func ColDigitConstraint(col:Int,digit:Digit) -> Int {
    return 162 + 9*col + Int(digit-1)
  }
  
  class func BoxDigitConstraint(row:Int, col:Int, digit:Digit) -> Int {
    let box = Box(row:row,col:col)
    return 243 + 9*box + Int(digit-1)
  }
  
  class func Box(row:Int,col:Int) -> Int {
    return 3*(row/3) + (col/3)
  }
}
