//
//  NewPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/27/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class NewPuzzleViewController: UIViewController
{
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  @IBAction func handleCancel(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
}
