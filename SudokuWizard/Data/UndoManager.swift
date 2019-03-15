//
//  UndoManager.swift
//
//  Created by Mike Mayer on 4/25/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation

protocol UndoableAction : class
{
  func undo() -> Bool
  func redo() -> Bool
  var label : String { get }
  
  func merge(_ action:UndoableAction) -> Bool
}

extension UndoableAction
{
  func merge(_ action:UndoableAction) -> Bool { return false }
}

protocol UndoManagerObserver
{
  func updateUndoState(using um:UndoManager)
}

class UndoManager
{
  // MARK: - Class methods
  
  static let shared = UndoManager()
  
  private var undoStack = [UndoableAction]()
  private var redoStack = [UndoableAction]()
  
  private var observers = [UndoManagerObserver]()
  
  init() {}
  
  func add(observer:UndoManagerObserver)
  {
    observers.append(observer)
  }
  
  func notifyObservers()
  {
    observers.forEach { $0.updateUndoState(using:self) }
  }
  
  var hasUndo : Bool { return undoStack.isEmpty == false }
  var hasRedo : Bool { return redoStack.isEmpty == false }
  
  func clear() -> Void
  {
    undoStack.removeAll()
    redoStack.removeAll()
    notifyObservers()
  }
  
  func add(_ action : UndoableAction) -> Void
  {
    guard action.redo() else { return }
    
    if redoStack.isEmpty, let head = undoStack.last, head.merge(action) {}
    else { undoStack.append(action) }
    
    redoStack.removeAll()
    notifyObservers()
  }
  
  func undo() -> Void
  {
    if undoStack.isEmpty { return }

    let action = undoStack.removeLast()
    
    if action.undo() { redoStack.append(action) }
    
    notifyObservers()
  }

  func redo() -> Void
  {
    if redoStack.isEmpty { return }
    
    let action = redoStack.removeLast()
    
    if action.redo() { undoStack.append(action) }
    else             { redoStack.removeAll() }
    
    notifyObservers()
  }
  
  func cancel(undo action:UndoableAction)
  {
    if redoStack.last === action { undoStack.append(redoStack.removeLast()) }
    else                         { redoStack.removeAll()                    }

    notifyObservers()
  }
  
  func history() -> (undo:[ String]?, redo:[String]? )
  {
    var undos : [String]?
    var redos : [String]?
    
    if hasUndo {
      undos = [String]()
      for u in undoStack { undos!.append(u.label) }
    }
    
    if hasRedo {
      redos = [String]()
      for r in redoStack { redos!.append(r.label)}
    }
    
    return (undos,redos)
  }
}
