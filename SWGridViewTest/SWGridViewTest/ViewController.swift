//
//  ViewController.swift
//  SWGridViewTest
//
//  Created by Mike Mayer on 11/30/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

let puzzleData : [String:String] =
  [ "demo1" : "..3..4..51..2..9...6..7..8..3..4..51..2..9...6..7..8..3..4..51..2..9...6..7..8...",
    "demo2" : "1........2........3........4........5........6........7........8........9........",
    "demo3" : "1.........2.........3.........4.........5.........6.........7.........8.........9",
    "err 1" : "1......2........3........4........5........6........7........8........9........",
    "err 2" : "1......2........3........4........5........6........7........8........9........12345",
    "err 3" : "1........2........3........4........5........6........7........8........Q........" ]

var puzzleKeys = [String]()
var firstSelectionMade = false

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
  @IBOutlet weak var dataPickerView: UIPickerView!
  @IBOutlet weak var sudokuGrid: SudokuWizardGridView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    puzzleKeys = puzzleData.keys.sorted()
    dataPickerView.selectRow(0, inComponent: 0, animated: true)
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return puzzleKeys.count + ( firstSelectionMade ? 0 : 1 )
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
  {
    if firstSelectionMade==false {
      if row == 0 { return "Select Puzzle Data" }
      return puzzleKeys[row-1]
    }
    return puzzleKeys[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    var key = puzzleKeys[row]
    
    if firstSelectionMade == false {
      if row > 0 {
        firstSelectionMade = true
        dataPickerView.reloadAllComponents()
        dataPickerView.selectRow(row-1, inComponent: 0, animated: false)
        key = puzzleKeys[row-1]
      }
    }
    
    let puzzle = puzzleData[key]!

    do
    {
      try sudokuGrid.loadPuzzle(puzzle)
    }
    catch SudokuWizardError.InvalidPuzzle(let errMessage)
    {
      let alert = UIAlertController(title: "Invalid Puzzle", message: errMessage, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
      self.present(alert, animated: true, completion: nil)
      sudokuGrid.clear()
    }
    catch
    {
      sudokuGrid.clear()
    }
  }
}

