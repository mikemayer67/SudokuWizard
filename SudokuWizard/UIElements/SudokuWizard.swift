//
//  Enums.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/21/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

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
