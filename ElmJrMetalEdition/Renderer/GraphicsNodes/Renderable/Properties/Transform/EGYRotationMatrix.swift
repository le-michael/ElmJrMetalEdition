//
//  EGYRotationMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-04.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGYRotationMatrix {
    var angleEquation: EGMathNode = EGConstant(0)

    func usesTime() -> Bool {
        return angleEquation.usesTime()
    }
    
    func setYRotation(angle: Float) {
        angleEquation = EGConstant(angle)
    }
    
    func setYRotation(angle: EGMathNode) {
        angleEquation = angle
    }
    func evaluate(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        let angle = angleEquation.evaluate(sceneProps)
        return EGMatrixBuilder.createYRotationMatrix(radians: angle)
    }
}
