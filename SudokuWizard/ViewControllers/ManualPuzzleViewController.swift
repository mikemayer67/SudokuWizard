//
//  ManualPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/28/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class ManualPuzzleViewController: NewPuzzleViewController, EditorBackgroundViewDelegate, DigitButtonBoxDelegate
{
  @IBOutlet weak var startButton : UIButton!
  @IBOutlet weak var restartButton : UIButton!
  @IBOutlet weak var digitBox : DigitButtonBox!
  @IBOutlet weak var statusLabel : StatusView!
  
  enum PuzzleState
  {
    case empty
    case evaluating
    case good(difficulty:Int)
    case conflicted
    case notUnique
    case noSolution
  }
  
  private var state = PuzzleState.empty
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let v = view as? EditorBackgroundView
    {
      v.delegate = self
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    add(button:startButton)
    add(button:restartButton)
        
    gridView.errorFeedback = .conflict
    
    resetPuzzle()
  }
    
  override func viewDidLayoutSubviews()
  {
    super.viewDidLayoutSubviews()
    
    updateUI()
  }
  
  func resetPuzzle()
  {
    gridView.clear()
    digitBox.deselectAll()
    state = .empty
    updateUI()
  }
  
  func updateUI()
  {
    // startButton

    if case .good = state { startButton.isEnabled = true  }
    else                  { startButton.isEnabled = false }
    
    // restartButton
    
    if case .empty = state { restartButton.isEnabled = false }
    else                   { restartButton.isEnabled = true  }
    
    // digitButtonsEnabled
    
    digitBox.enabled = gridView.selectedCell != nil
    
    // status
    
    switch state
    {
    case .empty:       statusLabel?.text = "Empty"
    case .conflicted:  statusLabel?.text = "Conflicts Found"
    case .evaluating:  statusLabel?.text = "Evaluating..."
    case .notUnique:   statusLabel?.text = "Multiple Solutions"
    case .noSolution:  statusLabel?.text = "No Solutions"
    case .good(let d): statusLabel?.text = String(format:"Difficulty: %d",d)
    }
  }
  
  func handleBackgroundTap()
  {
    gridView.selectedCell = nil
    digitBox.deselectAll()
    digitBox.enabled = false
  }
  
  func digitButtonBox(selected digit: Digit)
  {
    guard let cell = gridView.selectedCell else { return }
    cell.state = .filled(digit)
    updateState()
  }
  
  func digitButtonBox(unselected digit: Digit)
  {
    guard let cell = gridView.selectedCell else { return }
    cell.state = .empty
    updateState()
  }
  
  func updateState()
  {
    gridView.findAllErrors()
    gridView.updateHighlights()
    
    var empty = true
    var conflicted = false
    for c in gridView.cellViews {
      if case .empty = c.state { continue }
      empty = false
      if c.errant {
        conflicted = true
        break
      }
    }
    
    if empty {
      state = .empty
    }
    else if conflicted {
      state = .conflicted
    }
    else {
      do {
        let puzzle = gridView.puzzle
        let dlx = try DLXSudoku(puzzle)
        let status = dlx.evaluate()
        switch status
        {
        case .MultipleSolutions: state = .notUnique
        case .NoSolution:        state = .noSolution
        case .UniqueSolution(_):
          let solution = dlx.sudokuSolution(0)
          if let grader = SudokuGrader(puzzle,solution)
          {
            let difficulty = Int(grader.difficulty)
            state = .good(difficulty: difficulty)
          }
          else
          {
            state = .noSolution
          }
        }
      } catch {
        fatalError("Should never get here \(#file):\(#line)")
      }
    }
    
    updateUI()
  }
    
  @IBAction func handleStart(_ sender: UIButton) {
    print("MPVC: handle start")
    dismiss()
  }
  
  @IBAction func handleRestart(_ sender: UIButton)
  {
    print("MPVC: handle restart")
    resetPuzzle()
  }
  
  override func sudokuWizardCellView(selected cell: SudokuWizardCellView)
  {
    gridView.selectedCell = cell
    
    var digit : Digit?
    
    switch cell.state {
    case .locked(let d): digit = d
    case .filled(let d): digit = d
    case .empty: digit = nil
    }
    
    digitBox.select(digit: digit)
    updateUI()
  }
  
  override func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView)
  {
    gridView.track(touch: touch)
  }
}
