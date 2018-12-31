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
    self.navigationController?.delegate = self
    self.modalPresentationStyle = .overCurrentContext
    
    newPuzzleBackgroundAlpha = newPuzzleBackgroundView.alpha
    enterButtonOffset  = enterButtonBottomConstraint.constant
    randomButtonOffset = randomButtonBottomConstraint.constant
    scanButtonOffset   = scanButtonBottomConstraint.constant
    
    enterPuzzleButton.layer.cornerRadius = enterPuzzleButton.frame.height/2.0
    randomPuzzleButton.layer.cornerRadius = randomPuzzleButton.frame.height/2.0
    scanPuzzleButton.layer.cornerRadius = scanPuzzleButton.frame.height/2.0
    
    hideNewPuzzleInput()
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
  
  // MARK: - Navigation Controller Delegate Methods
  
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
  
  // MARK: - New Puzzle outlets
  
  @IBOutlet weak var newPuzzleButton: UIBarButtonItem!
  @IBOutlet weak var puzzleSettingsButton: UIBarButtonItem!
  
  
  @IBOutlet weak var newPuzzleBackgroundView: UIView!
  @IBOutlet weak var enterPuzzleButton: UIButton!
  @IBOutlet weak var randomPuzzleButton: UIButton!
  @IBOutlet weak var scanPuzzleButton: UIButton!
  @IBOutlet weak var cancelNewPuzzleButton: UIButton!
  
  @IBOutlet weak var scanButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var randomButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var enterButtonBottomConstraint: NSLayoutConstraint!
  
   // MARK: - New Puzzle properties
  
  var newPuzzleBackgroundAlpha : CGFloat!
  var enterButtonOffset : CGFloat!
  var randomButtonOffset : CGFloat!
  var scanButtonOffset : CGFloat!
  
  // MARK: - New Puzzle methods
  
  func hideNewPuzzleInput()
  {
    newPuzzleBackgroundView.isHidden = true
    enterPuzzleButton.isHidden = true
    randomPuzzleButton.isHidden = true
    scanPuzzleButton.isHidden = true
    cancelNewPuzzleButton.isHidden = true
    
    newPuzzleBackgroundView.alpha = 0.0
    enterPuzzleButton.alpha = 1.0
    randomPuzzleButton.alpha = 1.0
    scanPuzzleButton.alpha = 1.0
    cancelNewPuzzleButton.alpha = 0.0
    
    scanButtonBottomConstraint.constant = scanPuzzleButton.frame.height
    randomButtonBottomConstraint.constant = 0.0
    enterButtonBottomConstraint.constant = 0.0
    
    newPuzzleButton.isEnabled = true
    puzzleSettingsButton.isEnabled = true
  }
  
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
    newPuzzleButton.isEnabled = false
    puzzleSettingsButton.isEnabled = false
    
    newPuzzleBackgroundView.isHidden = false
    enterPuzzleButton.isHidden = false
    randomPuzzleButton.isHidden = false
    scanPuzzleButton.isHidden = false
    
    if !required {
      cancelNewPuzzleButton.isHidden = false
    }
    
    view.layoutIfNeeded()
    
    UIView.animateKeyframes(withDuration: 0.35, delay: 0.0, options: .calculationModeLinear, animations: {
      self.scanButtonBottomConstraint.constant = self.scanButtonOffset
      self.randomButtonBottomConstraint.constant = self.randomButtonOffset
      self.enterButtonBottomConstraint.constant = self.enterButtonOffset
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
        self.newPuzzleBackgroundView.alpha = self.newPuzzleBackgroundAlpha
      })
      if !required {
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
          self.cancelNewPuzzleButton.alpha = 1.0
        } )
      }
      self.view.layoutIfNeeded()
    })
  }
  
  @IBAction func handlePuzzleSelection(_ sender: UIButton)
  {
    UIView.animate(withDuration: 0.35, animations: {
      self.newPuzzleBackgroundView.alpha = 0.0
      self.enterPuzzleButton.alpha = 0.0
      self.randomPuzzleButton.alpha = 0.0
      self.scanPuzzleButton.alpha = 0.0
      self.cancelNewPuzzleButton.alpha = 0.0
    }) { (_) in
      self.hideNewPuzzleInput()
      
      switch sender {
      case self.enterPuzzleButton:
        self.performSegue(withIdentifier: "showNewPuzzle", sender: self)
      case self.randomPuzzleButton:
        self.performSegue(withIdentifier: "showRandomPuzzle", sender: self)
      case self.scanPuzzleButton:
        self.performSegue(withIdentifier: "showScanPuzzle", sender: self)
      default:
        break
      }
    }
  }
}

