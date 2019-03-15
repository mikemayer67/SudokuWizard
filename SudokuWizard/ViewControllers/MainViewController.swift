//
//  MainViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate
{
  // MARK: - Outlets
  
  @IBOutlet weak var undoButton: IconButton!
  @IBOutlet weak var histButton: IconButton!
  @IBOutlet weak var redoButton: IconButton!
  @IBOutlet weak var actionMenuButton: IconButton!
  @IBOutlet weak var pencilButton: IconButton!
  @IBOutlet weak var penButton: IconButton!
  
  @IBOutlet weak var gridView: SudokuWizardGridView!
  @IBOutlet weak var digitBox: DigitButtonBox!
  
  @IBOutlet weak var newPuzzleButton: UIBarButtonItem!
  @IBOutlet weak var puzzleSettingsButton: UIBarButtonItem!
  
  @IBOutlet weak var undoPickerView: UIView!
  @IBOutlet weak var undoPicker: UIPickerView!
  
  // MARK: - Enums and Typedefs
  
  enum NewPuzzleMethod
  {
    case manual
    case random
    case scan
  }
  
  enum UserEntryTool
  {
    case pencil
    case pen
  }
  
  // MARK: - View overrides
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    (view as? EditorBackgroundView)?.delegate = self
    
    self.navigationController?.delegate = self
    self.modalPresentationStyle = .overCurrentContext
    
    digitBox.delegate = self
    gridView.errorFeedback = .conflict
    undoPickerView.isHidden = true
    
    UndoManager.shared.add(observer: self)
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    gridView.cellDelegate = self
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    updateUI()
    
    if gridView.isEmpty { startNewPuzzle(required:true) }
  }
  
  // MARK: - UI State Machine
  
  private var entryTool = UserEntryTool.pen { didSet { updateUI() } }
  
  func updateUI()
  {
    let um = UndoManager.shared
    undoButton.isEnabled = um.hasUndo
    histButton.isEnabled = um.hasUndo || um.hasRedo
    redoButton.isEnabled = um.hasRedo
    
    actionMenuButton.isEnabled = true
    
    penButton.inverted    = entryTool == .pencil
    pencilButton.inverted = entryTool == .pen
    
    updateDigitBox()
  }
  
  // MARK: - Button Handlers
  
  @IBAction func handleActionButton(_ sender: UIButton)
  {
    let alert = UIAlertController(title:nil,
                                  message:nil,
                                  preferredStyle: .actionSheet)
    
    alert.addAction( UIAlertAction(title: "Start Over", style: .default)
    { _ in
      let action = ResetPuzzle(grid: self.gridView)
      UndoManager.shared.add(action)
    })

    alert.addAction( UIAlertAction(title: "Erase All Marks", style:.default)
    { _ in print( "Clear All Marks" ) })
    alert.addAction( UIAlertAction(title: "Compute All Marks", style:.default)
    { _ in print( "Compute All Marks" ) })
    alert.addAction( UIAlertAction(title:"Cancel", style:.cancel) )
    
    self.present(alert,animated:true)
  }
  
  @IBAction func handlePencilButton(_ sender: UIButton)
  {
    if entryTool == .pen { entryTool = .pencil }
  }
  
  @IBAction func handlePenButton(_ sender: UIButton)
  {
    if entryTool == .pencil { entryTool = .pen }
  }
}

// MARK: - Segues

extension MainViewController
{
  func navigationController(_ navigationController: UINavigationController,
                            animationControllerFor operation: UINavigationController.Operation,
                            from fromVC: UIViewController,
                            to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning?
  {
    if toVC is SettingsViewController  { return SettingsTransition(operation) }
    if fromVC is SettingsViewController  { return SettingsTransition(operation) }
    if toVC is NewPuzzleViewController { return NewPuzzleTransition(operation) }
    if fromVC is NewPuzzleViewController { return NewPuzzleTransition(operation) }
    return nil
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let dest = segue.destination as? SettingsViewController {
      dest.delegate = self
    } else if let dest = segue.destination as? NewPuzzleViewController {
      dest.puzzleController = self
    }  else {
      fatalError("Unknown segue destinatin: \(segue.destination)")
    }
  }
  
  @IBAction func handleNewPuzzle(_ sender: UIBarButtonItem)
  {
    startNewPuzzle()
  }
  
  func startNewPuzzle(required:Bool=false)
  {
    let alert = UIAlertController(title:"New Puzzle",
                                  message:"How would you like to start the new puzzle",
                                  preferredStyle:.alert)
    
    alert.addAction( UIAlertAction(title: "Enter It by Hand", style:.default)
    { _ in self.performSegue(withIdentifier: "showNewPuzzle", sender: self) } )
    alert.addAction( UIAlertAction(title: "Randomly Generated", style:.default)
    { _ in self.performSegue(withIdentifier: "showRandomPuzzle", sender: self) } )
    alert.addAction( UIAlertAction(title: "Captured with Camera", style:.default)
    { _ in self.performSegue(withIdentifier: "showScanPuzzle", sender: self) } )
    
    if !required {
      alert.addAction( UIAlertAction(title:"Cancel", style:.cancel) )
    }
    
    self.present(alert,animated: true)
  }
  
  func restart(with newPuzzle:SudokuWizardGridView)
  {
    guard gridView.copyPuzzle(from: newPuzzle) else { return }
  }
}

// MARK: - SudokuWizard CellViews

extension MainViewController : SudokuWizardCellViewDelegate
{
  func sudokuWizardCellView(selected cell: SudokuWizardCellView)
  {
    gridView.selectedCell = cell
    updateUI()
  }
  
