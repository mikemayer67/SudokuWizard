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
  @IBOutlet weak var startButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startButton.isHidden = true
  }
    
  @IBAction func handleStart(_ sender: UIButton) {
    print("MPVC: handle start")
    dismiss()
  }
  
}
