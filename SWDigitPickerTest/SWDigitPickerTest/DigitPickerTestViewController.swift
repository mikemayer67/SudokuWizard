//
//  ViewController.swift
//  SWDigitPickerTest
//
//  Created by Mike Mayer on 1/26/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

class DigitPickerTestViewController: UIViewController, SudokuWizardCellViewDelegate
{
  @IBOutlet weak var gridView: SudokuWizardGridView!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var unlockButton: UIButton!
  @IBOutlet weak var lockButton: UIButton!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    gridView.delegateForCells = self
    // Do any additional setup after loading the view, typically from a nib.
  }

  @IBAction func handleReset(_ sender: UIButton) {
    gridView.clear()
  }
  
  @IBAction func handleUnlock(_ sender: UIButton)
  {
    for c in gridView.cellViews {
      switch c.state {
      case .locked(let d): c.state = .filled(d)
      default: break
      }
    }
  }
  
  @IBAction func handleLock(_ sender: UIButton) {
    for c in gridView.cellViews {
      switch c.state {
      case .filled(let d): c.state = .locked(d)
      default: break
      }
    }
  }
  
  func sudokuWizard(changeValueFor cell: SudokuWizardCellView)
  {
    print("changeValueFor: \(cell)")
  }
  
  func sudokuWizard(changeMarksFor cell: SudokuWizardCellView) {}
  
  func sudokuWizard(selectionChangedTo cell: SudokuWizardCellView)
  {
    cell.selected = false
  }
}

