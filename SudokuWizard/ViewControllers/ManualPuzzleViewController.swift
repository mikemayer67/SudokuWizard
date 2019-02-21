//
//  ManualPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/28/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class ManualPuzzleViewController: NewPuzzleViewController, EditorBackgroundViewDelegate
{
  @IBOutlet weak var startButton : UIButton!
  @IBOutlet weak var restartButton : UIButton!
  @IBOutlet weak var digitsView : UIView!
  @IBOutlet weak var digitsViewHeight : NSLayoutConstraint!
  @IBOutlet weak var statusLabel : StatusView!
  
  private var digitButtons = [DigitButton]()
  private let digitButtonSep : CGFloat = 0.1
  
  private var tint = UIColor.black
  
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
    
    tint = startButton.titleColor(for: .normal) ?? .black
    
    for d : Digit in 1...9 {
      let btn = DigitButton(d)
      btn.tint = tint
      btn.isEnabled = false
      
      btn.addTarget(self, action: #selector(handleDigitButton(_:)), for: .touchUpInside)
      
      digitsView.addSubview(btn)
      
      digitButtons.append(btn)
    }
    
    gridView.errorFeedback = .conflict
    
    resetPuzzle()
  }
    
  override func viewDidLayoutSubviews()
  {
    super.viewDidLayoutSubviews()
  
    let boxWidth = digitsView.bounds.width

    if boxWidth > 0.0 {
      let buttonSize = boxWidth / (9.0 + 10.0*digitButtonSep)
      let buttonSep  = digitButtonSep * buttonSize
      
      digitsViewHeight.constant = buttonSize
      
      var xo = buttonSep;
      for btn in digitButtons
      {
        btn.frame = CGRect(x:xo, y:0.0, width: buttonSize, height:buttonSize)
        xo += buttonSep + buttonSize
      }
      
    }
    
    updateUI()
  }
  
  func resetPuzzle()
  {
    gridView.clear()
    selectButton(nil)
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
    
    digitButtonsEnabled = gridView.selectedCell != nil
    
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
  
  var digitButtonsEnabled = false
  {
    didSet {
      if digitButtonsEnabled != oldValue {
        for btn in digitButtons {
          btn.isEnabled = digitButtonsEnabled
        }
      }
    }
  }
  
  func handleBackgroundTap()
  {
    gridView.selectedCell = nil
    selectButton(nil)
    digitButtonsEnabled = false
  }
  
  @objc func handleDigitButton(_ sender:DigitButton)
  {
    guard let cell = gridView.selectedCell else { return }
    
    if sender.isSelected {
      selectButton(nil)
      cell.state = .empty
    }
    else
    {
      selectButton(sender.digit)
      cell.state = .filled(sender.digit)
    }
    
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
  
  func selectButton(_ digit:Digit?)
  {
    for btn in digitButtons {
      btn.isSelected = (btn.digit == digit)
    }
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
    
    selectButton(digit)
    updateUI()
  }
  
  override func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView)
  {
    gridView.track(touch: touch)
  }
}
