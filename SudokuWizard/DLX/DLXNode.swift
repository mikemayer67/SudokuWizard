//
//  Node.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class DLXNode
{
  var left  : DLXNode!
  var right : DLXNode!
  var up    : DLXNode!
  var down  : DLXNode!
  
  init()
  {
    self.left  = self
    self.right = self
    self.up    = self
    self.down  = self
  }
  
  func insert(after x:DLXNode)
  {
    self.left       = x
    self.right      = x.right
    self.left.right = self
    self.right.left = self
  }
  
  func insert(before x:DLXNode)
  {
    self.right      = x
    self.left       = x.left
    self.left.right = self
    self.right.left = self
  }
  
  func insert(below x:DLXNode)
  {
    self.up      = x
    self.down    = x.down
    self.up.down = self
    self.down.up = self
  }
  
  func insert(above x:DLXNode)
  {
    self.down    = x
    self.up      = x.up
    self.up.down = self
    self.down.up = self
  }
  
  func removeFromRow()
  {
    self.left.right = self.right
    self.right.left = self.left
  }
  
  func removeFromColumn()
  {
    self.up.down = self.down
    self.down.up = self.up
  }
  
  func reinsert()
  {
    self.up.down    = self
    self.down.up    = self
    self.left.right = self
    self.right.left = self
  }
  
  var coverage : String
  {
    let L = ( left === self ? "X" : "." )
    let R = ( right === self ? "X" : "." )
    let U = ( up === self ? "X" : "." )
    let D = ( down === self ? "X" : "." )
    return ":" + L + R + U + D
  }
  
  var id : String { return "" }
  var logEntry : String
  {
    return String(format:"%@%@  left:%@  right:%@  up:%@  down:%@",
                  self.id, self.coverage,
                  self.left.id, self.right.id, self.up.id, self.down.id)
  }
}



