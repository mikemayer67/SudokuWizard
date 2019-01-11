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

let links : Array<Set<Int>> = {
  var rval = Array<Set<Int>>(repeating: Set<Int>(), count: 81)
  
  for i in 1...80 {
    let r = i/9
    let c = i%9
    let b = 3*(r/3) + (c/3)
    for j in 0..<i {
      let rr = j/9
      let cc = j%9
      let bb = 3*(rr/3) + (cc/3)
      
      if( r == rr || c == cc || b == bb )
      {
        rval[i].insert(j)
      }
    }
  }
  return rval
}()

// hide4Candidates and hide2Candidates are used for converting
// a solution grid to a puzzle grid by hiding cells.  They provide
// the indices of unambiguous cells when attempting to symmetrically
// hide 4 or 2 cells respectively
//
//  00 01 02 03 04 05 06 07 08   00 01 02 03 04 05 06 07 bb   00 01 02 03 04 05 06 07 08
//  09 10 11 12 13 14 15 16 17   dd 10 11 12 13 14 15 bb bb   aa 10 11 12 13 14 15 16 17
//  18 19 20 21 22 23 24 25 26   dd dd 20 21 22 23 bb bb bb   aa aa 20 21 22 23 24 25 26
//  27 28 29 30 31 32 33 34 35   dd dd dd 30 31 bb bb bb bb   aa aa aa 30 31 32 33 34 35
//  36 37 38 39 40 41 42 43 44   dd dd dd dd XX bb bb bb bb   aa aa aa aa XX 41 42 43 44
//  45 46 47 48 49 50 51 52 53   dd dd dd dd cc cc bb bb bb   aa aa aa aa aa aa 51 52 53
//  54 55 56 57 58 59 60 61 62   dd dd dd cc cc cc cc bb bb   aa aa aa aa aa aa aa 61 62
//  63 64 65 66 67 68 69 70 71   dd dd cc cc cc cc cc cc bb   aa aa aa aa aa aa aa aa 71
//  72 73 74 75 76 77 78 79 80   dd cc cc cc cc cc cc cc cc   aa aa aa aa aa aa aa aa aa 

let hide4Candidates : Array<Int> = {
  var rval = Array(0...7)
  rval.append(contentsOf:Array(10...15))
  rval.append(contentsOf:Array(20...23))
  rval.append(contentsOf:Array(30...31))
  return rval
}()

let hide2Candidates : Array<Int> = {
  var rval = Array(0...8)
  rval.append(contentsOf:Array(10...17))
  rval.append(contentsOf:Array(20...26))
  rval.append(contentsOf:Array(30...35))
  rval.append(contentsOf:Array(41...44))
  rval.append(contentsOf:Array(51...53))
  rval.append(contentsOf:Array(61...62))
  rval.append(71)
  return rval
}()


class RandomSudoku
{
  var solution = Array<Int>()
  var showing : Array<Bool>!
  
  var truth : String
  var puzzle : String
  
  var difficulty : Int { return computeDifficulty() }
  
  init() {
    truth = "oops"
    puzzle = "oops"
    
    generateSolution()
    generatePuzzle()
  }
  
  private func generateSolution()
  {
    solution = Array<Int>(repeating: 0, count: 81)
    solution[0] = Int.random(in: 1...9)
    
    guard addRandomDigit(to:1) else {
      fatalError("Should never see this (\(#file):\(#line))")
    }
    
    truth = ""
    let zero = Int(UnicodeScalar("0").value)
    for i in 0...80 {
      let c = Character(UnicodeScalar(zero+solution[i])!)
      truth.append(c)
    }
  }
  
  private func addRandomDigit(to cell:Int) -> Bool
  {
    guard cell < 81 else { return true }
    var candidates = Set(Array(1...9))
    for linked in links[cell] {
      candidates.remove(solution[linked])
      if candidates.isEmpty { return false }
    }
    
    let pool = candidates.shuffled()
    for digit in pool {
      solution[cell] = digit
      if addRandomDigit(to: cell+1) { return true }
    }
    return false
  }
  
  private func generatePuzzle()
  {
    showing = Array<Bool>(repeating: true, count: 81)
    
    var hidden = 0
    hidden += hide4()
    hidden += hide2()
    
    showing[40] = false
    if validPuzzle() { hidden += 1 }
    else             { showing[40] = true }
    
    puzzle = ""
    let zero = Int(UnicodeScalar("0").value)
    for i in 0...80 {
      if showing[i] {
        let c = Character(UnicodeScalar(zero+solution[i])!)
        puzzle.append(c)
      }
      else {
        puzzle.append(".")
      }
    }
  }
  
  private func hide4() -> Int
  {
    var rval = 0
    let cand = hide4Candidates.shuffled()
    for n in cand {
      let e = 8 + 9*(n%9) - (n/9)
      let s = 8 + 9*(e%9) - (e/9)
      let w = 8 + 9*(s%9) - (s/9)
      showing[n] = false
      showing[e] = false
      showing[s] = false
      showing[w] = false
      
      if validPuzzle() {
        rval += 4
      }
      else
      {
        showing[n] = true
        showing[e] = true
        showing[s] = true
        showing[w] = true
      }
    }
    return rval
  }
  
  private func hide2() -> Int
  {
    var rval = 0
    let cand = hide2Candidates.shuffled()
    for ne in cand {
      if showing[ne] {
        let sw = 80 - ne
        showing[ne] = false
        showing[sw] = false
        
        if validPuzzle() {
          rval += 2
        }
        else
        {
          showing[ne] = true
          showing[sw] = true
        }
      }
    }
    return rval
  }
  
  private func validPuzzle() -> Bool
  {
    var givens = [(Int,Int,Int)]()
    for i in 0...80 {
      if showing[i] { givens.append((row:i/9, col:i%9, solution[i])) }
    }
    
    let dlx = try! DLXSudoku(givens)
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
  
  private func computeDifficulty() -> Int
  {
    return 50
    
//    // Difficulty will be on scale from 0-100
//    //   100 = can only be solved with calls to DLX
//    //     0 = no work needed at all (i.e. given completely filled in puzzle)
//    // Assign points as follow
//    //   call to DLX algorithm
//    // Normalize to final range
//    //   max value = 810
//
//    var hidden = Set<Int>()
//
//    var givens = [(Int,Int,Int)]()
//    for i in 0...80 {
//      if showing[i] { givens.append((row:i/9, col:i%9, solution[i])) }
//      else { hidden.insert(i) }
//    }
//
//    var dlxCalls = 0
//
//    while hidden.isEmpty == false
//    {
//    }
//    }
  }
  
}

