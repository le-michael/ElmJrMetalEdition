//
//  EGColorProperty.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-24.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGColorProperty {
    var rEquation: EGMathNode
    var gEquation: EGMathNode
    var bEquation: EGMathNode
    var aEquation: EGMathNode

    var isStatic = false
    var cachedColor = simd_float4(1, 1, 1, 1)

    func checkIfStatic() {
        isStatic = !rEquation.usesTime() && !gEquation.usesTime() && !bEquation.usesTime() && !aEquation.usesTime()
        if isStatic {
            let sceneProps = EGSceneProps(
                projectionMatrix: matrix_identity_float4x4,
                viewMatrix: matrix_identity_float4x4,
                time: 0
            )

            let r = rEquation.evaluate(sceneProps)
            let g = gEquation.evaluate(sceneProps)
            let b = bEquation.evaluate(sceneProps)
            let a = aEquation.evaluate(sceneProps)

            cachedColor = simd_float4(r, g, b, a)
        }
    }

    init() {
        rEquation = EGConstant(1)
        gEquation = EGConstant(1)
        bEquation = EGConstant(1)
        aEquation = EGConstant(1)
        checkIfStatic()
    }

    func setColor(r: Float, g: Float, b: Float, a: Float) {
        rEquation = EGConstant(r)
        gEquation = EGConstant(g)
        bEquation = EGConstant(b)
        aEquation = EGConstant(a)
        checkIfStatic()
    }

    func setColor(r: EGMathNode, g: EGMathNode, b: EGMathNode, a: EGMathNode) {
        rEquation = r
        gEquation = g
        bEquation = b
        aEquation = a
        checkIfStatic()
    }

    func evaluate(_ sceneProps: EGSceneProps) -> simd_float4 {
        if isStatic {
            return cachedColor
        }

        let r = rEquation.evaluate(sceneProps)
        let g = gEquation.evaluate(sceneProps)
        let b = bEquation.evaluate(sceneProps)
        let a = aEquation.evaluate(sceneProps)

        return simd_float4(r, g, b, a)
    }
}
