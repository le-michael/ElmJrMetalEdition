//
//  List.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
import Swiftz

var _List_Nil: List<Any> = List()

func _List_Cons<A>(hd: A, tl: List<A>) -> List<A> {
    return List(hd, tl)
}
