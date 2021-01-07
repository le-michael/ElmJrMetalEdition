//
//  SwiftArray.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
import Swiftz

// // Differs from the JS implementation - call this as a nullary function
func _SwiftArray_empty<A>() -> [A] {
    return [A]()
}

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

/* Original JsArray semantics copies the entire array
   This will therefore be an O(n) operation
*/
func _SwiftArray_push<A>
(_ value : A) -> (_ array : [A]) -> [A] {
    { array in
        return array + [value]
    }
}

func _SwiftArray_foldl<A, B>
(_ f : @escaping (A) -> (B) -> (B)) -> (_ acc : B) -> (_ array : [A])
-> B {
    { acc in { array in
        var result = acc
        for i in 0..<array.count {
            result = f(array[i])(result)
        }
        return result
    }}
}

func _SwiftArray_foldr<A, B>
(_ f : @escaping (A) -> (B) -> (B)) -> (_ acc :B) -> (_ array : [A])
-> B {
    { acc in { array in
        var result = acc
        for i in (0..<array.count).reversed() {
            result = f(array[i])(result)
        }
        return result
    }}
}

func _SwiftArray_map<A, B>
(_ f : @escaping (A) -> B) -> ([A]) -> [B] {
    { array in
        let result = array
        return result.fmap(f)
    }
}

func _SwiftArray_indexedMap<A, B>
(_ f : @escaping (Int) -> (A) -> B) -> (Int) -> ([A]) -> [B] {
    { offset in { array in
        var result = Array<B>()
        for i in 0..<array.count {
            result[i] = f(offset + i)(array[i])
        }
        return result
    }}
}

// Slice up to but not including the last element
func _SwiftArray_slice<A>
(_ from : Int) -> (_ to : Int) -> (_ array : [A]) -> [A] {
    { to in { array in
        return Array(array[from..<to])
    }}
}

func _SwiftArray_appendN<A>
(_ n : Int) -> (_ dest : [A]) -> (_ source : [A]) -> [A] {
    { dest in { source in
        let destLen = dest.count
        var itemsToCopy = n - destLen
        
        if (itemsToCopy > source.count) {
            itemsToCopy = source.count
        }
        
        var result = Array<A>()
        
        for i in 0..<destLen {
            result.append(dest[i])
        }
        
        for i in 0..<itemsToCopy {
            result.append(source[i])
        }
        
        return result
    }}
}
