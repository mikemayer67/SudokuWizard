//
//  DigitSet.swift
//  SudokuWizard
//
//  Created by Mike Mayer on 1/14/19.
//  Copyright © 2019 VMWishes. All rights reserved.
//

import Foundation

fileprivate let MaskDigits : Dictionary<UInt16,Digit> = [0x001:1, 0x002:2, 0x004:3, 0x008:4, 0x010:5, 0x020:6, 0x040:7, 0x080:8, 0x100:9 ]
fileprivate let DigitMasks : Dictionary<Digit,UInt16> = [1:0x001, 2:0x002, 3:0x004, 4:0x008, 5:0x010, 6:0x020, 7:0x040, 8:0x080, 9:0x100 ]

struct DigitSet
{
  private(set) var n : Int = 0
  
  private var digitBits : UInt16 = 0
  
  init(_ on:Bool = false) {
    if on { n = 9; digitBits = 0b111111111 }
  }
  
  init(_ bits:UInt16) {
    digitBits = bits
    n = countBits()
  }
  
  mutating func set(_ digit:Digit) {
    let m = mask(digit)
    if digitBits & m == 0 { n += 1; digitBits |= m }
  }
  
  mutating func clear(_ digit:Digit) {
    let m = mask(digit)
    if digitBits & m != 0 { n -= 1; digitBits &= ~m }
  }
  
  var isEmpty : Bool { return n==0 }
  
  func has(digit:Digit) -> Bool
  {
    return digitBits & mask(digit) != 0
  }
  
  func missing(digit:Digit) -> Bool
  {
    return digitBits & mask(digit) == 0
  }
  
  func digit() -> Digit?
  {
    return MaskDigits[digitBits]
  }
  
  func digits() -> [Digit]
  {
    var rval = [Digit]()
    for d : Digit in 1...9 {
      if has(digit:d) { rval.append(d) }
    }
    return rval
  }
  
  func union(_ x:DigitSet) -> DigitSet
  {
    return DigitSet(self.digitBits | x.digitBits)
  }
  
  func intersect(_ x:DigitSet) -> DigitSet
  {
    return DigitSet(self.digitBits & x.digitBits)
  }
  
  func subtract(_ x:DigitSet) -> DigitSet
  {
    return DigitSet(self.digitBits & ~x.digitBits)
  }
  
  func complement() -> DigitSet
  {
    return DigitSet(~self.digitBits)
  }
  
  private func countBits() -> Int
  {
    var rval : Int  = 0
    var mask : UInt16 = 1
    for _ in 0..<9 {
      if ( digitBits & mask ) != 0 { rval += 1 }
      mask *= 2
    }
    return rval
  }
  
  private func mask(_ digit:Digit) -> UInt16
  {
    return 1 << UInt16(digit-1)
  }
}
