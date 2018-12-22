//
//  Settings.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 12/18/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

class Settings
{
  // MARK: - Class data
  
  static let factoryDefaults : [ String : AnyObject ] =
  {
    let fd = Bundle.main.path(forResource: "FactoryDefaults", ofType: "plist")
    return NSDictionary(contentsOfFile:fd!) as! [String : AnyObject]
  }()
  
  static let defaults : UserDefaults =
  {
    let ud = UserDefaults.standard
    ud.register(defaults: factoryDefaults)
    ud.synchronize()
    return ud
  }()
  
  static var shared = Settings()
  {
    didSet
    {
      shared.updateDefaults()
      defaults.synchronize()
    }
  }
  
  // MARK: = Settings data
  
  let markStyleKey     = "markStyle"
  let markStrategyKey  = "markStrategy"
  let errorFeedbackKey = "errorFeedback"
  
  var markStyle     : SudokuWizard.MarkStyle
  var markStrategy  : SudokuWizard.MarkStrategy
  var errorFeedback : SudokuWizard.ErrorFeedback
  
  init()
  {
    let dv = Settings.defaults
    markStyle   = SudokuWizard.MarkStyle(rawValue: dv.integer(forKey: markStyleKey)) ?? .dots
    markStrategy = SudokuWizard.MarkStrategy(rawValue: dv.integer(forKey: markStrategyKey )) ?? .manual
    errorFeedback = SudokuWizard.ErrorFeedback(rawValue: dv.integer(forKey: errorFeedbackKey )) ?? .conflict
  }
  
  func updateDefaults()
  {
    let dv = Settings.defaults
    dv.set( markStyle.rawValue, forKey:markStyleKey)
    dv.set( markStrategy.rawValue, forKey:markStrategyKey)
    dv.set( errorFeedback.rawValue, forKey:errorFeedbackKey)
  }
  
  func differ(from x:Settings) -> Bool
  {
    if markStyle  != x.markStyle        { return true }
    if markStrategy != x.markStrategy   { return true }
    if errorFeedback != x.errorFeedback { return true }
    return false
  }
}
