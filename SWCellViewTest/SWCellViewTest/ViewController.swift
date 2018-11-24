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
  @IBOutlet weak var cellView: SudokuWizardCellView!
  @IBOutlet weak var viewWidth: NSLayoutConstraint!
  @IBOutlet weak var viewHeight: NSLayoutConstraint!
  @IBOutlet weak var viewTop: NSLayoutConstraint!
  @IBOutlet weak var viewLeading: NSLayoutConstraint!
  @IBOutlet weak var lockedSwitch: UISwitch!
  @IBOutlet weak var conflictedSwitch: UISwitch!
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
  @IBOutlet weak var touchInputControl: UISegmentedControl!
  
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
    
    lockedSwitch.transform     = CGAffineTransform(scaleX: 0.75, y: 0.75)
    conflictedSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    
    lockedSwitch.isOn     = cellView.locked
    conflictedSwitch.isOn = cellView.conflicted
    
    valueControl.selectedSegmentIndex      = cellView.value
    markTypeControl.selectedSegmentIndex   = cellView.markType.rawValue
    touchInputControl.selectedSegmentIndex = cellView.touchInputAction.rawValue
    
    cellView.delegate = self
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
      cellView.locked = sender.isOn
    }
    else if sender == conflictedSwitch
    {
      cellView.conflicted = sender.isOn
    }
  }
  
  @IBAction func handleValueSelection(_ sender: UISegmentedControl)
  {
    cellView.value = sender.selectedSegmentIndex
  }
  
  @IBAction func handleMark(_ sender: UIButton)
  {
    sender.isSelected = sender.isSelected ? false : true
    cellView.set(mark:sender.tag, on:sender.isSelected)
  }
  
  @IBAction func handleMarkType(_ sender: UISegmentedControl)
  {
    cellView.markType = SudokuWizardCellView.MarkType(rawValue: sender.selectedSegmentIndex)!
  }
  
  @IBAction func handleTouchInputControl(_ sender: UISegmentedControl)
  {
    cellView.touchInputAction = SudokuWizardCellView.TouchInputAction(rawValue: sender.selectedSegmentIndex)!
  }
  
  func sudokuWizardCellViewValueChanged(_ cellView: SudokuWizardCellView)
  {
    valueControl.selectedSegmentIndex = cellView.value
  }
  
  func sudokuWizardCellValueMarksChanged(_ cellView: SudokuWizardCellView)
  {
    markOne.isSelected = cellView.isSet(mark: 1)
    markTwo.isSelected = cellView.isSet(mark: 2)
    markThree.isSelected = cellView.isSet(mark: 3)
    markFour.isSelected = cellView.isSet(mark: 4)
    markFive.isSelected = cellView.isSet(mark: 5)
    markSix.isSelected = cellView.isSet(mark: 6)
    markSeven.isSelected = cellView.isSet(mark: 7)
    markEight.isSelected = cellView.isSet(mark: 8)
    markNine.isSelected = cellView.isSet(mark: 9)
  }
}

