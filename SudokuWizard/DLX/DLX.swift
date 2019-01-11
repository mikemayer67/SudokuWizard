//
//  DLX.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

enum DLXError : Error
{
  case InputEmpty
  case InputNoCoverage
}

enum DLXSolutionStatus
{
  case NoSolution
  case UniqueSolution([Int])
  case MultipleSolutions
}

extension Notification.Name {
  static let DLXSolutionFound      = Notification.Name("DLXSolutionAdded")
  static let DLXAlgorithmCanceled  = Notification.Name("DLXAlgorithmCanceled")
  static let DLXAlgorithmComplete  = Notification.Name("DLXAlgorithmComplete")
}

// DLX is the root node of the DLX grid

class DLX : DLXNode
{
  var isComplete = false  // have all solutions been found
    
  override var id : String { return " root"}
  
  // The init method converts the input coverage "matrix" into the
  //   double-linked mesh representing the matrix.  The actual format
  //   of the input is an array of arrays of Int values.  Each member
  //   of the outer array (and [Int] object) represents a distinct row
  //   in the coverage matrix.  Each inner array (a row) contains the
  //   indices of the columsn in the matrix "covered" by that row, i.e.
  //   where the 1's are in the coverage matrix.
  
  init( _ A:[[Int]] ) throws
  {
    super.init()
    
    if A.count == 0 { throw DLXError.InputEmpty }
    
    var columns = Dictionary<Int,DLXColumnNode>()
    
    for i in 0..<A.count {
      var head : DLXGridNode?
      for j in A[i]
      {
        let col = columns[j] ?? DLXColumnNode(j)
        let node = DLXGridNode( row:i, col:col )
        if head == nil { head = node }
        else           { node.insert(before:head!) }  // adds node to END of the current row
        if columns[j] == nil { columns[j] = col }
      }
    }
    
    if columns.keys.isEmpty { throw DLXError.InputNoCoverage }
    
    columns.keys.sorted().forEach { (id: Int) in
      columns[id]!.insert(before: self) // adds node to END of the column header row
    }
  }
  
  // The pickCoumn method selects the column with the least number
  //  of associated rows.  In the case two or more columns have the
  //  same least number of rows, the first one to the right of the
  //  root will be chosen
  
  func pickColumn() -> DLXColumnNode?
  {
    var c = self.right as? DLXColumnNode
    
    var j = c?.right as? DLXColumnNode
    while j != nil
    {
      if( j!.rows < c!.rows ) { c = j }
      j = j!.right as? DLXColumnNode
    }
    
    return c;
  }
  
  // Finding solutions to a DLX problem could very easily take more time
  //   than would be acceptable in anything other than a command line tool.
  //   Therefore the solution algorithm is executed in a background thread.
  //
  // To support this, two quess are created:
  //   1) n operation queue in which the algorithm will be run
  //   2) a dispatch queue which will manage the read/update of the solutions
  
  let solverQueue = OperationQueue()
  let dataQueue = DispatchQueue(label: "DLXDataQueue")
  
  // Following is the array of solutions and the thread safe accesors for
  //   reading and updating the array.  Note that the solutions method
  //   returns a COPY of the solutions at the time it is invoked (more
  //   accurately at the time the data queue processes the read request).
  
  private var lastNotification : Date?
  private var solutions_ = [[Int]]() // actual storage...
  
  var solutions : [[Int]] {
    return dataQueue.sync { return solutions_ }
  }
  
  func addSolution(_ solution : [Int])
  {
    dataQueue.sync { [weak self] in
      solutions_.append(solution)
      let now = Date();
      
      if lastNotification == nil || now.timeIntervalSince(lastNotification!) >= 1.0
      {
        DispatchQueue.main.async {
          NotificationCenter.default.post(name: .DLXSolutionFound, object: self)
        }
        lastNotification = now
      }
    }
  }
  
  func resetSolutions()
  {
    dataQueue.sync { solutions_.removeAll() }
  }

  
  // The next two methods control the execution of the dancing link
  //   algroithm in a background thread.
  //
  // The solve method kicks off the algorithm iusing the DLXSolver operation
  // The cancel method kills the algorithm (if running).
  //
  //  As each solution is found, a DLXSolutionFound notification will
  //    be posted.  These solutions can be watched via the thread-safe
  //    solutions method (above).
  //
  //  When the algorithm has completed, a DLXAlgorithmComplete notification
  //    will be posted.
  //
  //  Calling 'solve' while there is already an algorithm operation
  //    running or after the algrorithm has run to comppleteion will
  //    not start a new algorithm oparation.
  //  Calling 'solve' after an algorithm has been canceled will clear
  //    the current set of solutions and restart the algorithm from scratch.
  
  func solve()
  {
    if isComplete                     { return }
    if solverQueue.operationCount > 0 { return }
    
    let algorithm = DLXAlgorithm(self)
    
    solverQueue.addOperation( algorithm )
  }
  
  func cancel()
  {
    if isComplete { return }
    
    solverQueue.cancelAllOperations()
  }
  
  // The final method uses the dancing link algorithm to evaluate the
  //   nature of the coverage problem: no solution, unique solution, or
  //   multiple solutions.  If there is a unique solution, it is returned
  //   as part of the status.
  //
  // This method runs synchronously and does not use notification to
  //   provide run status
  
  func evaluate() -> DLXSolutionStatus
  {
    let algorithm = DLXAlgorithm(self)
    return algorithm.audit()
  }
}
