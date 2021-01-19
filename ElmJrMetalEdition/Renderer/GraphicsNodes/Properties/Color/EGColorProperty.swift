//
//  EGColorProperty.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-24.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGColorProperty {
    var equations: (r: EGMathNode, g: EGMathNode, b: EGMathNode, a: EGMathNode)

    var isStatic = false
    var cachedColor = simd_float4(1, 1, 1, 1)

    func checkIfStatic() {
        isStatic = !equations.r.usesTime()
            && !equations.g.usesTime()
            && !equations.b.usesTime()
            && !equations.a.usesTime()

        if isStatic {
            let sceneProps = EGSceneProps(
                projectionMatrix: matrix_identity_float4x4,
                viewMatrix: matrix_identity_float4x4,
                time: 0
            )

            let r = equations.r.evaluate(sceneProps)
            let g = equations.g.evaluate(sceneProps)
            let b = equations.b.evaluate(sceneProps)
            let a = equations.a.evaluate(sceneProps)

            cachedColor = simd_float4(r, g, b, a)
        }
    }

    init() {
        equations = (
            r: EGConstant(1),
            g: EGConstant(1),
            b: EGConstant(1),
            a: EGConstant(1)
        )
    }

    func set(r: Float, g: Float, b: Float, a: Float) {
        equations = (EGConstant(r), EGConstant(g), EGConstant(b), EGConstant(a))
    }
    
    func set(color: simd_float3) {
        equations = (EGConstant(color.x), EGConstant(color.y), EGConstant(color.z), EGConstant(1))
    }

    func set(r: EGMathNode, g: EGMathNode, b: EGMathNode, a: EGMathNode) {
        equations = (r, g, b, a)
    }

    func evaluate(_ sceneProps: EGSceneProps) -> simd_float4 {
        if isStatic {
            return cachedColor
        }

        let r = equations.r.evaluate(sceneProps)
        let g = equations.g.evaluate(sceneProps)
        let b = equations.b.evaluate(sceneProps)
        let a = equations.a.evaluate(sceneProps)

        return simd_float4(r, g, b, a)
    }
}
