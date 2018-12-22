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

class GridTestViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SudokuWizardCellViewDelegate
{
  @IBOutlet weak var dataPickerView: UIPickerView!
  @IBOutlet weak var sudokuGrid: SudokuWizardGridView!
  @IBOutlet weak var valueSegmentedControl: UISegmentedControl!
  @IBOutlet weak var marksLabel: UILabel!
  @IBOutlet weak var markStyleControl: UISegmentedControl!
  @IBOutlet weak var autoMarkControl: UISegmentedControl!
  @IBOutlet weak var conflictsButton: UIButton!
  
  var markButtons = [UIButton]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    puzzleKeys = puzzleData.keys.sorted()
    dataPickerView.selectRow(0, inComponent: 0, animated: true)
    markStyleControl.selectedSegmentIndex = 0
    autoMarkControl.selectedSegmentIndex = 1
    
    var last : UIButton!
    for i in 1...9
    {
      let btn = UIButton(type:.system)
      
      btn.setAttributedTitle(NSAttributedString(string: i.description,
                                                attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)]),
                             for: .normal)
      
      markButtons.append(btn)
      view.addSubview(btn)
      
      btn.translatesAutoresizingMaskIntoConstraints = false
      btn.centerYAnchor.constraint(equalTo: marksLabel.centerYAnchor).isActive = true
      btn.tag = i
      switch i {
      case 1:
        btn.leftAnchor.constraint(equalTo: valueSegmentedControl.leftAnchor).isActive = true
      case 9:
        btn.rightAnchor.constraint(equalTo: valueSegmentedControl.rightAnchor).isActive = true
        fallthrough
      default:
        btn.leftAnchor.constraint(equalTo: last.rightAnchor).isActive = true
        btn.widthAnchor.constraint(equalTo: last.widthAnchor, multiplier: 1.0).isActive = true
      }
      
      btn.addTarget(self, action: #selector(handleMarkButton(_:)), for: .touchUpInside)
      
      last = btn
      
      conflictsButton.isSelected = sudokuGrid.errorFeedback == .conflict
    }
    
    sudokuGrid.cellViews.forEach { cell in cell.delegate = self }
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
    
    valueSegmentedControl.selectedSegmentIndex = 0
    markButtons.forEach { $0.isSelected = false }
    
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
  
  // MARK: -
  
  func sudokuWizard(changeValueFor cell: SudokuWizardCellView) {
    guard sudokuGrid.state == .Active else { return }
    print("Popup value picker")
  }
  
  func sudokuWizard(changeMarksFor cell: SudokuWizardCellView) {
    guard sudokuGrid.state == .Active else { return }
    print("Popup marks picker")
  }
  
  func sudokuWizard(selectionChangedTo cell: SudokuWizardCellView)
  {
    sudokuGrid.selectedCell = cell
    
    if let cell = sudokuGrid.selectedCell
    {
      switch cell.state
      {
      case .empty:
        for d in 1...9 { markButtons[d-1].isSelected = cell.hasMark(d) }
        valueSegmentedControl.selectedSegmentIndex = 0
      case let .filled(v):
        for d in 1...9 { markButtons[d-1].isSelected = false }
        valueSegmentedControl.selectedSegmentIndex = v
      case let .locked(v):
        for d in 1...9 { markButtons[d-1].isSelected = false }
        valueSegmentedControl.selectedSegmentIndex = v
      }
    }
  }
  
  @IBAction func handleValueControl(_ sender: UISegmentedControl)
  {
    let d = sender.selectedSegmentIndex
    if let cell = sudokuGrid.selectedCell
    {
      switch (cell.state,d)
      {
      case (.empty,0):
        for m in 1...9 { markButtons[m-1].isSelected = cell.hasMark(m) }
      case (.empty,_):
        cell.state = .filled(d)
        for m in 1...9 { markButtons[m-1].isSelected = false }
        sudokuGrid.handleValueChange(for:cell)
      case (.filled(_),0):
        cell.state = .empty
        for m in 1...9 { markButtons[m-1].isSelected = cell.hasMark(m) }
        sudokuGrid.handleValueChange(for:cell)
      case (.filled(_), _):
        cell.state = .filled(d)
        sudokuGrid.handleValueChange(for:cell)
      case let (.locked(v),_):
        sender.selectedSegmentIndex = v
      }
    }
  }
  
  @objc func handleMarkButton(_ sender:UIButton)
  {
    let d = sender.tag
    
    if let cell = sudokuGrid.selectedCell
    {
      switch (cell.state,cell.hasMark(d))
      {
      case (.empty,true):
        cell.clear(mark: d)
        sender.isSelected = false
      case (.empty,false):
        cell.set(mark:d)
        sender.isSelected = true
      default:
        break;
      }
    }
  }
  
  @IBAction func handleConflicts(_ sender: UIButton)
  {
    sender.isSelected = !sender.isSelected
    sudokuGrid.errorFeedback = ( sender.isSelected ? .conflict : .none )
  }
  
  @IBAction func handleMarkStyle(_ sender: UISegmentedControl)
  {
    sudokuGrid.markStyle =  sender.selectedSegmentIndex == 0 ? .digits : .dots
  }
  
  @IBAction func handleAutoMarkControl(_ sender: UISegmentedControl)
  {
    switch sender.selectedSegmentIndex
    {
    case 0: // erase
      sudokuGrid.markStrategy = .manual
      sudokuGrid.clearAllMarks()
      markButtons.forEach { btn in btn.isEnabled = true }
      Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) {_ in sender.selectedSegmentIndex = 1 }
    case 1: // manual
      sudokuGrid.markStrategy = .manual
      markButtons.forEach { btn in btn.isEnabled = true }
    case 2: // allowed
      sudokuGrid.markStrategy = .allowed
      markButtons.forEach { btn in btn.isEnabled = false }
    case 3: // conflicted
      sudokuGrid.markStrategy = .conflicted
      markButtons.forEach { btn in btn.isEnabled = false }
    default:
      break
    }
    
    if let cell = sudokuGrid.selectedCell {
      if case .empty = cell.state {
        for m in 1...9 { markButtons[m-1].isSelected = cell.hasMark(m) }
      } else {
        for m in 1...9 { markButtons[m-1].isSelected = false }
      }
    }
  }
  
}

