//
//  Bitwise.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2020-12-31.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import Swiftz

var _Bitwise_and = curry { (_ a: Int, _ b: Int) in a & b }
var _Bitwise_or = curry { (_ a: Int, _ b: Int) in a | b }
var _Bitwise_xor = curry { (_ a: Int, _ b: Int) in a ^ b }
func _Bitwise_complement(_ a: Int) -> Int {
    return ~a
}

var _Bitwise_shiftLeftBy = curry { (_ offset: Int, _ a: Int) in
    a << offset
}

var _Bitwise_shiftRightBy = curry { (_ offset: Int, _ a: Int) in
    a >> offset
}

// This is logical shift right
var _Bitwise_shiftRightZfBy = curry { (_ offset: Int, _ a: Int) in
    Int(bitPattern: UInt(bitPattern: a) >> UInt(offset))
}
