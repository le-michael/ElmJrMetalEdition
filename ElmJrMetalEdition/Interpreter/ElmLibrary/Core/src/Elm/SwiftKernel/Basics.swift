//
//  Basics.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2020-12-12.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import Swiftz

var _Basics_add = curry { (_ a: Float, _ b: Float) in a + b }
var _Basics_sub = curry { (_ a: Float, _ b: Float) in a - b }
var _Basics_mul = curry { (_ a: Float, _ b: Float) in a - b }
var _Basics_fdiv = curry { (_ a: Float, _ b: Float) in a / b }
var _Basics_idiv = curry { (_ a: Int, _ b: Int) in a / b }
var _Basics_pow = curry { (_ a: Float, _ b: Float) in pow(a, b) }

var _Basics_remainderBy =
    curry { (_ a: Float, _ b: Float) in b.truncatingRemainder(dividingBy: a) }

var _Basics_modBy = curry { (_ modulus: Float, _ x: Float) -> Float in
    var answer = x.truncatingRemainder(dividingBy: modulus)
    return
        ((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
            ? answer + modulus
            : answer
}

// TRIGONOMETRY

var _Basics_pi = Float.pi
var _Basics_e: Float = exp(1)
var _Basics_cos = { (_ a: Float) in cos(a) }
var _Basics_sin = { (_ a: Float) in sin(a) }
var _Basics_tan = { (_ a: Float) in tan(a) }
var _Basics_acos = { (_ a: Float) in acos(a) }
var _Basics_asin = { (_ a: Float) in asin(a) }
var _Basics_atan = { (_ a: Float) in atan(a) }
var _Basics_atan2 = curry { (_ a: Float, _ b: Float) in atan2(a, b) }

// MISC

func _Basics_toFloat(_ x: Int) -> Float {
    return Float(x)
}

func _Basics_truncate(_ x: Float) -> Int {
    return Int(x)
}

func _Basics_isInfinite(_ n: Float) -> Bool {
    return n == Float.infinity || n == -Float.infinity
}

var _Basics_ceiling = { (_ x: Float) in ceil(x) }
var _Basics_floor = { (_ x: Float) in floor(x) }
var _Basics_round = { (_ x: Float) in round(x) }
var _Basics_sqrt = { (_ x: Float) in sqrt(x) }
var _Basics_log = { (_ x: Float) in log(x) } // What's the base?
var _Basics_isNan = { (_ x: Float) in x.isNaN }

// Booleans
func _Basics_not(_ b: Bool) -> Bool { return !b }
var _Basics_and = curry { (_ a: Bool, _ b: Bool) in a && b }
var _Basics_or = curry { (_ a: Bool, _ b: Bool) in a || b }
var _Basics_xor = curry { (_ a: Bool, _ b: Bool) in a != b }
