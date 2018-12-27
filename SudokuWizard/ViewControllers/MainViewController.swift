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
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    self.navigationController?.delegate = self
    self.modalPresentationStyle = .overCurrentContext
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    print("Put this into an if condition once loading old puzzles is implemented: ",#file,":",#line)
    startNewPuzzle(required:true)
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
    return SettingsTransition(operation)
  }
  
  func settingsViewController(update settings: Settings)
  {
    Settings.shared = settings
    print("Settings changed")
  }

  // Mark: - New Puzzle
  
  @IBAction func handleNewPuzzle(_ sender: UIBarButtonItem)
  {
    startNewPuzzle(required:false)
  }
  
  func startNewPuzzle(required:Bool)
  {
    let newPuzzleSelection = {
      let selection = UIAlertController(title:"New Puzzle",
                                        message:"How would you like to start the puzzle",
                                        preferredStyle:.actionSheet)
      selection.addAction( UIAlertAction(title:"manual",style:.default) { _ in self.startNewPuzzle(.manual) } )
      selection.addAction( UIAlertAction(title:"random",style:.default) { _ in self.startNewPuzzle(.random) } )
      selection.addAction( UIAlertAction(title:"scanned",style:.default) { _ in self.startNewPuzzle(.scan) } )
      if required == false
      {
        selection.addAction(UIAlertAction(title:"cancel",style:.cancel))
      }
      self.present(selection,animated: true)
    }
    
    if puzzle?.state == .Active  // Fix this
    {
      let alert = UIAlertController(title:"Discard Puzzle",
                                    message:"Replace active puzzle with new puzzle",
                                    preferredStyle:.alert)
      alert.addAction( UIAlertAction(title: "OK", style:.destructive) { _ in
        newPuzzleSelection()
      } )
      alert.addAction( UIAlertAction(title:"Cancel", style:.cancel) )
      
      self.present(alert,animated: true)
    }
    else
    {
      newPuzzleSelection()
    }
  }
  
  func startNewPuzzle(_ method:NewPuzzleMethod)
  {
    print("startNewPuzzle:",method)
  }
  
}
