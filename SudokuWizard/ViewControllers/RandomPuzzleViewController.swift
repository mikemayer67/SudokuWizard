//
//  RandomPuzzleViewController.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/27/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class RandomPuzzleViewController: NewPuzzleViewController
{
  @IBOutlet weak var regenButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var difficultyView: StatusView!
  
  let genQueue = DispatchQueue(label: "RandomPuzzleGenerator")
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    add(button:regenButton)
    add(button:startButton)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    generate()
  }
  
  @IBAction func handleRegen(_ sender: UIButton)
  {
    generate()
  }
    
  @IBAction func handleStart(_ sender: UIButton)
  {
    puzzleController?.restart(with: gridView)
    dismiss()
  }
  
  // MARK: - Random puzzle
  
  func generate()
  {
    gridView.clear()
    regenButton.isEnabled = false
    startButton.isEnabled = false
    difficultyView.text = "???"
    
    var flashErr = true
    var flashIndex = Int.random(in: 0...80)
    let timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
      DispatchQueue.main.async {
        if flashErr { self.gridView.cellViews[flashIndex].errant = false }
        else        { self.gridView.cellViews[flashIndex].highlighted = false }
        flashErr   = Int.random(in:0...1) == 0
        flashIndex = Int.random(in:0...80)
          
        if flashErr { self.gridView.cellViews[flashIndex].errant = true }
        else        { self.gridView.cellViews[flashIndex].highlighted = true }
      }
    }
    
    genQueue.async {
      let rs = RandomSudoku()
      
      DispatchQueue.main.async {
        do {
          try self.gridView.loadPuzzle(rs.puzzle, solution: rs.solution)
          self.difficultyView.text = String(format: "%d", rs.difficulty)
        }
        catch {
          fatalError("Should never get here \(#file):\(#line)")
        }
        timer.invalidate()
        self.regenButton.isEnabled = true
        self.startButton.isEnabled = true
        self.dirty = true
        if flashErr { self.gridView.cellViews[flashIndex].errant = false }
        else        { self.gridView.cellViews[flashIndex].highlighted = false }
      }
    }
  }
  
}
