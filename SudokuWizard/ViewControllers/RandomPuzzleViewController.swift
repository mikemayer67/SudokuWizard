//
//  RandomPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/27/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class RandomPuzzleViewController: NewPuzzleViewController, SudokuWizardCellViewDelegate
{
  @IBOutlet weak var gridView: SudokuWizardGridView!
  @IBOutlet weak var regenButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var difficultyView: UIView!
  @IBOutlet weak var difficultyLabel: UILabel!
  
  let genQueue = DispatchQueue(label: "RandomPuzzleGenerator")
  
  override func awakeFromNib() {
    super.awakeFromNib()
    gridView.delegateForCells = self
    
    startButton.setTitleColor(UIColor.gray, for: .disabled)
    regenButton.setTitleColor(UIColor.gray, for: .disabled)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let r  = difficultyView.frame.height/4.0
    let dl = difficultyView.layer
    let dp = UIBezierPath(roundedRect: difficultyView.bounds, cornerRadius: r)
    dl.cornerRadius = r
    dl.shadowPath = dp.cgPath
    dl.shadowColor = UIColor.black.cgColor
    dl.shadowOpacity = 0.5
    dl.shadowOffset = CGSize(width:3.0,height:3.0)
    dl.shadowRadius = 5.0
    dl.masksToBounds = false
    
    let gl = gridView.layer
    gl.shadowPath = UIBezierPath(rect: gridView.bounds).cgPath
    gl.shadowColor = UIColor.black.cgColor
    gl.shadowOpacity = 0.5
    gl.shadowOffset = CGSize(width:3.0,height:3.0)
    gl.shadowRadius = 5.0
    gl.masksToBounds = false
    
    regenButton.layer.cornerRadius = regenButton.frame.height/2.0
    startButton.layer.cornerRadius = startButton.frame.height/2.0
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    generate()
  }
  
  @IBAction func handleRegen(_ sender: UIButton)
  {
    generate()
  }
  
  @IBAction func handleStart(_ sender: UIButton)
  {
    dismiss()
  }
  
  // MARK: - Random puzzle
  
  func generate()
  {
    gridView.clear()
    regenButton.isEnabled = false
    startButton.isEnabled = false
    difficultyLabel.text = ""
    
    var flashErr = true
    var flashIndex = Int.random(in: 0...80)
    let timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
      DispatchQueue.main.async {
        if flashErr { self.gridView.cellViews[flashIndex].errant = false }
        else        { self.gridView.cellViews[flashIndex].highlighted = false }
        flashErr = Int.random(in:0...1) == 0
        flashIndex = Int.random(in:0...80)
          
        if flashErr { self.gridView.cellViews[flashIndex].errant = true }
        else        { self.gridView.cellViews[flashIndex].highlighted = true }
      }
    }
    
    genQueue.async {
      let rs = RandomSudoku()
      
      DispatchQueue.main.async {
        do {
          try self.gridView.loadPuzzle(rs.puzzle, solution: rs.solution)
          self.gridView.state = .Viewable
          self.difficultyLabel.text = String(format:"%d",rs.difficulty)
        }
        catch {
          fatalError("Should never get here \(#file):\(#line)")
        }
        timer.invalidate()
        self.regenButton.isEnabled = true
        self.startButton.isEnabled = true
        self.dirty = true
        if flashErr { self.gridView.cellViews[flashIndex].errant = false }
        else        { self.gridView.cellViews[flashIndex].highlighted = false }
      }
    }
    

  }
  
  // MARK: - Grid Delegate methods
  
  func sudokuWizard(changeValueFor     cell: SudokuWizardCellView) {}
  func sudokuWizard(changeMarksFor     cell: SudokuWizardCellView) {}
  func sudokuWizard(selectionChangedTo cell: SudokuWizardCellView) { cell.selected = false }
}
