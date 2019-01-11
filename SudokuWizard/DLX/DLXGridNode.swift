//
//  DLXGridNode.swift
//  
//
//  Created by Mike Mayer on 10/26/18.
//

import Foundation

class DLXGridNode : DLXNode
{
  let row : Int
  let col : DLXColumnNode

  override var id : String { return "(" + row.description + "," + col.col.description + ")" }
  
  init(row:Int, col:DLXColumnNode)
  {
    self.row = row
    self.col = col
    
    super.init()
    
    col.add(row:self)
  }
  
}
