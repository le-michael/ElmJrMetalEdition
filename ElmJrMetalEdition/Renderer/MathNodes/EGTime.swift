//
//  EGTime.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EGTime: EGMathNode {
    func evaluate(_ sceneProps: EGSceneProps) -> Float {
        return sceneProps.time
    }

    func usesTime() -> Bool {
        return true
    }
}
