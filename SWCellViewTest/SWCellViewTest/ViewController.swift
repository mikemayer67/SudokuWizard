//
//  ViewController.swift
//  SWCellViewTest
//
//  Created by Mike Mayer on 11/22/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
  @IBOutlet weak var sizeSlider: UISlider!
  @IBOutlet weak var cellView: SWCellView!
  @IBOutlet weak var viewWidth: NSLayoutConstraint!
  @IBOutlet weak var viewHeight: NSLayoutConstraint!
  @IBOutlet weak var lockedSwitch: UISwitch!
  @IBOutlet weak var conflictedSwitch: UISwitch!
  @IBOutlet weak var valueControl: UISegmentedControl!
  @IBOutlet weak var markTypeControl: UISegmentedControl!
  
  let maxWidth = UIScreen.main.bounds.width - 40
  let maxHeight = UIScreen.main.bounds.height - 40
    
  override func viewDidLoad()
  {
    super.viewDidLoad()

    let maxSize   = maxWidth < maxHeight ? maxWidth : maxHeight
    let minSize   = maxSize / 9.0
    let startSize = 0.5 * (minSize + maxSize)

    sizeSlider.minimumValue = Float( minSize )
    sizeSlider.maximumValue = Float( maxSize )
    sizeSlider.value = Float( startSize )
    
    viewWidth.constant = startSize
    viewHeight.constant = startSize
    
    lockedSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    conflictedSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    
    lockedSwitch.isOn = cellView.locked
    conflictedSwitch.isOn = cellView.conflicted
    
    valueControl.selectedSegmentIndex = cellView.value
    markTypeControl.selectedSegmentIndex = cellView.markType == .digits ? 0 : 1
  }
  
  @IBAction func handleSlider(_ sender: UISlider)
  {
    viewWidth.constant = CGFloat( sizeSlider.value )
    viewHeight.constant = CGFloat( sizeSlider.value )
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
    cellView.markType = sender.selectedSegmentIndex == 0 ? SWCellView.MarkType.digits : SWCellView.MarkType.dots
  }
}

