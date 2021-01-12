//
//  EGTransformProperty.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-22.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGTransformProperty {
    var translate = EGTranslationMatrix()
    var rotate = EGRotationMatrix()
    var scale = EGScaleMatrix()
    
    var isStatic = false
    var cachedMatrix = matrix_identity_float4x4
    
    init() {
        checkIfStatic()
    }
    
    func checkIfStatic() {
        isStatic = !translate.usesTime()
            && !rotate.usesTime()
            && !scale.usesTime()
        
        if isStatic {
            let sceneProps = EGSceneProps(
                projectionMatrix: matrix_identity_float4x4,
                viewMatrix: matrix_identity_float4x4,
                time: 0,
                cameraPosition: [0, 0, 0]
            )
            cachedMatrix = translate.evaluate(sceneProps)
                * rotate.evaluate(sceneProps)
                * scale.evaluate(sceneProps)
        }
    }
    
    func transformationMatrix(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        if isStatic {
            return cachedMatrix
        }
        return translate.evaluate(sceneProps)
            * rotate.evaluate(sceneProps)
            * scale.evaluate(sceneProps)
    }
}
