//
//  EGZRotationMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGZRotationMatrix {
    var angleEquation: EGMathNode = EGConstant(0)

    func usesTime() -> Bool {
        return angleEquation.usesTime()
    }
    
    func setZRotation(angle: Float) {
        angleEquation = EGConstant(angle)
    }
    
    func setZRotation(angle: EGMathNode) {
        angleEquation = angle
    }
    func evaluate(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        let angle = angleEquation.evaluate(sceneProps)
        return EGMatrixBuilder.createZRotationMatrix(radians: angle)
    }
}
