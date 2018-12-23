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
  @IBOutlet weak var updateButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var autoMarkSwitch: UISwitch!
  @IBOutlet weak var autoMarkPolicy: UISegmentedControl!
  @IBOutlet weak var incorrectEntrySwitch: UISwitch!
  @IBOutlet weak var conflictedEntrySwitch: UISwitch!
  
  var settings = Settings()
  var delegate : SettingsViewControllerDelegate?
  
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
    
    checkState()
  }
  
  @IBAction func handleButton(_ sender: UIButton)
  {
    if sender == updateButton
    {
      delegate?.settingsViewController(update: settings)
    }
    self.navigationController?.popViewController(animated: true)
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
    
    updateButton.setTitle((dirty ? "apply" : "back"), for: .normal)
    cancelButton.isEnabled = dirty
    cancelButton.isHidden  = (dirty == false)
  }
  
}
