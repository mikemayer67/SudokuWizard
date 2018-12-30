//
//  RandomPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/27/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class RandomPuzzleViewController: NewPuzzleViewController
{
  @IBOutlet weak var startButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func handleStart(_ sender: UIButton) {
    print("RPVC: handle start")
    handleStart()
  }
}
