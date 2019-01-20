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
  
  override func awakeFromNib() {
    super.awakeFromNib()
    gridView.delegateForCells = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
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
    let rs = RandomSudoku()
    
    do {
      try gridView.loadPuzzle(rs.puzzle, solution: rs.solution)
      difficultyLabel.text = String(format:"%d / %d",rs.difficulty, rs.complexity)
    }
    catch {
      fatalError("Should never get here \(#file):\(#line)")
    }
  }
  
  // MARK: - Grid Delegate methods
  
  func sudokuWizard(changeValueFor     cell: SudokuWizardCellView) {}
  func sudokuWizard(changeMarksFor     cell: SudokuWizardCellView) {}
  func sudokuWizard(selectionChangedTo cell: SudokuWizardCellView) { cell.selected = false }
}
