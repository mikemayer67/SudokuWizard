//
//  NewPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/27/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class NewPuzzleViewController: UIViewController
{
  var dirty = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let bg = UIImage(named:"SudokuBackground") {
      view.backgroundColor = UIColor(patternImage: bg)
    }
  }

  override func viewDidLoad()
  {
    super.viewDidLoad()
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
}
