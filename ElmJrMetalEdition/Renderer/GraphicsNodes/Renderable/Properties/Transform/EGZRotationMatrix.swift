//
//  EGZRotationMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGZRotationMatrix {
    var angleEquation: EGMathNode = EGFloatConstant(0)

    func setZRotation(angle: Float) {
        angleEquation = EGFloatConstant(angle)
    }
    
    func setZRotation(angle: EGMathNode) {
        angleEquation = angle
    }
    func evaluate(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        let angle = angleEquation.evaluate(sceneProps)
        return EGMatrixBuilder.createZRotationMatrix(radians: angle)
    }
}
