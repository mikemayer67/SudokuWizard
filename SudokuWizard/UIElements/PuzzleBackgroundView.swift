//
//  PuzzleBackgroundView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 2/8/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

class PuzzleBackgroundView: UIView
{
  @IBOutlet weak var controller : NewPuzzleViewController!

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    controller.handleBackgroundTap()
  }
}
