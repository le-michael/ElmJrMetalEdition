//
//  EGRandom.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-30.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EGRandom: EGMathNode {
    var value: Float

    init() {
        value = Float.random(in: 0 ... 100)
    }

    init(range: Range<Float>) {
        value = Float.random(in: range)
    }

    func evaluate(_ sceneProps: EGSceneProps) -> Float {
        return value
    }

    func usesTime() -> Bool {
        return false
    }
}
