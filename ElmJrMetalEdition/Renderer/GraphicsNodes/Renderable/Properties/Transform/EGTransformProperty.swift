//
//  EGTransformProperty.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-22.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGTransformProperty {
    var translationMatrix = EGTranslationMatrix()
    var rotationMatrix = EGRotationMatrix()
    var scaleMatrix = EGScaleMatrix()
    
    var isStatic = false
    var cachedMatrix = matrix_identity_float4x4
    
    init() {
        checkIfStatic()
    }
    
    func checkIfStatic() {
        isStatic = !translationMatrix.usesTime()
            && !rotationMatrix.usesTime()
            && !scaleMatrix.usesTime()
        
        if isStatic {
            let sceneProps = EGSceneProps(
                projectionMatrix: matrix_identity_float4x4,
                viewMatrix: matrix_identity_float4x4,
                time: 0
            )
            cachedMatrix = translationMatrix.evaluate(sceneProps)
                * rotationMatrix.evaluate(sceneProps)
                * scaleMatrix.evaluate(sceneProps)
        }
    }
    
    func getTransformationMatrix(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        if isStatic {
            return cachedMatrix
        }
        return translationMatrix.evaluate(sceneProps)
            * rotationMatrix.evaluate(sceneProps)
            * scaleMatrix.evaluate(sceneProps)
    }
}
