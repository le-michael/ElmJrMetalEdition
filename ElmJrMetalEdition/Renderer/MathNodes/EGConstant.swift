//
//  EGConstant.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EGConstant: EGMathNode {
    var value: Float

    init(_ value: Float) {
        self.value = value
    }

    func evaluate(_ sceneProps: EGSceneProps) -> Float {
        return value
    }

    func usesTime() -> Bool {
        return false
    }
}
