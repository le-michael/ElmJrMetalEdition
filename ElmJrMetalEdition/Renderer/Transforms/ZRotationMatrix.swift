//
//  ZRotationMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class ZRotationMatrix {
    var angleEquation: RMNode = RMConstant(0)

    func evaluate(_ sceneProps: SceneProps) -> matrix_float4x4 {
        let angle = angleEquation.evaluate(sceneProps)
        return createZRotationMatrix(radians: angle)
    }
}
