//
//  SudokuGrader.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 1/11/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import Foundation

fileprivate enum Element : String {
  case Row = "row"
  case Col = "col"
  case Box = "box"
}

class SudokuGrader
{
  private let hiddenSingleWeight = 1.0
  private let nakedSingleWeight  = 2.0
  private let hiddenPairWeight   = 5.0
  private let nakedPairWeight    = 5.0
  
  private(set) var difficulty = 0.0
  
  // 9x9 matrix containing marks for each cell
  private var marks  = [[DigitSet]](repeating: [DigitSet](repeating: DigitSet(true), count: 9), count: 9)
  
  // 9x9 matrix containing digits (or nil)
  private var digits = [[Digit?]](repeating: [Digit?](repeating: nil, count: 9), count: 9)
  
  private var numComplete = 0
  
  init(_ puzzle:SudokuGrid,_ truth:SudokuGrid)
  {
    for r in 0..<9 {
      for c in 0..<9 {
        if let d = puzzle[r][c] { add(row:r, col:c, digit:d) }
      }
    }
    
    while numComplete < 81
    {
      dumpGrid()
      dumpMarks()
      
      if findHiddenSingles() { continue }
      if findNakedSingles()  { continue }
      if findNakedPairs()   { continue }
      
      fatalError("Keep Working on this")
    }
  }
  
  private func add(row:Int, col:Int, digit:Digit)
  {
    let boxRow = 3*(row/3)
    let boxCol = 3*(col/3)
    
    digits[row][col] = digit
    
    for i in 0..<9 {
      marks[row][i].clear(digit)
      marks[i][col].clear(digit)
      marks[boxRow + i/3][boxCol + i%3].clear(digit)
    }
    
    numComplete += 1
  }
  
  private func openCells(inRow:Int, notInCol:Int? = nil) -> [RowCol]
  {
    var rval = [RowCol]()
    for col in 0..<9 {
      if col != notInCol, digits[inRow][col] == nil { rval.append((inRow,col)) }
    }
    return rval
  }
  
  private func openCells(inCol:Int, notInRow:Int? = nil) -> [RowCol]
  {
    var rval = [RowCol]()
    for row in 0..<9 {
      if row != notInRow, digits[row][inCol] == nil { rval.append((row,inCol)) }
    }
    return rval
  }
  
  private func openCells(inBox:Int, notInRow:Int? = nil, notInCol:Int? = nil) -> [RowCol]
  {
    var rval = [RowCol]()
    let boxRow = 3*(inBox/3)
    let boxCol = 3*(inBox%3)
    for i in 0..<9 {
      let row = boxRow + i/3
      let col = boxCol + i%3
      if !(row == notInRow && col == notInCol), digits[row][col] == nil { rval.append((row,col)) }
    }
    return rval
  }
  
  func dumpGrid()
  {
    print("  +---+---+---+")
    for r in 0..<9 {
      var s = "  |"
      for c in 0..<9 {
        s.append( digits[r][c] == nil ? " " : String(format:"%d",digits[r][c]!) )
        if c%3 == 2 { s.append("|") }
      }
      print(s)
      if r%3 == 2 { print("  +---+---+---+") }
    }
  }
  
  func dumpMarks()
  {
    print("  +---+---+---+---+---+---+---+---+---+")
    for r in 0..<9 {
      for rr in 0...2 {
        var s = "  |"
        for c in 0..<9 {
          for cc in 0...2 {
            if digits[r][c] == nil {
              s.append(marks[r][c].has(digit:Digit(3*rr+cc+1)) ? "©" : " ")
            }
            else
            {
              s.append( String(format:"%d", digits[r][c]!) )
            }
          }
          if c%3==2, c<8 { s.append("|") }
          else { s.append(":") }
        }
        print(s)
      }
      if r%3==2, r<8 { print("  +===+===+===+===+===+===+===+===+===+") }
      else { print("  +---+---+---+---+---+---+---+---+---+") }
    }
  }
  