  func selectCell(_ cell:SudokuWizardCellView?)
  {
    gridView.selectedCell = cell
    

  }
  
  func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView) {
    gridView.track(touch: touch)
  }
}

// MARK: - Background View

extension MainViewController : EditorBackgroundViewDelegate
{
  func handleBackgroundTap()
  {
    gridView.selectedCell = nil
    updateUI()
  }
}

// MARK: - Digit Box

extension MainViewController : DigitButtonBoxDelegate
{
  func digitButtonBox(selected digit: Digit)
  {
    guard let c = gridView.selectedCell else { return }
    
    let action = ChangeDigit(grid: gridView, cell: c, digit: digit)
    UndoManager.shared.add(action)
  }
  
  func digitButtonBox(unselected digit: Digit)
  {
    guard let c = gridView.selectedCell else { return }
    
    let action = ChangeDigit(grid: gridView, cell: c, digit: nil)
    UndoManager.shared.add(action)
  }
  
  func updateDigitBox()
  {
    if let cell = gridView.selectedCell {
      switch cell.state {
      case .locked(_):
        digitBox.enabled = false
      case .filled(let d):
        digitBox.enabled = true
        digitBox.select(digit: d)
      case .empty:
        digitBox.enabled = true
        digitBox.select(digit: nil)
      }
    }
    else
    {
      digitBox.deselectAll()
      digitBox.enabled = false
    }
  }
}

// MARK: - Undo Manager

extension MainViewController : UndoManagerObserver, UIPickerViewDelegate, UIPickerViewDataSource
{
  @IBAction func handleUndoButton(_ sender: UIButton)
  {
    UndoManager.shared.undo()
  }
  
  @IBAction func handleRedoButton(_ sender: UIButton)
  {
    UndoManager.shared.redo()
  }
  
  @IBAction func handleHistoryButton(_ sender: UIButton)
  {
    let hist = UndoManager.shared.history()
    let redoCount = hist.redo?.count ?? 0
    let undoCount = hist.undo?.count ?? 0
    
    let bgView = undoPicker.superview
    if let bgLayer = bgView?.layer
    {
      bgLayer.shadowPath = UIBezierPath(rect: bgLayer.bounds).cgPath
      bgLayer.shadowColor = UIColor.black.cgColor
      bgLayer.shadowRadius = 5.0
      bgLayer.shadowOpacity = 0.5
      bgLayer.masksToBounds = false
    }

    let curRow = undoCount > 0 ? redoCount : redoCount - 1
    undoPicker.reloadAllComponents()
    undoPicker.selectRow(curRow, inComponent: 0, animated: false)

    bgView?.alpha = 0.0
    undoPickerView.isHidden = false
    UIView.animate(withDuration: 0.2) { bgView?.alpha = 1.0 }
  }
  
  @IBAction func handlePickerOK(_ sender:UIButton)
  {
    let row = undoPicker.selectedRow(inComponent: 0)
    
    let um = UndoManager.shared
    let hist = um.history()
    let redoCount = hist.redo?.count ?? 0
    
    if row < redoCount
    {
      for _ in 0..<(redoCount - row) { um.redo() }
    }
    else
    {
      for _ in 0...(row-redoCount) { um.undo() }
    }
    
    hidePickerView()
  }
  
  @IBAction func handlePickerCancel(_ sender:UIButton)
  {
    hidePickerView()
  }
  
  func updateUndoState(using um: UndoManager)
  {
    updateUI()
  }
  
  func hidePickerView()
  {
    let bgView = undoPicker.superview
    UIView.animate(withDuration: 0.2,
                   animations:{ bgView?.alpha = 0.0 },
                   completion:{ _ in bgView?.alpha = 1.0; self.undoPickerView.isHidden = true }
    )
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    let hist = UndoManager.shared.history()
    let undoCount = hist.undo?.count ?? 0
    let redoCount = hist.redo?.count ?? 0
    let numRows = undoCount + redoCount
    return numRows
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
  {
    let hist = UndoManager.shared.history()
    let redoCount = hist.redo?.count ?? 0
    let undoCount = hist.undo?.count ?? 0
    
    var pickerLabel: UILabel? = (view as? UILabel)
    if pickerLabel == nil {
      pickerLabel = UILabel()
//      pickerLabel?.font = UIFont(name: "<Your Font Name>", size: <Font Size>)
      pickerLabel?.textAlignment = .center
    }
    
    pickerLabel?.text = ""
    
    if row < redoCount
    {
      let text = hist.redo![row]
      pickerLabel?.text = "Redo \(text)"
      pickerLabel?.textColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    }
    else if row >= redoCount
    {
      let undoIndex = row - redoCount
      let text = hist.undo![undoCount - 1 - undoIndex]
      pickerLabel?.text = "Undo \(text)"
      pickerLabel?.textColor = UIColor.blue
    }
    
    return pickerLabel!
  }
}


// MARK: - Settings

extension MainViewController : SettingsViewControllerDelegate
{
  func settingsViewController(update settings: Settings)
  {
    Settings.shared = settings
    print("Settings changed -- do something with them")
  }
}
