//
//  UndoableActions.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 3/3/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import Foundation

class ChangeDigit : UndoableAction
{
  private(set) var label : String
  
  let grid     : SudokuWizardGridView
  let cell     : SudokuWizardCellView
  let oldDigit : Digit?
  
  private(set) var newDigit : Digit?
  
  var oldMarks = Dictionary<SudokuWizardCellView,[Bool]>()
  
  init(grid:SudokuWizardGridView, cell:SudokuWizardCellView, digit:Digit?)
  {
    self.oldDigit = cell.digit
    self.newDigit = digit
    
    self.grid = grid
    self.cell  = cell
    self.label = digit == nil ? "clearing of " : "add \(digit!) to "
    self.label = self.label + "(r\(cell.row! + 1),c\(cell.col! + 1))"
    
    if self.oldDigit != nil { oldMarks[cell] = cell.marks }
    
    for peer in cell.peers {
      if case .empty = peer.state {
        oldMarks[peer] = peer.marks
      }
    }
  }
  
  func undo() -> Bool
  {
    if let d = oldDigit { cell.state = .filled(d) }
    else                { cell.state = .empty     }
    
    for (cell,marks) in oldMarks { cell.set(marks:marks) }
    
    grid.findAllErrors()
    
    return true
  }
  
  func redo() -> Bool
  {
    if let d = newDigit { cell.state = .filled(d) }
    else                { cell.state = .empty     }

    grid.findAllErrors()
    
    return true
  }
  
  func merge(_ action:UndoableAction) -> Bool
  {
    guard let a = action as? ChangeDigit else { return false }
    guard cell === a.cell else { return false }
    
    newDigit = a.newDigit
    label = a.label
    
    return true
  }
}
