//
//  EGTransformProperty.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-22.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGTransformProperty {
    var scaleMatrix = EGScaleMatrix()
    var translationMatrix = EGTranslationMatrix()
    var zRotationMatrix = EGZRotationMatrix()

    func getTransformationMatrix(sceneProps: EGSceneProps) -> matrix_float4x4 {
        return translationMatrix.evaluate(sceneProps) *
            zRotationMatrix.evaluate(sceneProps) * scaleMatrix.evaluate(sceneProps)
    }
}
