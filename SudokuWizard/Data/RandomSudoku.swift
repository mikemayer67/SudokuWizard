//
//  RandomSudoku.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 1/1/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import Foundation

// links is used for generating a solution grid
// it contains the indices of all cells PRIOR to a given cell
// which are in teh same row, column, or box

let links : [[RowCol]] = {
  var rval = [[RowCol]]()
  
  for r in 0...8 {
    let br = 3*(r/3)
    for c in 0...8 {
      let bc = 3*(c/3)
      
      var rc = [RowCol]()
      for j in 0..<c { rc.append(RowCol(r,j)) }
      for j in 0..<r { rc.append(RowCol(j,c)) }
      for j in br..<r {
        for k in 0..<3 {
          if bc+k != c { rc.append(RowCol(j,bc+k)) }
        }
      }
      
      rval.append(rc)
    }
  }
  
  return rval
}()

// hide4Candidates and hide2Candidates are used for converting
// a solution grid to a puzzle grid by hiding cells.  They provide
// the indices of unambiguous cells when attempting to symmetrically
// hide 4 or 2 cells respectively
//
//  00 01 02 03 04 05 06 07 08   00 01 02 03 04 05 06 07 ||   00 01 02 03 04 05 06 07 08
//  10 11 12 13 14 15 16 17 18   ++ 11 12 13 14 15 16 || ||   -- 11 12 13 14 15 16 17 18
//  20 21 22 23 24 25 26 27 28   ++ ++ 22 23 24 25 || || ||   -- -- 22 23 24 25 26 27 28
//  30 31 32 33 34 35 36 37 38   ++ ++ ++ 33 34 || || || ||   -- -- -- 33 34 35 36 37 38
//  40 41 42 43 44 45 46 47 48   ++ ++ ++ ++    || || || ||   -- -- -- --    45 46 47 48
//  50 51 52 53 54 55 56 57 58   ++ ++ ++ ++ -- -- || || ||   -- -- -- -- -- -- 56 57 58
//  60 61 62 63 64 65 66 67 68   ++ ++ ++ -- -- -- -- || ||   -- -- -- -- -- -- -- 67 68
//  70 71 72 73 74 75 76 77 78   ++ ++ -- -- -- -- -- -- ||   -- -- -- -- -- -- -- -- 78
//  80 81 82 83 84 85 86 87 88   ++ -- -- -- -- -- -- -- --   -- -- -- -- -- -- -- -- -- 

let hide4Candidates : [RowCol] = {
  var rval = [RowCol]()
  for r in 0...3 {
    for c in r..<(8-r) {
      rval.append(RowCol(r,c))
    }
  }
  return rval
}()

let hide2Candidates : [RowCol] = {
  var rval = [RowCol]()
  for r in 0...3 {
    for c in r...8 {
      rval.append(RowCol(r,c))
    }
  }
  for r in 4...7 {
    for c in (r+1)...8 {
      rval.append(RowCol(r,c))
    }
  }
  return rval
}()


class RandomSudoku
{
  var solution : SudokuGrid
  var puzzle   : SudokuGrid!
  
  private(set) var difficulty = -1
  
  init() {
    solution = SudokuGrid(repeating: [Digit?](repeating: nil, count: 9), count: 9)
    
    generateSolution()
    generatePuzzle()
    
    guard let grader = SudokuGrader(puzzle,solution) else {
      fatalError("Invalid puzzle generated")
    }
    
    difficulty = Int(grader.difficulty)
  }
  
  private func generateSolution()
  {
    solution[0][0] = Digit.random(in: 1...9)
    
    guard addRandomDigit(row:0,col:1) else {
      fatalError("Should never see this (\(#file):\(#line))")
    }
  }
  
  private func addRandomDigit(row:Int,col:Int) -> Bool
  {
    guard row < 9 else { return true }
    let cell = 9*row + col
    
    var candidates = DigitSet(true)
    for linked in links[cell] {
      if let d = solution[linked.row][linked.col] {
        candidates.clear(d)
        if candidates.isEmpty { return false }
      }
    }
    
    let next : RowCol = col == 8 ? RowCol(row+1,0) : RowCol(row,col+1)
    
    let pool = candidates.digits().shuffled()
    for digit in pool {
      solution[row][col] = digit
      if addRandomDigit(row:next.row, col:next.col ) { return true }
    }
    return false
  }
  
  private func generatePuzzle()
  {
    puzzle = solution
    
    hide4()
    hide2()
    
    puzzle[4][4] = nil
    if validPuzzle() == false { puzzle[4][4] = solution[4][4] }
  }
  
  private func hide4()
  {
    let cand = hide4Candidates.shuffled()
    for rc in cand {
      puzzle[  rc.row][  rc.col] = nil
      puzzle[8-rc.col][  rc.row] = nil
      puzzle[8-rc.row][8-rc.col] = nil
      puzzle[  rc.col][8-rc.row] = nil
      
      if validPuzzle() == false {
        puzzle[  rc.row][  rc.col] = solution[  rc.row][  rc.col]
        puzzle[8-rc.col][  rc.row] = solution[8-rc.col][  rc.row]
        puzzle[8-rc.row][8-rc.col] = solution[8-rc.row][8-rc.col]
        puzzle[  rc.col][8-rc.row] = solution[  rc.col][8-rc.row]
      }
    }
  }
  
  private func hide2()
  {
    let cand = hide2Candidates.shuffled()
    for rc in cand {
      puzzle[  rc.row][  rc.col] = nil
      puzzle[8-rc.row][8-rc.col] = nil
      
      if validPuzzle() == false {
        puzzle[  rc.row][  rc.col] = solution[  rc.row][  rc.col]
        puzzle[8-rc.row][8-rc.col] = solution[8-rc.row][8-rc.col]
      }
    }
  }
  
  private func validPuzzle() -> Bool
  {    
    let dlx = try! DLXSudoku(puzzle)
    let status = dlx.evaluate()
    
    switch status
    {
    case .MultipleSolutions:
      return false
    case .NoSolution:
      fatalError("Should never see this (\(#file):\(#line))")
    case .UniqueSolution(_):
      return true
    }
  }
}

