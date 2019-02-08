//
//  NewPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/27/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class NewPuzzleViewController: UIViewController, SudokuWizardCellViewDelegate
{
  @IBOutlet weak var gridView: SudokuWizardGridView!
  @IBOutlet weak var statusView: UIView?
  @IBOutlet weak var statusLabel: UILabel?
    
  private var buttons = [UIButton]()
  
  func add(button:UIButton)
  {
    buttons.append(button)
  }

  var dirty = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let bg = UIImage(named:"SudokuBackground") {
      view.backgroundColor = UIColor(patternImage: bg)
    }
    
    for cell in gridView.cellViews { cell.delegate = self }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let sv = statusView
    {
      let r  = sv.frame.height/4.0
      let sl = sv.layer
      let sp = UIBezierPath(roundedRect: sv.bounds, cornerRadius: r)
      sl.cornerRadius = r
      sl.shadowPath = sp.cgPath
      sl.shadowColor = UIColor.black.cgColor
      sl.shadowOpacity = 0.5
      sl.shadowOffset = CGSize(width:3.0,height:3.0)
      sl.shadowRadius = 5.0
      sl.masksToBounds = false
    }
    
    let gl = gridView.layer
    gl.shadowPath = UIBezierPath(rect: gridView.bounds).cgPath
    gl.shadowColor = UIColor.black.cgColor
    gl.shadowOpacity = 0.5
    gl.shadowOffset = CGSize(width:3.0,height:3.0)
    gl.shadowRadius = 5.0
    gl.masksToBounds = false
    
    for b in buttons
    {
      b.layer.cornerRadius = b.frame.height/2.0
    }
  }
  
  @IBAction func handleCancel(_ sender: UIButton) {
    if dirty {
      let alert = UIAlertController(title:"Discard Puzzle",
                                    message:"This will throw away this new puzzle",
                                    preferredStyle:.alert)
      alert.addAction( UIAlertAction(title: "OK", style:.destructive) { _ in
        self.navigationController?.popViewController(animated: true) } )
      alert.addAction( UIAlertAction(title:"Cancel", style:.cancel) )
      
      self.present(alert,animated: true)
    }
    else
    {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  func dismiss()
  {
    self.navigationController?.popViewController(animated: true)
  }
  
  
  func sudokuWizardCellView(selected cell: SudokuWizardCellView) { cell.selected = false }
  func sudokuWizardCellView(touch: UITouch, outside cell: SudokuWizardCellView) { }
  
  func handleBackgroundTap()
  {
    gridView.selectedCell = nil
  }

}