  private func findHiddenSingles() -> Bool
  {
    var rval = false
    var found = [RowColDigit]()
    
    for r in 0..<9 {
      for c in 0..<9 {
        if digits[r][c] != nil { continue }
        
        for e in [Element.Row, Element.Col, Element.Box] {
          var oc : [RowCol]!
          switch e {
          case .Row: oc = openCells(inRow:r, notInCol:c)
          case .Col: oc = openCells(inCol:c, notInRow:r)
          case .Box: oc = openCells(inBox:3*(r/3)+(c/3), notInRow:r, notInCol:c)
          }
          
          var u = marks[r][c].complement()
          for rc in oc { u = u.union( marks[rc.row][rc.col]) }
          u = u.complement()
          if let d = u.digit() {
            print(" HiddenSingle[\(e.rawValue)] (\(r),\(c),\(d))")
            found.append((r,c,d));
            break  // out of e to next c
          }
        } // row,col,box
      }   // c
    }     // r
    
    for rcd in found {
      rval = true
      add(row: rcd.row, col: rcd.col, digit: rcd.digit)
      difficulty += hiddenSingleWeight
    }
    
    return rval
  }
  
  private func findNakedSingles() -> Bool
  {
    var rval = false
    var found = [RowColDigit]()
    
    for r in 0..<9 {
      for c in 0..<9 {
        if digits[r][c] == nil
        {
          if let d = marks[r][c].digit() {
            found.append( (r,c,d) )
          }
          else if marks[r][c].isEmpty {
            fatalError("Internal Logic Error, grader provided invalid puzzle")
          }
        }
      }
    }
    
    for rcd in found {
      rval = true
      print(" NakedSingle(\(rcd.row),\(rcd.col),\(rcd.digit))")
      add(row: rcd.row, col: rcd.col, digit: rcd.digit)
      difficulty += nakedSingleWeight
    }
    
    return rval
  }
  
  private func findNakedPairs() -> Bool
  {
    var rval = false
    
    var found = [ (rc1:RowCol,rc2:RowCol,element:Element,digits:[Digit]) ]()
    
    for e in [Element.Row, Element.Col, Element.Box] {
      for i in 0..<9
      {
        var oc : [RowCol]!
        switch e {
        case .Row: oc = openCells(inRow: i)
        case .Col: oc = openCells(inCol: i)
        case .Box: oc = openCells(inBox: i)
        }
        while(oc.count > 1)
        {
          let rc1 = oc.removeFirst()
          for rc2 in oc
          {
            let u = marks[rc1.row][rc1.col].union( marks[rc2.row][rc2.col] )
            if u.n == 2 {
              found.append( (rc1,rc2,e,u.digits()) )
            }
          }
        }
      }
    }
    
    for pair in found
    {      
      let rc1 = pair.rc1
      let rc2 = pair.rc2
      
      var clearedSomething = false
      switch(pair.element)
      {
      case .Row:
        let row = rc1.row
        for col in 0..<9 {
          if col != rc1.col, col != rc2.col, digits[row][col] == nil {
            for d in pair.digits {
              if marks[row][col].has(digit:d) {
                marks[row][col].clear(d)
                clearedSomething = true
              }
            }
          }
        }
      case .Col:
        let col = rc1.col
        for row in 0..<9 {
          if row != rc1.row, row != rc2.row, digits[row][col] == nil {
            for d in pair.digits {
              if marks[row][col].has(digit:d) {
                marks[row][col].clear(d)
                clearedSomething = true
              }
            }
          }
        }
      case .Box:
        let boxRow = 3*(rc1.row/3)
        let boxCol = 3*(rc1.col/3)
        for i in 0..<9 {
          let row = boxRow + i/3
          let col = boxCol + i%3
          if (row != rc1.row) || (col != rc1.col),
             (row != rc2.row) || (col != rc2.col),
             digits[row][col] == nil
          {
            for d in pair.digits {
              if marks[row][col].has(digit:d) {
                marks[row][col].clear(d)
                clearedSomething = true
              }
            }
          }
        }
      }
      if clearedSomething {
        rval = true
        difficulty += nakedPairWeight
        print("Naked pair found: (\(pair.rc1.row),\(pair.rc1.col)), (\(pair.rc2.row),\(pair.rc2.col)), \(pair.element.rawValue) : \(pair.digits)")
      }
    }
    
    
    return rval
  }
  
}
