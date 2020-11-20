//
//  RMConstant.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class RMConstant: RMNode {
    var value: Float

    init(_ value: Float) {
        self.value = value
    }

    override func evaluate(_ sceneProps: SceneProps) -> Float {
        return value
    }
}
