//
//  TransparentBackgroundView.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 3/9/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import UIKit

class TransparentBackgroundView: UIView
{
  override func awakeFromNib() {
    backgroundColor = UIColor.init(white: 1.0, alpha: 0.0)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // here simply to block touches from passing through to stuff behind it
  }
}
