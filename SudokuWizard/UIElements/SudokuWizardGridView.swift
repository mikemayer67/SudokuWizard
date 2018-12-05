//
//  SudokuWizardGridView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/30/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

enum SudokuWizardError : Error
{
  case InvalidPuzzle(String)
}

class SudokuWizardGridView: UIView, SudokuWizardCellViewDelegate
{
  enum GridState
  {
    case Unset
    case Active
    case Solved
  }
  
  private(set) var state = GridState.Unset
  
  let bgView          = BackgroundView()
  var cellViews       = [SudokuWizardCellView]()
  
  var cellInputController : SudokuWizardInputController?
  
  // MARK: -
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    // MARK:  grid content

    self.addSubview(bgView)
    
    bgView.translatesAutoresizingMaskIntoConstraints = false
    bgView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    bgView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    bgView.widthAnchor.constraint(equalTo: bgView.heightAnchor).isActive = true
    
    var index = 0;
    for row in 0...8 {
      for col in 0...8 {
        let cell = SudokuWizardCellView(row:row,col:col)
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
        
        cell.delegate = self
        
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
      cell.highlighted = false
    }
    
    state = .Unset
  }
  
  func loadPuzzle(_ puzzle:String) throws
  {
    clear()
    guard puzzle.count == 81 else { throw SudokuWizardError.InvalidPuzzle("Puzzle string must contiain 81 characters") }
    
    let digitString = puzzle.replacingOccurrences(of: ".", with: "0")
    let digits = digitString.compactMap{Int(String($0))}
    
    guard digits.count == 81 else { throw SudokuWizardError.InvalidPuzzle("Puzzle string must contiain only digits and periods") }

    for i in 0...80 {
      let d = digits[i]
      if d > 0 { cellViews[i].state = .locked(d) }
    }
    
    state = .Active
  }

  // MARK: -
  
  func sudokuWizardCellTapped(_ cell: SudokuWizardCellView)
  {
    guard state == .Active else { return }
    
    if cell.selected == false
    {
      select(cell)
      return
    }
   
    print("Popup value picker")
  }
  
  func sudokuWizardCellPressed(_ cell: SudokuWizardCellView)
  {
    guard state == .Active else { return }

    select(cell)
    print("Popup mark picker")
  }
  
  func select(_ cell:SudokuWizardCellView)
  {
    if cell.selected == false
    {
      for i in 0...80 { cellViews[i].selected = false }
      cell.selected = true
    }
  }
}

// MARK: -

class BackgroundView: UIView
{
  override func draw(_ rect: CGRect)
  {
    super.draw(rect)
    UIColor.black.setFill()
    let path = UIBezierPath(rect: rect)
    path.fill()
  }
}


//
//func sudokuWizardCellPopupForUserInput(_ cellView: SudokuWizardCellView)
//{
//  if popupController == nil
//  {
//    print("Create popup controller")
//    popupController = SudokuWizardPopupController()
//  }
//  if let pc = popupController
//  {
//    print("Popup for :", cellView, pc )
//    print("bounds frame: ", self.boundsView.frame )
//    print("cell frame: ", cellView.frame )
//
//    present(pc, animated: false)
//    {
//      print("Popup presented")
//    }
//  }
//}
