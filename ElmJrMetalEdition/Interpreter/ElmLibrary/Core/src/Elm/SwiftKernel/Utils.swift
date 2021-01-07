//
//  Utils.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2020-12-31.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Bow
import Foundation

func _Utils_eq<A>(x: A, y: A) {}

func _Utils_Tuple2<A, B>(_ a: A, _ b: B) -> (A, B) { return (a, b) }
func _Utils_Tuple3<A, B, C>(_ a: A, _ b: B, _ c: C) -> (A, B, C) {
    return (a, b, c)
}

func _Utils_cmp<A>(_ x : A, _ y : A) -> Int where A : Comparable {
    return x == y ? /* EQ */ 0 : x < y ? /* LT */ -1 : /* GT */ 1
}
