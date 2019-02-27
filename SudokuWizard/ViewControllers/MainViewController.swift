//
//  MainViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate, SettingsViewControllerDelegate, SudokuWizardCellViewDelegate
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
    
    self.navigationController?.delegate = self
    self.modalPresentationStyle = .overCurrentContext
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    gridView.cellDelegate = self
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    print("Put this into an if condition once loading old puzzles is implemented: ",#file,":",#line)
    updateUI()
    startNewPuzzle(required:false)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let dest = segue.destination as? SettingsViewController
    {
      dest.delegate = self
    }
    else
    {
      print("Prepare to segue to: ",segue.destination)
    }
  }
  
  // MARK: - UI State Machine
  
  private var entryTool = UserEntryTool.pen
  {
    didSet {
      updateUI()
    }
  }
  
  func updateUI()
  {
    undoButton.isEnabled = false
    histButton.isEnabled = false
    redoButton.isEnabled = false
    
    actionMenuButton.isEnabled = true
    
    penButton.inverted    = entryTool == .pen
    pencilButton.inverted = entryTool == .pencil
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
    if gridView?.state == .Populated
    {
      let alert = UIAlertController(title:"Discard Puzzle",
                                    message:"Replace active puzzle with new puzzle",
                                    preferredStyle:.alert)
      alert.addAction( UIAlertAction(title: "OK", style:.destructive) { _ in self.startNewPuzzle() } )
      alert.addAction( UIAlertAction(title:"Cancel", style:.cancel) )
      
      self.present(alert,animated: true)
    }
    else
    {
      startNewPuzzle()
    }
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
    print("Add handleUndoButton logic")
  }
  
  @IBAction func handleRedoButton(_ sender: UIButton)
  {
    print("Add handleRedoButton logic")
  }
  
  @IBAction func handleHistoryButton(_ sender: UIButton)
  {    print("Add handleHistoryutton logic")

  }
  
  @IBAction func handleActionButton(_ sender: UIButton)
  {
    print("Add handleActionButton logic")
  }
  
  @IBAction func handlePencilButton(_ sender: UIButton)
  {
    if entryMode == .digits { entryMode = .marks }
  }
  
  @IBAction func handlePenButton(_ sender: UIButton)
  {
    if entryMode == .marks { entryMode = .digits }
  }
  
  func sudokuWizardCellView(selected cell: SudokuWizardCellView)
  {
    gridView.selectedCell = cell
    print("complete sudokuWizardCellView(selected cell: SudokuWizardCellView)")
    
//    var digit : Digit?
//
//    switch cell.state {
//    case .locked(let d): digit = d
//    case .filled(let d): digit = d
//    case .empty: digit = nil
//    }
//    
//    digitBox.select(digit: digit)
//    updateUI()
  }
  
  func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView) {
    gridView.track(touch: touch)
  }
}

