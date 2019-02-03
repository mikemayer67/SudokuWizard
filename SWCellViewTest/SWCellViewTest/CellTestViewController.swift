//
//  CellTestViewController.swift
//  SudokuWizardCellViewTest
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class CellTestViewController: UIViewController, SudokuWizardCellViewDelegate
{
  @IBOutlet weak var sizeSlider: UISlider!
  @IBOutlet weak var xSlider: UISlider!
  @IBOutlet weak var ySlider: UISlider!
  @IBOutlet weak var cellView: SudokuWizardCellView!
  @IBOutlet weak var bgView: BackgroundView!
  @IBOutlet weak var viewWidth: NSLayoutConstraint!
  @IBOutlet weak var viewHeight: NSLayoutConstraint!
  @IBOutlet weak var viewTop: NSLayoutConstraint!
  @IBOutlet weak var viewLeading: NSLayoutConstraint!
  @IBOutlet weak var lockedSwitch: UISwitch!
  @IBOutlet weak var errantSwitch: UISwitch!
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
  
  var markButtons = [UIButton]()
  
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
    errantSwitch.transform      = CGAffineTransform(scaleX: 0.75, y: 0.75)
    highlightedSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    
    switch cellView.state
    {
    case .empty:
      lockedSwitch.isOn = false
      lockedSwitch.isEnabled = false
      errantSwitch.isOn = false
      errantSwitch.isEnabled = false
      highlightedSwitch.isOn = false
    case let .filled(d):
      lockedSwitch.isOn = false
      lockedSwitch.isEnabled = true
      errantSwitch.isOn = cellView.errant
      errantSwitch.isEnabled = true
      highlightedSwitch.isOn = cellView.highlighted
      highlightedSwitch.isEnabled = true
      valueControl.selectedSegmentIndex = Int(d)
    case let .locked (d):
      lockedSwitch.isOn = true
      lockedSwitch.isEnabled = true
      errantSwitch.isOn = cellView.errant
      errantSwitch.isEnabled = true
      highlightedSwitch.isOn = cellView.highlighted
      highlightedSwitch.isEnabled = true
      valueControl.selectedSegmentIndex = Int(d)
    }
    
    cellView.delegate = self
    cellView.selected = false
    
    markButtons = [markOne, markTwo, markThree, markFour, markFive, markSix, markSeven, markEight, markNine]
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
    else if sender == errantSwitch
    {
      cellView.errant = sender.isOn
    }
    else if sender == highlightedSwitch
    {
      cellView.highlighted = sender.isOn
    }
  }
  
  @IBAction func handleValueSelection(_ sender: UISegmentedControl)
  {
    let d = Digit(sender.selectedSegmentIndex)
    
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
        errantSwitch.isOn = false
        errantSwitch.isEnabled = false
        highlightedSwitch.isOn = false
        highlightedSwitch.isEnabled = false
        cellView.errant = false
        cellView.highlighted = false
      case let .locked(oldValue):
        sender.selectedSegmentIndex = Int(oldValue)
      }
    }
    else
    {
      switch cellView.state
      {
      case .empty:
        cellView.state = .filled(d)
        lockedSwitch.isEnabled = true
        errantSwitch.isEnabled = true
        highlightedSwitch.isEnabled = true
      case .filled(_):
        cellView.state = .filled(d)
      case let .locked(oldValue):
        sender.selectedSegmentIndex = Int(oldValue)
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
    
    for i in 1...9 {
      markButtons[i-1].isSelected = cellView.hasMark(i)
    }
  }
  
  var isMarkable = true
  {
    didSet {
      cellView.markable = isMarkable
      
      if isMarkable {
        for i in 1...9 {
          markButtons[i-1].isEnabled = true
        }
      }
      else {
        for i in 1...9 {
          markButtons[i-1].isSelected = false
          markButtons[i-1].isEnabled = false
        }
      }
    }
  }
  
  @IBAction func handleMarkType(_ sender: UISegmentedControl)
  {
    switch sender.selectedSegmentIndex
    {
    case 0:
      cellView.markStyle = .digits
      isMarkable = true
    case 1:
      cellView.markStyle = .dots
      isMarkable = true
    default:
      isMarkable = false
    }
  }
  
  func sudokuWizardCellView(selected cell: SudokuWizardCellView) { }
  func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView) { }
}


