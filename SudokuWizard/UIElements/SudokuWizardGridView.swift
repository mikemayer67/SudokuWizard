//
//  SudokuWizardGridView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/30/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class SudokuWizardGridView: UIView
{
  @IBOutlet weak var viewController : UIViewController!
  
  // MARK: -
  
  enum GridState
  {
    case Empty
    case Populated
    case Solved
  }
  
  class BackgroundView: UIView
  {
    override func draw(_ rect: CGRect) {
      UIColor.black.setFill()
      UIBezierPath(rect: rect).fill()
    }
  }
  
  // MARK: -
  
  private(set) var state = GridState.Empty
  
  var bgView : UIView!
  var cellViews = [SudokuWizardCellView]()
  
  var highlightActiveDigit = true
  {
    didSet { updateHighlights() }
  }
  
  var selectedCell : SudokuWizardCellView?
  {
    didSet
    {
      if selectedCell == nil {
        oldValue?.selected = false
      }
      else {
        for c in cellViews {
          if c != selectedCell { c.selected = false }
        }
      }
      updateHighlights()
    }
  }
  
  func updateHighlights()
  {
    if highlightActiveDigit, let d = selectedCell?.digit
    {
      for c in cellViews { c.highlighted = ( c != selectedCell && c.digit == d ) }
    }
    else
    {
      for c in cellViews { c.highlighted = false }
    }
  }
  
  func track(touch:UITouch)
  {
    for cell in cellViews {
      if cell.bounds.contains(touch.location(in: cell)) {
        cell.selected = true
        break
      }
    }
  }
  
  var markStyle : SudokuWizard.MarkStyle = .digits
  {
    didSet { cellViews.forEach { cell in cell.markStyle = markStyle } }
  }
  
  var markStrategy : SudokuWizard.MarkStrategy = .manual
  {
    didSet { if markStrategy != oldValue { computeAllMarks() } }
  }
  
  var errorFeedback : SudokuWizard.ErrorFeedback = .conflict
  {
    didSet { if errorFeedback != oldValue { findAllErrors() } }
  }
  
  // MARK: -
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    // MARK:  grid content

    bgView = BackgroundView()
    self.addSubview(bgView)
    
    bgView.translatesAutoresizingMaskIntoConstraints = false
    
    let bgw = self.bounds.width
    let bgh = self.bounds.height
    if bgw < bgh {
      bgView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
      bgView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
      bgView.widthAnchor.constraint(equalTo: bgView.heightAnchor).isActive = true
    } else {
      bgView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
      bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
      bgView.widthAnchor.constraint(equalTo: bgView.heightAnchor).isActive = true
      bgView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    var index = 0;
    for row in 0...8 {
      for col in 0...8 {
        let cell = SudokuWizardCellView(row:row,col:col)
        cell.markStyle = markStyle
        
        cellViews.append(cell)
        bgView.addSubview(cell)
        
        cell.translatesAutoresizingMaskIntoConstraints = false
        
        switch row
        {
        case 0:
          cell.topAnchor.constraint(equalTo: bgView.topAnchor, constant:1.0).isActive = true
        case 3, 6:
          cell.topAnchor.constraint(equalTo: cellViews[index-9].bottomAnchor, constant:2.0).isActive = true
        case 8:
          cell.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -1.0).isActive = true
          fallthrough
        default:
          cell.topAnchor.constraint(equalTo: cellViews[index-9].bottomAnchor, constant:1.0).isActive = true
        }
        
        switch col
        {
        case 0:
          cell.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant:1.0).isActive = true
        case 3, 6:
          cell.leftAnchor.constraint(equalTo: cellViews[index-1].rightAnchor, constant:2.0).isActive = true
        case 8:
          cell.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -1.0).isActive = true
          fallthrough
        default:
          cell.leftAnchor.constraint(equalTo: cellViews[index-1].rightAnchor, constant:1.0).isActive = true
        }
        
        if index > 0 {
          cell.widthAnchor.constraint(equalTo: cellViews[0].widthAnchor).isActive = true
          cell.heightAnchor.constraint(equalTo: cellViews[0].heightAnchor).isActive = true
        }
        
        index += 1
      }
    }
    
    // MARK: popup controller
    
  }
  
  // MARK: -
  
  func clear()
  {
    cellViews.forEach  { (cell) in
      cell.state = .empty
      cell.selected = false
      cell.errant = false
      cell.highlighted = false
      cell.clearAllMarks()
      cell.correctDigit = nil
    }
    
    state = .Empty
    selectedCell = nil
  }
  
  func loadPuzzle(string puzzle:String, solution:String? = nil) throws
  {
    try loadPuzzle( puzzle.sudokuGrid(), solution:solution?.sudokuGrid() )
  }
  
  func loadPuzzle(_ puzzle:SudokuGrid, solution:SudokuGrid? = nil) throws
  {
    clear()
    
    for i in 0...80 {
      if let d = puzzle[i/9][i%9], d>0 {
        cellViews[i].state = .locked(d)
      }
    }
    
    if let s = solution
    {
      for i in 0...80 {
        guard let d = s[i/9][i%9] else {
          throw SudokuWizardError.InvalidPuzzle("Puzzle solution must contiain only digits 1-9")
        }
        cellViews[i].correctDigit = d
      }
    }
    
    computeAllMarks()
    findAllErrors()
    
    state = .Populated
  }
  
  var puzzle : SudokuGrid {
    var rval = SudokuGrid()
    var row = Digits()
    for cell in cellViews {
      row.append(cell.digit)
      if row.count == 9 {
        rval.append(row)
        row.removeAll()
      }
    }
    return rval
  }
  
  // MARK: -
  
  func clearAllMarks()
  {
    if markStrategy == .manual {
      cellViews.forEach { cell in cell.clearAllMarks() }
    }
  }
  
  func computeAllMarks()
  {
    guard markStrategy != .manual else { return }
    
    // turn on all marks until demonstrated otherwise
    var marks = [[Bool]](repeating: [Bool](repeating: true, count: 9), count: 81)
    
    // loop over grid cells, update marks based on values
    cellViews.forEach { cell in
      if case .empty = cell.state { return }
      
      let r = cell.row!
      let c = cell.col!
      let d = Int(cell.digit!)
      
      let br = 3*(r/3)  // row index of NW corner of current box
      let bc = 3*(c/3)  // col index of NW corner of current box
      
      for i in 0...8 {
        marks[9*r + c][i] = false  // clear all marks in current cell
        
        marks[9*r + i][d-1] = false  // clear v-mark in current column
        marks[9*i + c][d-1] = false  // clear v-mark in current row
        
        let ri = i/3  // ith row offset in current box
        let ci = i%3  // ith col offset in current box
        
        marks[9*(br+ri) + (bc+ci)][d-1] = false // clear v-mark in current box
      }
    }
    
    for i in 0...80 {
      if markStrategy == .conflicted {
        for j in 0...8 { marks[i][j] = !marks[i][j] }
      }
      cellViews[i].set(marks: marks[i])
    }
  }
  
  func findAllErrors()
  {
    cellViews.forEach { cell in checkForErrors(for:cell) }
  }
  
  func handleValueChange(for cell:SudokuWizardCellView)
  {
    let r = cell.row!
    let c = cell.col!
    
    let br = 3*(r/3)  // row index of NW corner of current box
    let bc = 3*(c/3)  // col index of NW corner of current box
    
    for i in 0...8 {
      if i != c { update(cellViews[9*r + i] ) }
      if i != r { update(cellViews[9*i + c] ) }
      
      let ri = i/3  // ith row offset in current box
      let ci = i%3  // ith col offset in current box
      update(cellViews[9*(br+ri) + (bc+ci)] )
    }
  }
  
  func update(_ cell:SudokuWizardCellView)
  {
    checkForErrors(for:cell)
    updateMarks(for:cell)
  }
  
  func checkForErrors(for cell:SudokuWizardCellView)
  {
    cell.errant = false
    
    if errorFeedback == .none { return }
    
    if errorFeedback == .error
    {
      if let d = cell.digit, let cd = cell.correctDigit, d != cd
      {
        cell.errant = true
        return
      }
    }
    
    let r = cell.row!
    let c = cell.col!
    
    guard let d = cell.digit else { return }
    
    let br = 3*(r/3)  // row index of NW corner of current box
    let bc = 3*(c/3)  // col index of NW corner of current box
    
    for i in 0...8 {
      let rowCell = cellViews[9*r + i]
      let colCell = cellViews[9*i + c]
      
      let ri = i/3  // ith row offset in current box
      let ci = i%3  // ith col offset in current box
      
      let boxCell = cellViews[9*(br+ri)+(bc+ci)]
      
      for tc in [rowCell,colCell,boxCell] {
        if tc !== cell, tc.digit == d { cell.errant = true; return }
      }
    }
  }
  
  func updateMarks(for cell:SudokuWizardCellView)
  {
    guard markStrategy != .manual else { return }
    
    let r = cell.row!
    let c = cell.col!
    
    let br = 3*(r/3)  // row index of NW corner of current box
    let bc = 3*(c/3)  // col index of NW corner of current box
    
    var marks = [Bool](repeating:true,count:9)
    
    for m : Digit in 1...9 {
      let j = Int(m)-1
      for i in 0...8 {
        if cellViews[9*r + i].digit == m { marks[j] = false; break }
        if cellViews[9*i + c].digit == m { marks[j] = false; break }
        
        let ri = i/3  // ith row offset in current box
        let ci = i%3  // ith col offset in current box
        if cellViews[9*(br+ri)+(bc+ci)].digit == m { marks[j] = false; break }
      }
    }
    if markStrategy == .conflicted {
      for i in 0...8 { marks[i] = !marks[i] }
    }
    
    cell.set(marks:marks)
  }
}
