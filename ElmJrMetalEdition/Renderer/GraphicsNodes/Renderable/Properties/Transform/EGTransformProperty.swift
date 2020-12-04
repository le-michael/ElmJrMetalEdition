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
    var xRotationMatrix = EGXRotationMatrix()
    var yRotationMatrix = EGYRotationMatrix()
    var zRotationMatrix = EGZRotationMatrix()
    
    var isStatic = true
    var cachedMatrix = matrix_identity_float4x4
    
    init() {
        checkIfStatic()
    }
    
    func checkIfStatic() {
        isStatic = !scaleMatrix.usesTime()
            && !translationMatrix.usesTime()
            && !xRotationMatrix.usesTime()
            && !yRotationMatrix.usesTime()
            && !zRotationMatrix.usesTime()
        
        if isStatic {
            let sceneProps = EGSceneProps(
                projectionMatrix: matrix_identity_float4x4,
                viewMatrix: matrix_identity_float4x4,
                time: 0
            )
            cachedMatrix = translationMatrix.evaluate(sceneProps)
                * xRotationMatrix.evaluate(sceneProps)
                * yRotationMatrix.evaluate(sceneProps)
                * zRotationMatrix.evaluate(sceneProps)
                * scaleMatrix.evaluate(sceneProps)
        }
    }
    
    func getTransformationMatrix(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        if isStatic {
            return cachedMatrix
        }
        
        return translationMatrix.evaluate(sceneProps)
            * xRotationMatrix.evaluate(sceneProps)
            * yRotationMatrix.evaluate(sceneProps)
            * zRotationMatrix.evaluate(sceneProps)
            * scaleMatrix.evaluate(sceneProps)
    }
}
