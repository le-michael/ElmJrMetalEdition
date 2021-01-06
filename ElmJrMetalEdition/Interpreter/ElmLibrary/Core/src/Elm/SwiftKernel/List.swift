//
//  List.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
import Swiftz

// Differs from the JS implementation - call this as a nullary function
func _List_Nil<A>() -> List<A> {
    return List<A>()
}

func _List_Cons<A>(_ hd: A, _ tl: List<A>) -> List<A> {
    return List(hd, tl)
}

func _List_fromArray<A>(_ arr: [A]) -> List<A> {
    var out: List<A> = _List_Nil()
    for i in (0 ..< arr.count).reversed() {
        out = _List_Cons(arr[i], out)
    }
    return out
}

func _List_toArray<A>(_ xs: List<A>) -> [A] {
    var result = [A]()
    for element in xs {
        result.append(element)
    }
    return result
}

func _List_map2<A, B, Result>
(_ f: @escaping (A) -> (B) -> Result) -> (_ xs: List<A>) -> (_ ys: List<B>) ->
    List<Result>
{
    { xs in { ys in
        var xs = xs
        var ys = ys
        var arr = [Result]()
        while true {
            switch (xs.match, ys.match) {
            case (let ListMatcher.Cons(x, xrest), let ListMatcher.Cons(y, yrest)):
                arr.append(f(x)(y))
                xs = xrest
                ys = yrest
            default:
                break
            }
        }
        return _List_fromArray(arr)
    }}
}

func _List_map3<A, B, C, Result>
(_ f: @escaping (A) -> (B) -> (C) -> Result) ->
    (_ xs: List<A>) -> (_ ys: List<B>) -> (_ zs: List<C>) ->
    List<Result>
{
    { xs in { ys in { zs in
        var xs = xs
        var ys = ys
        var zs = zs
        var arr = [Result]()
        while true {
            switch (xs.match, ys.match, zs.match) {
            case (let ListMatcher.Cons(x, xrest),
                  let ListMatcher.Cons(y, yrest),
                  let ListMatcher.Cons(z, zrest)):
                arr.append(f(x)(y)(z))
                xs = xrest
                ys = yrest
                zs = zrest
            default:
                break
            }
        }
        return _List_fromArray(arr)
    }}}
}

func _List_map4<A, B, C, D, Result>
(_ f: @escaping (A) -> (B) -> (C) -> (D) -> Result) ->
    (_ ws: List<A>) -> (_ xs: List<B>) -> (_ ys: List<C>) -> (_ zs: List<D>) ->
    List<Result>
{
    { ws in { xs in { ys in { zs in
        var ws = ws
        var xs = xs
        var ys = ys
        var zs = zs
        var arr = [Result]()
        while true {
            switch (ws.match, xs.match, ys.match, zs.match) {
            case (let ListMatcher.Cons(w, wrest),
                  let ListMatcher.Cons(x, xrest),
                  let ListMatcher.Cons(y, yrest),
                  let ListMatcher.Cons(z, zrest)):
                arr.append(f(w)(x)(y)(z))
                ws = wrest
                xs = xrest
                ys = yrest
                zs = zrest
            default:
                break
            }
        }
        return _List_fromArray(arr)
    }}}}
}

func _List_map5<A, B, C, D, E, Result>
(_ f: @escaping (A) -> (B) -> (C) -> (D) -> (E) -> Result) ->
    (_ vs: List<A>) -> (_ ws: List<B>) -> (_ xs: List<C>) -> (_ ys: List<D>) -> (_ zs: List<E>) ->
    List<Result>
{
    { vs in { ws in { xs in { ys in { zs in
        var vs = vs
        var ws = ws
        var xs = xs
        var ys = ys
        var zs = zs
        var arr = [Result]()
        while true {
            switch (vs.match, ws.match, xs.match, ys.match, zs.match) {
            case (let ListMatcher.Cons(v, vrest),
                  let ListMatcher.Cons(w, wrest),
                  let ListMatcher.Cons(x, xrest),
                  let ListMatcher.Cons(y, yrest),
                  let ListMatcher.Cons(z, zrest)):
                arr.append(f(v)(w)(x)(y)(z))
                vs = vrest
                ws = wrest
                xs = xrest
                ys = yrest
                zs = zrest
            default:
                break
            }
        }
        return _List_fromArray(arr)
    }}}}}
}

func _List_sortBy<A, Cmp>(_ f: @escaping (A) -> Cmp)
-> (_ xs: List<A>) -> List<A> where Cmp : Comparable
{
    { xs in
        var array = _List_toArray(xs)
        array.sort(by: { a, b in f(a) < f(b) })
        return _List_fromArray(array)
    }
}
