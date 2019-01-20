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
  private let hiddenSingleWeight = 0.1
  private let nakedSingleWeight  = 0.2
  private let nakedPairWeight    = 1.0
  private let nakedTripleWeight  = 1.1
  private let hiddenPairWeight   = 1.3
  private let hiddenTripleWeight = 1.4
  private let pointingPairWeight = 1.5
  private let guessWeight        = 3.0
  
  private let difficultyMin      = 1.0
  private let difficultyConst    = 4.0
  private let difficultyFactor   = 1.0
  
  private let insaneWeight       = 999.0

  private(set) var difficulty = 0.0
  
  // 9x9 matrix containing marks for each cell
  private var marks  = [[DigitSet]](repeating: [DigitSet](repeating: DigitSet(true), count: 9), count: 9)
  
  // 9x9 matrix containing digits (or nil)
  private var digits = [[Digit?]](repeating: [Digit?](repeating: nil, count: 9), count: 9)
  
  private var numComplete = 0
  
  init?(_ puzzle:SudokuGrid,_ truth:SudokuGrid)
  {
    for r in 0..<9 {
      for c in 0..<9 {
        if let d = puzzle[r][c] { add(row:r, col:c, digit:d) }
      }
    }

    let dlx = try! DLXSudoku(puzzle)
    let status = dlx.evaluate()

    guard case DLXSolutionStatus.UniqueSolution = status else { return nil }
    
    while numComplete < 81
    {
      if findHiddenSingles() { continue }
      if findNakedSingles()  { continue }
      if findNakedPairs()    { continue }
      if findNakedTriples()  { continue }
      if findHiddenPairs()   { continue }
      if findHiddenTriples() { continue }
      if findPointingPair()  { continue }
      if guess(truth:truth)  { continue }
      
      print("\nGrader unable to find solution\n")
      difficulty = insaneWeight;
      break
    }
    
    difficulty *= difficultyFactor
    difficulty -= difficultyConst
    if difficulty < difficultyMin { difficulty = difficultyMin }
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
      if col != notInCol, digits[inRow][col] == nil { rval.append(RowCol(inRow,col)) }
    }
    return rval
  }
  
  private func openCells(inCol:Int, notInRow:Int? = nil) -> [RowCol]
  {
    var rval = [RowCol]()
    for row in 0..<9 {
      if row != notInRow, digits[row][inCol] == nil { rval.append(RowCol(row,inCol)) }
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
      if !(row == notInRow && col == notInCol), digits[row][col] == nil { rval.append(RowCol(row,col)) }
    }
    return rval
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
//      print(" NakedSingle(\(rcd.row),\(rcd.col),\(rcd.digit))")
      add(row: rcd.row, col: rcd.col, digit: rcd.digit)
      difficulty += nakedSingleWeight
    }
    
    return rval
  }
  
  private func findNakedPairs() -> Bool
  {
    var ncleared = 0
    
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
        while(oc.count > 2) // if only 2 cells, pair has no other cells to clear
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
      
      switch(pair.element)
      {
      case .Row:
        let row = rc1.row
        for col in 0..<9 {
          if col != rc1.col, col != rc2.col, digits[row][col] == nil {
            for d in pair.digits {
              if marks[row][col].has(digit:d) {
                marks[row][col].clear(d)
                ncleared += 1
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
                ncleared += 1
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
                ncleared += 1
              }
            }
          }
        }
      }
    }
    
    if ncleared == 0 { return false }
    
    let fac = 0.8 + 0.2/Double(ncleared)
    difficulty += fac * nakedPairWeight
    
    return true
  }
  
  private func findNakedTriples() -> Bool
  {
    var ncleared = 0
    
    var found = [ (rc1:RowCol,rc2:RowCol,rc3:RowCol,element:Element,digits:[Digit]) ]()
    
    for e in [Element.Row, Element.Col, Element.Box] {
      for i in 0..<9
      {
        var oc : [RowCol]!
        switch e {
        case .Row: oc = openCells(inRow: i)
        case .Col: oc = openCells(inCol: i)
        case .Box: oc = openCells(inBox: i)
        }
        while oc.count > 3 // if only 3 cells, triple has no other cells to clear
        {
          let rc1 = oc.removeFirst()
          var soc = oc!
          while soc.count > 1
          {
            let rc2 = soc.removeFirst()
            for rc3 in soc
            {
              let u = marks[rc1.row][rc1.col].union(marks[rc2.row][rc2.col]).union(marks[rc3.row][rc3.col])
              if u.n == 3 {
                found.append( (rc1,rc2,rc3,e,u.digits()) )
              }
            }
          }
        }
      }
    }
    
    for triple in found
    {
      let rc1 = triple.rc1
      let rc2 = triple.rc2
      let rc3 = triple.rc3
      
      switch(triple.element)
      {
      case .Row:
        let row = rc1.row
        for col in 0..<9 {
          if col != rc1.col, col != rc2.col, col != rc3.col, digits[row][col] == nil {
            for d in triple.digits {
              if marks[row][col].has(digit:d) {
                marks[row][col].clear(d)
                ncleared += 1
              }
            }
          }
        }
      case .Col:
        let col = rc1.col
        for row in 0..<9 {
          if row != rc1.row, row != rc2.row, row != rc3.row, digits[row][col] == nil {
            for d in triple.digits {
              if marks[row][col].has(digit:d) {
                marks[row][col].clear(d)
                ncleared += 1
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
            (row != rc3.row) || (col != rc3.col),
            digits[row][col] == nil
          {
            for d in triple.digits {
              if marks[row][col].has(digit:d) {
                marks[row][col].clear(d)
                ncleared += 1
              }
            }
          }
        }
      }
    }
    
    if ncleared == 0 { return false }
    
    let fac = 0.8 + 0.2/Double(ncleared)
    difficulty += fac * nakedTripleWeight
    
    return true
  }
  
  private func findHiddenPairs() -> Bool
  {
    var ncleared = 0
    
    for e in [Element.Row, Element.Col, Element.Box] {
      for i in 0..<9 {
        var oc : [RowCol]!
        switch e {
        case .Row: oc = openCells(inRow: i)
        case .Col: oc = openCells(inCol: i)
        case .Box: oc = openCells(inBox: i)
        }
        let noc = oc.count
        if(oc.count > 2) { // if only 2 cells, not really hidden...
          for i in 0..<(noc-1) {
            let rc1 = oc[i]
            for j in (i+1)..<noc {
              let rc2 = oc[j]
              var u = marks[rc1.row][rc1.col].union(marks[rc2.row][rc2.col])
              for k in 0..<noc {
                if k != i, k != j
                {
                  let rc = oc[k]
                  u = u.subtract(marks[rc.row][rc.col])
                }
              }
              if u.n == 2 {
                if marks[rc1.row][rc1.col].subtract(u).isEmpty == false {
                  marks[rc1.row][rc1.col] = marks[rc1.row][rc1.col].subtract(u.complement())
                  ncleared += 1
                }
                if marks[rc2.row][rc2.col].subtract(u).isEmpty == false {
                  marks[rc2.row][rc2.col] = marks[rc2.row][rc2.col].subtract(u.complement())
                  ncleared += 1
                }
              }
            }
          }
        }
      }
    }
    
    if ncleared == 0 { return false }
    
    let fac = 0.8 + 0.2/Double(ncleared)
    difficulty += fac * hiddenPairWeight
    
    return true
  }
  
  private func findHiddenTriples() -> Bool
  {
    var ncleared = 0
    
    for e in [Element.Row, Element.Col, Element.Box] {
      for i in 0..<9 {
        var oc : [RowCol]!
        switch e {
        case .Row: oc = openCells(inRow: i)
        case .Col: oc = openCells(inCol: i)
        case .Box: oc = openCells(inBox: i)
        }
        let noc = oc.count
        if(oc.count > 3) { // if only 3 cells, not really hidden...
          for i in 0..<(noc-2) {
            let rc1 = oc[i]
            for j in (i+1)..<(noc-1) {
              let rc2 = oc[j]
              for k in (j+1)..<noc {
                let rc3 = oc[k]
                var u = marks[rc1.row][rc1.col].union(marks[rc2.row][rc2.col]).union(marks[rc3.row][rc3.col])
                for m in 0..<noc {
                  if m != i, m != j, m != k
                  {
                    let rc = oc[m]
                    u = u.subtract(marks[rc.row][rc.col])
                  }
                }
                if u.n == 3 {
                  if marks[rc1.row][rc1.col].subtract(u).isEmpty == false {
                    marks[rc1.row][rc1.col] = marks[rc1.row][rc1.col].subtract(u.complement())
                    ncleared += 1
                  }
                  if marks[rc2.row][rc2.col].subtract(u).isEmpty == false {
                    marks[rc2.row][rc2.col] = marks[rc2.row][rc2.col].subtract(u.complement())
                    ncleared += 1
                  }
                  if marks[rc3.row][rc3.col].subtract(u).isEmpty == false {
                    marks[rc3.row][rc3.col] = marks[rc3.row][rc3.col].subtract(u.complement())
                    ncleared += 1
                  }
                }
              }
            }
          }
        }
      }
    }
    
    if ncleared == 0 { return false }
    
    let fac = 0.8 + 0.2/Double(ncleared)
    difficulty += fac * hiddenTripleWeight
    
    return true
  }
    
  private func findPointingPair() -> Bool
  {
    var ncleared = 0
    
    // Note that we initially build indices for a row/box intersection
    //  These will be transposed when evaluating pointing pairs in columns
    //  Comments below reflect pointing pairs in rows
    
    var src  : [RowCol]!  // intresection of row/col and box
    var tgt1 : [RowCol]!  // remainder of row/col outside box
    var tgt2 : [RowCol]!  // remainder of box not in row/col
    
    for r in 0..<9 {
      // find indices of the 2 rows in the boxes intersecting the current row OTHER than the current row
      let r1 = 3*(r/3) + ( r%3 == 0 ? 1 : 0 )
      let r2 = 3*(r/3) + ( r%3 == 2 ? 1 : 2 )
      // loop over all boxes that intersect the current row (c is first column in each box)
      for c in [0,3,6]
      {
        // find first column indices of the boxes that intersect the current row OTHER than the current box
        let c1 = ( c == 0 ? 3 : 0 )
        let c2 = ( c == 6 ? 3 : 6 )
        
        // build for rows, transpose if we're testing columns
        src  = [ RowCol(r,c),  RowCol(r,c+1),  RowCol(r,c+2) ]
        tgt1 = [ RowCol(r,c1), RowCol(r,c1+1), RowCol(r,c1+2), RowCol(r,c2), RowCol(r,c2+1), RowCol(r,c2+2) ]
        tgt2 = [ RowCol(r1,c), RowCol(r1,c+1), RowCol(r1,c+2), RowCol(r2,c), RowCol(r2,c+1), RowCol(r2,c+2) ]
        
        for e in [Element.Row,Element.Col]
        {
          // transpose for columns (if that's what we're doing on this pass
          if e == .Col {
            for i in 0..<3 { src[i].transpose() }
            for i in 0..<6 { tgt1[i].transpose(); tgt2[i].transpose() }
          }
          
          // total of 4 passes: Rule: (indices) Test => action
          //  0: (.Row,0)   Pair/Triple in a row, all in the same box => remove pair/triple from the rest of the box
          //  1: (.Row,1)   Pair/Triple in a box, all in the same row => remove pair/triple from the rest of the row
          //  2: (.Col,0)   Pair/Triple in a box, all in the same col => remove pair/triple from the rest of the col
          //  3: (.Col,1)   Pair/Triple in a col, all in the same box => remove pair/triple from the rest of the box
          for i in [0,1] {
            // change rule 0->1 or 2->3
            if i == 1 { let tmp = tgt1; tgt1 = tgt2; tgt2 = tmp }
            
            var n = 0                // number of cells in the intersection of row/col with box
            var u = DigitSet(false)
            
            // find all marks in the intersection of row/col with box
            for rc in src {
              if digits[rc.row][rc.col] == nil {
                n += 1
                u = u.union(marks[rc.row][rc.col])
              }
            }
            
            // determine which are unique to intersection of row/col with box
            for rc in tgt1 {
              if digits[rc.row][rc.col] == nil {
                u = u.subtract(marks[rc.row][rc.col])
              }
            }

            // pointing pair if number of unique marks equals number of cells in the intersection
            if n > 1, n == u.n {
              // look for target cells that contain one of the marks unique to the intersection
              for rc in tgt2 {
                if digits[rc.row][rc.col] == nil,
                  marks[rc.row][rc.col].intersect(u).n > 0
                {
                  // clear them if found
                  ncleared += 1
                  marks[rc.row][rc.col] = marks[rc.row][rc.col].subtract(u)
                }
              }
            }
          }
          
        }
      }
    }
    
    if ncleared == 0 { return false }
    
    let fac = 0.8 + 0.2/Double(ncleared)
    difficulty += fac * pointingPairWeight
    
    return true
  }
  
  private func guess(truth:SudokuGrid) -> Bool
  {
    var rval = false
    
    var num = 0.0
    var den = 0.0
    
    var nmarks = 10
    var cell : RowCol?
    
    for r in 0..<9 {
      for c in 0..<9 {
        if digits[r][c] == nil {
          let m = marks[r][c]
          if m.n < nmarks {
            nmarks = m.n;
            cell = RowCol(r, c)
          }
          num += 1.0
          den += Double(m.n)
        }
      }
    }
    
    if let rc = cell, let d = truth[rc.row][rc.col]
    {
      rval = true
      
      let prob_fail = 1.0 - num/den
      let n_guess = log(0.10) / log(prob_fail)
      
      let fac = 1.0 + 0.1 * n_guess
      
      difficulty += fac * guessWeight
      
      add(row: rc.row, col: rc.col, digit: d)
    }
    
    return rval
  }
  
}
