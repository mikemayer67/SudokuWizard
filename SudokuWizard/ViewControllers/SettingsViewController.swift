//
//  SettingsViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/17/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate
{
  func settingsViewController(update settings:Settings)
}

class SettingsViewController: UITableViewController
{
  @IBOutlet weak var updateButtonItem: UIBarButtonItem!
  @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
  @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var autoMarkSwitch: UISwitch!
  @IBOutlet weak var autoMarkPolicy: UISegmentedControl!
  @IBOutlet weak var incorrectEntrySwitch: UISwitch!
  @IBOutlet weak var conflictedEntrySwitch: UISwitch!
  
  var settings = Settings()
  var delegate : SettingsViewControllerDelegate?
  
  @IBAction func handleButtonItem(_ sender: UIBarButtonItem)
  {
    if sender == updateButtonItem
    {
      delegate?.settingsViewController(update: settings)
    }
    self.navigationController?.popViewController(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print ("SVC: viewDidLoad")
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    switch settings.markStyle
    {
    case .digits:
      styleSegmentedControl.selectedSegmentIndex = 0
    case .dots:
      styleSegmentedControl.selectedSegmentIndex = 1
    }
    
    switch settings.markStrategy
    {
    case .manual:
      autoMarkSwitch.isOn = false
      autoMarkPolicy.isEnabled = false
    case .allowed:
      autoMarkSwitch.isOn = true
      autoMarkPolicy.isEnabled = true
      autoMarkPolicy.selectedSegmentIndex = 0
    case .conflicted:
      autoMarkSwitch.isOn = true
      autoMarkPolicy.isEnabled = true
      autoMarkPolicy.selectedSegmentIndex = 1
    }
    
    switch settings.errorFeedback
    {
    case .conflict:
      incorrectEntrySwitch.isOn = false
      conflictedEntrySwitch.isOn = true
    case .error:
      incorrectEntrySwitch.isOn = true
      conflictedEntrySwitch.isOn = false
    case .none:
      incorrectEntrySwitch.isOn = false
      conflictedEntrySwitch.isOn = false
    }
  }
  
  @IBAction func handleSegmentedControl(_ sender: UISegmentedControl)
  {
    checkState()
  }
  
  @IBAction func handleSwitch(_ sender: UISwitch)
  {
    switch sender
    {
    case autoMarkSwitch:
      autoMarkPolicy.isEnabled = sender.isOn
    case incorrectEntrySwitch:
      if sender.isOn { conflictedEntrySwitch.isOn = false }
    case conflictedEntrySwitch:
      if sender.isOn { incorrectEntrySwitch.isOn = false}
    default:
      break;
    }
    
    checkState()
  }
  
  func checkState()
  {
    settings.markStyle = SudokuWizard.MarkStyle(rawValue: styleSegmentedControl.selectedSegmentIndex) ?? .digits
    
    settings.markStrategy = (
      autoMarkSwitch.isOn == false ? .manual :
        autoMarkPolicy.selectedSegmentIndex == 0 ? .allowed : .conflicted
    )
    
    settings.errorFeedback = (
      incorrectEntrySwitch.isOn ? .error :
      conflictedEntrySwitch.isOn ? .conflict : .none
    )
    
    let dirty = delegate != nil && settings.differ(from: Settings.shared)
    
    updateButtonItem.setTitle((dirty ? "Apply" : "Back"), for: .normal)
    cancelButtonItem.isEnabled = dirty
    cancelButtonItem.isHidden  = (dirty == false)
  }
  
  
}
