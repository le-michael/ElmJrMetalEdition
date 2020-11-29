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

    init() {
        rEquation = EGFloatConstant(1)
        gEquation = EGFloatConstant(1)
        bEquation = EGFloatConstant(1)
        aEquation = EGFloatConstant(1)
    }

    func setColor(r: Float, g: Float, b: Float, a: Float) {
        rEquation = EGFloatConstant(r)
        gEquation = EGFloatConstant(g)
        bEquation = EGFloatConstant(b)
        aEquation = EGFloatConstant(a)
    }

    func setColor(r: EGMathNode, g: EGMathNode, b: EGMathNode, a: EGMathNode) {
        rEquation = r
        gEquation = g
        bEquation = b
        aEquation = a
    }

    func evaluate(_ sceneProps: EGSceneProps) -> simd_float4 {
        let r = rEquation.evaluate(sceneProps)
        let g = gEquation.evaluate(sceneProps)
        let b = bEquation.evaluate(sceneProps)
        let a = aEquation.evaluate(sceneProps)

        return simd_float4(r, g, b, a)
    }
}
