//
//  SwiftArray.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
import Swiftz

// TODO: Check if this will have typecasting problems
var _SwiftArray_empty = [Any]()

func _SwiftArray_singleton<A>(value: A) -> [A] {
    return [value]
}

func _SwiftArray_initialize<A>
(_ size: Int) -> (_ offset: Int) -> (_ f: (Int) -> A) -> [A] {
    { offset in { f in
        var result = [A]()

        for i in 0..<size {
            result.append(f(offset + i))
        }

        return result
    }}
}

func _SwiftArray_initializeFromList<A>
(_ max: Int) -> (_ ls: List<A>) -> ([A], List<A>) {
    { ls in
        var result = [A]()
        var xs = ls
        for _ in 0..<max {
            switch xs.match {
            case ListMatcher.Nil: break
            case ListMatcher.Cons(let hd, let tl):
                result.append(hd)
                xs = tl
            }
        }
        return _Utils_Tuple2(result, ls)
    }
}

func _SwiftArray_unsafeGet<A>
(_ index: Int) -> (_ array: [A]) -> (A) {
    { array in
        array[index]
    }
}

func _SwiftArray_unsafeSet<A>
(_ index: Int) -> (_ value: A) -> (_ array: [A]) -> [A] {
    { value in { array in
        var result = array
        result[index] = value
        return result
    }}
}
