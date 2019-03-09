//
//  MainViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate, SettingsViewControllerDelegate,
  SudokuWizardCellViewDelegate, EditorBackgroundViewDelegate, DigitButtonBoxDelegate, UndoManagerObserver
{
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
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    (view as? EditorBackgroundView)?.delegate = self
    
    self.navigationController?.delegate = self
    self.modalPresentationStyle = .overCurrentContext
    
    digitBox.delegate = self
    gridView.errorFeedback = .conflict
    
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
  }
  
  func handleBackgroundTap()
  {
    gridView.selectedCell = nil
    digitBox.deselectAll()
    digitBox.enabled = false
  }
  
  // MARK: - New Puzzle methods
  
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
  
  func settingsViewController(update settings: Settings)
  {
    Settings.shared = settings
    print("Settings changed -- do something with them")
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
  
  // MARK: - Button Handlers
  
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
    print("Add history logic")
  }
  
  func updateUndoState(using um: UndoManager)
  {
    updateUI()
  }
  
  @IBAction func handleActionButton(_ sender: UIButton)
  {
    let alert = UIAlertController(title:nil,
                                  message:nil,
                                  preferredStyle: .actionSheet)
    
    alert.addAction( UIAlertAction(title: "Start Over", style: .default)
    { _ in print("Restart Puzzle") })
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
  
  func sudokuWizardCellView(selected cell: SudokuWizardCellView)
  {
    gridView.selectedCell = cell
    
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
    
    updateUI()
  }
  
  func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView) {
    gridView.track(touch: touch)
  }
  
  // MARK: - Puzzle Logic
  
  func restart(with newPuzzle:SudokuWizardGridView)
  {
    guard gridView.copyPuzzle(from: newPuzzle) else { return }
  }
  
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
}

