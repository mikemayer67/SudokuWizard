//
//  SudokuGrader.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 1/11/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import Foundation

class SudokuGrader
{
  init(_ puzzle:String)
  {
    var digits = puzzle.digits()
    print(digits)
  }
  
  var difficulty : Int {
    return 48
  }
}
