//
//  Transforms.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-22.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class Transforms {
    var scaleMatrix = ScaleMatrix()
    var translationMatrix = TranslationMatrix()
    var zRotationMatrix = ZRotationMatrix()

    func getTransformationMatrix(sceneProps: SceneProps) -> matrix_float4x4 {
        return translationMatrix.evaluate(sceneProps) *
            zRotationMatrix.evaluate(sceneProps) *
            scaleMatrix.evaluate(sceneProps)
    }
}
