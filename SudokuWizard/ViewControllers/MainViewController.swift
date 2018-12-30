//
//  MainViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate, SettingsViewControllerDelegate
{
  var puzzle : SudokuWizardGridView? = nil
  
  enum NewPuzzleMethod
  {
    case manual
    case random
    case scan
  }
  
  override func awakeFromNib() {
    if let bg = UIImage(named:"SudokuBackground") {
      view.backgroundColor = UIColor(patternImage: bg)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    self.navigationController?.delegate = self
    self.modalPresentationStyle = .overCurrentContext
  }
  
  var firstappear = true
  override func viewDidAppear(_ animated: Bool)
  {
    print("Put this into an if condition once loading old puzzles is implemented: ",#file,":",#line)
    if firstappear { startNewPuzzle(required:true) }
    firstappear = false
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

  // Mark: - Navigation Controller Delegate Methods
  
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

  // Mark: - New Puzzle
  
  @IBAction func handleNewPuzzle(_ sender: UIBarButtonItem)
  {
    if puzzle?.state == .Active
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
    let selection = UIAlertController(title:"New Puzzle",
                                      message:"How would you like to start the puzzle",
                                      preferredStyle:.actionSheet)
    
    selection.addAction( UIAlertAction(title:"manual",style:.default) { _ in
      self.performSegue(withIdentifier: "showNewPuzzle", sender: self)
    } )
    selection.addAction( UIAlertAction(title:"random",style:.default) { _ in
      self.performSegue(withIdentifier: "showRandomPuzzle", sender: self)
    } )
    selection.addAction( UIAlertAction(title:"scanned",style:.default) { _ in
      self.performSegue(withIdentifier: "showScanPuzzle", sender: self)
    } )
    
    if !required { selection.addAction( UIAlertAction(title:"cancel",style:.cancel) ) }
    
    self.present(selection,animated: true)
  }
  
  
  
}
