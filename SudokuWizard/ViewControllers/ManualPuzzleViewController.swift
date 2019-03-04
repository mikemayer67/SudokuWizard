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
    (view as? EditorBackgroundView)?.delegate = self
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
          let solution = dlx.sudokuSolution()
          
          gridView.addSolution(solution)
          
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
    puzzleController?.restart(with: gridView)
    dismiss()
  }
  
  @IBAction func handleRestart(_ sender: UIButton)
  {
    let alert = UIAlertController(title:"Restart Puzzle",
                                  message:"Clear all digits from the puzzle",
                                  preferredStyle:.alert)
    alert.addAction( UIAlertAction(title: "OK", style:.destructive) { _ in self.resetPuzzle() } )
    alert.addAction( UIAlertAction(title:"Cancel", style:.cancel) )
    
    self.present(alert,animated: true)
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
  
  // MARK: - Test Hack
  
  @IBOutlet weak var hackButton : UIButton?
  
  @IBAction func testHack(_ sender: UIButton)
  {
    var demos : [String] = [String]()
    demos.append("74..9.2.83.8..2....5.8....6..6....2.2.......5.1....4..1....3.6....9..8.18.9.1..53")
    demos.append(".4..9.2..3.8..2....5.8....6..6....2.2.......5.1....4..1....3.6....9....18.9.1..53")
    
    let demo = demos[ Int.random(in: 0...1) ]
    
    let digits = try! demo.sudokuGrid()
    
    resetPuzzle()
    for i in 0...80
    {
      let c = gridView.cellViews[i]
      sudokuWizardCellView(selected: c )
      
      if let d = digits[i/9][i%9] {
        digitBox.select(digit: d)
        c.state = .filled(d)
      }
      else {
        digitBox.select(digit: nil)
      }
    }
    
    updateState()
    
    handleBackgroundTap()
  }
}
