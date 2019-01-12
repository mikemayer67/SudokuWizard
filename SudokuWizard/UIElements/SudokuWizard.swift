//
//  Enums.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/21/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

fileprivate let zero = Int(UnicodeScalar("0").value)
fileprivate let nine = zero + 9
fileprivate let dot  = Int(UnicodeScalar(".").value)

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
  init(digits:Array<Int>)
  {
    self = ""
    for d in digits {
      switch d {
      case 1...9: self += "\(UnicodeScalar(zero+d)!)"
      case 0:     self += "."
      default:    fatalError("digits must each be in range 0-9")
      }
    }
  }
  
  func digits() -> Array<Int>
  {
    var rval = Array<Int>()
    for c in self.utf8 {
      let d = Int(c)
      switch(d) {
      case dot:         rval.append(0)
      case zero...nine: rval.append(d-zero)
      default:          fatalError("digits must be '.' or 0-9")
      }
    }
    guard rval.count == 81 else { fatalError("Invalid puzzle length \(rval.count)") }
    return rval
  }
}
