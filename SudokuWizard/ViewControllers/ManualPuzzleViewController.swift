//
//  ManualPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/28/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class ManualPuzzleViewController: NewPuzzleViewController, SudokuWizardCellViewDelegate
{
  @IBOutlet weak var gridView: SudokuWizardGridView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var restartButton: UIButton!
  @IBOutlet weak var statusView: UIView!
  @IBOutlet weak var statusLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    gridView.delegateForCells = self
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let r  = statusView.frame.height/4.0
    let dl = statusView.layer
    let dp = UIBezierPath(roundedRect: statusView.bounds, cornerRadius: r)
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
    
    restartButton.layer.cornerRadius = restartButton.frame.height/2.0
    startButton.layer.cornerRadius = startButton.frame.height/2.0
    
    startButton.isHidden = true
    restartButton.isHidden = true
  }
    
  @IBAction func handleStart(_ sender: UIButton) {
    print("MPVC: handle start")
    dismiss()
  }
  
  @IBAction func handleRestart(_ sender: UIButton) {
    print("MPVC: handle restart")
  }
  
  func sudokuWizard(changeValueFor cell: SudokuWizardCellView) {
    print("MPVC: sudokup wizard change value for: \(cell)")
  }
  
  func sudokuWizard(changeMarksFor cell: SudokuWizardCellView) {}
  func sudokuWizard(selectionChangedTo cell: SudokuWizardCellView) { cell.selected = false }
}
