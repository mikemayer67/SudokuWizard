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

func RowColumnConstraint(row:Int,col:Int) -> Int {
  return 9*row + col
}

func RowDigitConstraint(row:Int,digit:Int) -> Int {
  return 81 + 9*row + (digit-1)
}

func ColDigitConstraint(col:Int,digit:Int) -> Int {
  return 162 + 9*col + (digit-1)
}

func BoxDigitConstraint(row:Int, col:Int, digit:Int) -> Int {
  let box = Box(row:row,col:col)
  return 243 + 9*box + (digit-1)
}

func Box(row:Int,col:Int) -> Int {
  return 3*(row/3) + (col/3)
}

class DLXSudoku : DLX
{
  init( _ givens:[(row:Int,col:Int,digit:Int)] ) throws
  {
    var uncovered = [[Int]]();
    
    for row in 0...8 {
      for col in 0...8 {
        for digit in 1...9 {
          uncovered.append( [ RowColumnConstraint(row:row,col:col),
                              RowDigitConstraint(row:row,digit:digit),
                              ColDigitConstraint(col:col,digit:digit),
                              BoxDigitConstraint(row:row,col:col,digit:digit) ] )
        }
      }
    }
    
    try super.init(uncovered)
    
    for rcd in givens {
      let cols = [ RowColumnConstraint(row:rcd.row, col:rcd.col),
                   RowDigitConstraint(row:rcd.row, digit:rcd.digit),
                   ColDigitConstraint(col:rcd.col, digit:rcd.digit),
                   BoxDigitConstraint(row:rcd.row, col:rcd.col, digit:rcd.digit) ]
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
  
  func sudokuSolution(_ n:Int) -> [(row:Int,col:Int,digit:Int)]?
  {
    var rval = [(row:Int,col:Int,digit:Int)]()
    
    if n < solutions.count {
      let rows = solutions[n]
      for row in rows {
        let r = row/81
        let c = (row%81)/9
        let d = row%9 + 1
        rval.append( (r,c,d) )
      }
    }
    return rval
  }
}
