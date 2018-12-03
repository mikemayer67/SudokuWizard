//
//  ViewController.swift
//  SudokuWizardCellViewTest
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SudokuWizardCellViewDelegate
{
  @IBOutlet weak var sizeSlider: UISlider!
  @IBOutlet weak var xSlider: UISlider!
  @IBOutlet weak var ySlider: UISlider!
  @IBOutlet weak var boundsView: UIView!
  @IBOutlet weak var cellView: SudokuWizardCellView!
  @IBOutlet weak var viewWidth: NSLayoutConstraint!
  @IBOutlet weak var viewHeight: NSLayoutConstraint!
  @IBOutlet weak var viewTop: NSLayoutConstraint!
  @IBOutlet weak var viewLeading: NSLayoutConstraint!
  @IBOutlet weak var lockedSwitch: UISwitch!
  @IBOutlet weak var conflictedSwitch: UISwitch!
  @IBOutlet weak var highlightedSwitch: UISwitch!
  @IBOutlet weak var valueControl: UISegmentedControl!
  @IBOutlet weak var markTypeControl: UISegmentedControl!
  @IBOutlet weak var markOne: UIButton!
  @IBOutlet weak var markTwo: UIButton!
  @IBOutlet weak var markThree: UIButton!
  @IBOutlet weak var markFour: UIButton!
  @IBOutlet weak var markFive: UIButton!
  @IBOutlet weak var markSix: UIButton!
  @IBOutlet weak var markSeven: UIButton!
  @IBOutlet weak var markEight: UIButton!
  @IBOutlet weak var markNine: UIButton!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let pw = cellView.superview!.bounds.width
    let ph = cellView.superview!.bounds.height

    let maxSize   = pw < ph ? pw : ph
    let minSize   = maxSize / 9.0
    let startSize = 0.5 * (minSize + maxSize)

    sizeSlider.minimumValue = Float( minSize )
    sizeSlider.maximumValue = Float( maxSize )
    sizeSlider.value        = Float( startSize )
    
    viewWidth.constant   = startSize
    viewHeight.constant  = startSize
    viewLeading.constant = 0.5 * (pw-startSize)
    viewTop.constant     = 0.5 * (ph-startSize)
    
    lockedSwitch.transform      = CGAffineTransform(scaleX: 0.75, y: 0.75)
    conflictedSwitch.transform  = CGAffineTransform(scaleX: 0.75, y: 0.75)
    highlightedSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    
    switch cellView.state
    {
    case .empty:
      lockedSwitch.isOn = false
      lockedSwitch.isEnabled = false
      conflictedSwitch.isOn = false
      conflictedSwitch.isEnabled = false
      highlightedSwitch.isOn = false
    case let .filled(d):
      lockedSwitch.isOn = false
      lockedSwitch.isEnabled = true
      conflictedSwitch.isOn = cellView.conflicted
      conflictedSwitch.isEnabled = true
      highlightedSwitch.isOn = cellView.highlighted
      highlightedSwitch.isEnabled = true
      valueControl.selectedSegmentIndex = d
    case let .locked (d):
      lockedSwitch.isOn = true
      lockedSwitch.isEnabled = true
      conflictedSwitch.isOn = cellView.conflicted
      conflictedSwitch.isEnabled = true
      highlightedSwitch.isOn = cellView.highlighted
      highlightedSwitch.isEnabled = true
      valueControl.selectedSegmentIndex = d
    }
    
    cellView.delegate = self
    cellView.selected = false
  }
  
  @IBAction func handleSlider(_ sender: UISlider)
  {
    let cw = cellView.bounds.width
    let ch = cellView.bounds.height
    
    let pw = cellView.superview!.bounds.width
    let ph = cellView.superview!.bounds.height
    
    viewWidth.constant = CGFloat( sizeSlider.value )
    viewHeight.constant = CGFloat( sizeSlider.value )
    viewLeading.constant = CGFloat(xSlider.value) * (pw-cw)
    viewTop.constant = CGFloat(ySlider.value) * (ph-ch)
    
    print("cellView.frame: ",cellView.frame," in ", cellView.superview!.bounds)
  }
  
  @IBAction func handleSwitch(_ sender: UISwitch)
  {
    if sender == lockedSwitch
    {
      switch cellView.state
      {
      case let .filled(d):
        if sender.isOn {
          cellView.state = .locked(d)
          cellView.selected = false
        }
      case let .locked(d):
        if sender.isOn == false
        {
          cellView.state = .filled(d)
        }
      default:
        break
      }
    }
    else if sender == conflictedSwitch
    {
      cellView.conflicted = sender.isOn
    }
    else if sender == highlightedSwitch
    {
      cellView.highlighted = sender.isOn
    }
  }
  
  @IBAction func handleValueSelection(_ sender: UISegmentedControl)
  {
    let d = sender.selectedSegmentIndex
    
    if d == 0
    {
      switch cellView.state
      {
      case .empty:
        break
      case .filled(_):
        cellView.state = .empty
        lockedSwitch.isOn = false
        lockedSwitch.isEnabled = false
        conflictedSwitch.isOn = false
        conflictedSwitch.isEnabled = false
        highlightedSwitch.isOn = false
        highlightedSwitch.isEnabled = false
        cellView.conflicted = false
        cellView.highlighted = false
      case let .locked(oldValue):
        sender.selectedSegmentIndex = oldValue
      }
    }
    else
    {
      switch cellView.state
      {
      case .empty:
        cellView.state = .filled(d)
        lockedSwitch.isEnabled = true
        conflictedSwitch.isEnabled = true
        highlightedSwitch.isEnabled = true
      case .filled(_):
        cellView.state = .filled(d)
      case let .locked(oldValue):
        sender.selectedSegmentIndex = oldValue
      }
    }
  }
  
  @IBAction func handleMark(_ sender: UIButton)
  {
    if sender.isSelected
    {
      sender.isSelected = false
      cellView.clear(mark: sender.tag)
    }
    else
    {
      sender.isSelected = true
      cellView.set(mark: sender.tag)
    }
    
    markOne.isSelected = cellView.hasMark(1)
    markTwo.isSelected = cellView.hasMark(2)
    markThree.isSelected = cellView.hasMark(3)
    markFour.isSelected = cellView.hasMark(4)
    markFive.isSelected = cellView.hasMark(5)
    markSix.isSelected = cellView.hasMark(6)
    markSeven.isSelected = cellView.hasMark(7)
    markEight.isSelected = cellView.hasMark(8)
    markNine.isSelected = cellView.hasMark(9)
  }
  
  @IBAction func handleMarkType(_ sender: UISegmentedControl)
  {
    cellView.markStyle = SudokuWizardCellView.MarkStyle(rawValue: sender.selectedSegmentIndex)!
  }
  
  func sudokuWizardCellTapped(_ cellView: SudokuWizardCellView)
  {
    switch cellView.state
    {
    case .empty, .filled(_):
      cellView.selected = !cellView.selected
    case .locked(_):
      break
    }
  }
  
  func sudokuWizardCellPressed(_ cellView: SudokuWizardCellView)
  {
    print("Cell Pressed")
  }
}


//
//func sudokuWizardCellPopupForUserInput(_ cellView: SudokuWizardCellView)
//{
//  if popupController == nil
//  {
//    print("Create popup controller")
//    popupController = SudokuWizardPopupController()
//  }
//  if let pc = popupController
//  {
//    print("Popup for :", cellView, pc )
//    print("bounds frame: ", self.boundsView.frame )
//    print("cell frame: ", cellView.frame )
//
//    present(pc, animated: false)
//    {
//      print("Popup presented")
//    }
//  }
//}

