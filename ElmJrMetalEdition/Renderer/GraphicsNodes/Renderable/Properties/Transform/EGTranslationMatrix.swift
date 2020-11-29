//
//  EGTranslationMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGTranslationMatrix {
    var xEquation: EGMathNode = EGFloatConstant(0)
    var yEquation: EGMathNode = EGFloatConstant(0)
    var zEquation: EGMathNode = EGFloatConstant(0)

    func setTranslation(x: Float, y: Float, z: Float) {
        xEquation = EGFloatConstant(x)
        yEquation = EGFloatConstant(y)
        zEquation = EGFloatConstant(z)
    }

    func setTranslation(x: EGMathNode, y: EGMathNode, z: EGMathNode) {
        xEquation = x
        yEquation = y
        zEquation = z
    }
    
    func evaluate(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        let x = xEquation.evaluate(sceneProps)
        let y = yEquation.evaluate(sceneProps)
        let z = zEquation.evaluate(sceneProps)

        return EGMatrixBuilder.createTranslationMatrix(x: x, y: y, z: z)
    }
}
