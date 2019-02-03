//
//  BackgroundView.swift
//  SWCellViewTest
//
//  Created by Mike Mayer on 1/31/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

class BackgroundView: UIView
{
  @IBOutlet weak var cellView : SudokuWizardCellView!
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    cellView.selected = false
  }
}
