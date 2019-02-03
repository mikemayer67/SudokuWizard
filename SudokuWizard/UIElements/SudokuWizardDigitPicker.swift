//
//  SudokuWizardDigitPicker.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 1/26/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

class SudokuWizardDigitPicker: UIView
{
  enum Selection
  {
    case digit(Digit)
    case clear
    case dismiss
  }
  
  func displayOver(cell:SudokuWizardCellView)
  {
    print("display")
  }
  
  func handleTouch(touch:UITouch)
  {
    print("handleTouch")
  }
  
  func dismiss(touch:UITouch) -> Selection
  {
    var rval = Selection.dismiss
    
    return rval
  }
}
