//
//  DLXColumnNode.swift
//  
//
//  Created by Mike Mayer on 10/26/18.
//

import Foundation

class DLXColumnNode : DLXNode
{
  var col : Int
  var rows = 0
  
  override var id : String { return "C" + col.description + "[" + rows.description + "]" }

  init(_ col:Int)
  {
    self.col = col
    super.init()
  }
  
  func add(row node:DLXGridNode)
  {
    node.insert(above:self) // this inserts node at bottom of the column
    self.rows += 1
  }
  
  func cover()
  {
    self.left.right = self.right
    self.right.left = self.left
    
    var i = self.down as? DLXGridNode
    while i != nil
    {
      var j = i!.right as! DLXGridNode
      while j !== i
      {
        j.down.up = j.up
        j.up.down = j.down
        j.col.rows -= 1
        j = j.right as! DLXGridNode
      }
      i = i!.down as? DLXGridNode
    }
  }
  
  func uncover()
  {
    var i = self.up as? DLXGridNode
    while i != nil
    {
      var j = i!.left as! DLXGridNode
      while j !== i
      {
        j.down.up = j
        j.up.down = j
        j.col.rows += 1
        j = j.left as! DLXGridNode
      }
      i = i!.up as? DLXGridNode
    }
    
    self.right.left = self
    self.left.right = self
  }
  
}
