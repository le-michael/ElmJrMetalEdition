//
//  EGRotationMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import simd

class EGRotationMatrix {
    var xEquation: EGMathNode = EGConstant(0)
    var yEquation: EGMathNode = EGConstant(0)
    var zEquation: EGMathNode = EGConstant(0)

    func usesTime() -> Bool {
        return xEquation.usesTime() || yEquation.usesTime() || zEquation.usesTime()
    }

    func setRotation(x: Float, y: Float, z: Float) {
        xEquation = EGConstant(x)
        yEquation = EGConstant(y)
        zEquation = EGConstant(z)
    }

    func setRotation(x: EGMathNode, y: EGMathNode, z: EGMathNode) {
        xEquation = x
        yEquation = y
        zEquation = z
    }

    func evaluate(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        let x = xEquation.evaluate(sceneProps)
        let y = yEquation.evaluate(sceneProps)
        let z = zEquation.evaluate(sceneProps)

        return matrix_float4x4(rotation: [x, y, z])
    }
}
