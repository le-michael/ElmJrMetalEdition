//
//  EGScaleMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGScaleMatrix {
    var xEquation: EGMathNode = EGConstant(1)
    var yEquation: EGMathNode = EGConstant(1)
    var zEquation: EGMathNode = EGConstant(1)
    
    func usesTime() -> Bool {
        return xEquation.usesTime() || yEquation.usesTime() || zEquation.usesTime()
    }
    
    func setScale(x: Float, y: Float, z: Float) {
        xEquation = EGConstant(x)
        yEquation = EGConstant(y)
        zEquation = EGConstant(z)
    }

    func setScale(x: EGMathNode, y: EGMathNode, z: EGMathNode) {
        xEquation = x
        yEquation = y
        zEquation = z
    }

    func evaluate(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        let x = xEquation.evaluate(sceneProps)
        let y = yEquation.evaluate(sceneProps)
        let z = zEquation.evaluate(sceneProps)

        return matrix_float4x4(scale: [x, y, z])
    }
}
