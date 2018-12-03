//
//  Extensions.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/2/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

extension String {
  subscript (i: Int) -> Character {
    return self[index(startIndex, offsetBy: i)]
  }
}
