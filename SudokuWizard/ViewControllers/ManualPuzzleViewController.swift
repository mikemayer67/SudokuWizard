//
//  ManualPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/28/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class ManualPuzzleViewController: NewPuzzleViewController
{
  @IBOutlet weak var startButton : UIButton!
  @IBOutlet weak var restartButton : UIButton!
  @IBOutlet weak var digitsView : UIView!
  @IBOutlet weak var digitsViewHeight : NSLayoutConstraint!
  @IBOutlet weak var statusLabel : StatusView!
  
  private var digitButtons = [UIButton]()
  private let digitButtonSep : CGFloat = 0.25
  
  private var tint = UIColor.black
  private var puzzle : DLXSudoku.Grid!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    add(button:startButton)
    add(button:restartButton)
    
    tint = startButton.titleColor(for: .normal) ?? .black
    
    for i in 1...9 {
      let btn = UIButton(type:.custom)
      
      btn.setTitle(i.description, for: .normal)
      btn.tag = i
      btn.setTitleColor(tint, for: .normal)
      btn.setTitleColor(UIColor.white, for: .selected)
      btn.setTitleColor(UIColor.gray, for: .disabled)
      btn.backgroundColor = UIColor.white
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
      
      var box = CGRect(x: buttonSep, y: 0.0, width: buttonSize, height: buttonSize)
      for btn in digitButtons
      {
        btn.frame = box
        
        let bl = btn.layer
        
        bl.cornerRadius = 0.5*buttonSize
        bl.borderWidth = 0.0
        bl.borderColor = tint.cgColor
        bl.shadowPath = UIBezierPath(rect: btn.bounds).cgPath
        bl.shadowOpacity = 0.0
        bl.shadowOffset = CGSize(width:2.0,height:2.0)
        bl.shadowRadius = 6.0
        bl.masksToBounds = false
        
        box = box.offsetBy(dx: buttonSep + buttonSize, dy: 0.0)
      }
      
    }
    
    updateUI()
  }
  
  func resetPuzzle()
  {
    puzzle = SudokuGrid(repeating: Digits(repeating:nil, count:9), count: 9)
    gridView.clear()
    selectButton(nil)
    updateUI()
  }
  
  func updateUI()
  {
    // startButton
    
    startButton.isEnabled = false
    
    // restartButton
    
    var empty = true
    for r in 0..<9 {
      for c in 0..<9 {
        if puzzle[r][c] != nil {
          empty = false
        }
      }
    }
    restartButton.isEnabled = !empty
    
    // digitButtonsEnabled
    
    digitButtonsEnabled = gridView.selectedCell != nil
    
    // status
    
    if empty {
      statusLabel?.text = "Empty"
    }
    else {
      statusLabel?.text = "..."
    }
  }
  
  var digitButtonsEnabled = false
  {
    didSet {
      for btn in digitButtons {
        btn.isEnabled = digitButtonsEnabled
        btn.layer.borderWidth = digitButtonsEnabled ? 1.0 : 0.0
        btn.layer.shadowOpacity = digitButtonsEnabled ? 0.25 : 0.0
      }
    }
  }
  
  override func handleBackgroundTap() {
    super.handleBackgroundTap()
    selectButton(nil)
    digitButtonsEnabled = false
  }
  
  @objc func handleDigitButton(_ sender:UIButton)
  {
    if let cell = gridView.selectedCell
    {
      var digit : Digit?
      if sender.isSelected {
        selectButton(nil)
        cell.state = .empty
      }
      else
      {
        selectButton(sender.tag)
        digit = Digit(sender.tag)
        cell.state = .filled(digit!)
      }
      puzzle[cell.row!][cell.col!] = digit
    }
    gridView.findAllErrors()
    gridView.updateHighlights()
    updateUI()
  }
  
  func selectButton(_ tag:Int?)
  {
    for btn in digitButtons {
      if btn.tag == tag {
        btn.isSelected = true
        btn.backgroundColor = tint
      }
      else
      {
        btn.isSelected = false
        btn.backgroundColor = .white
      }
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
    
    selectButton( digit == nil ? nil : Int(digit!) )
    
    updateUI()
  }
  
  override func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView)
  {
    gridView.track(touch: touch)
  }
}
