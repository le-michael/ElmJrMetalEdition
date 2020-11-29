//
//  RGColorProperty.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-24.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class RGColorProperty {
    var rEquation: RMNode
    var gEquation: RMNode
    var bEquation: RMNode
    var aEquation: RMNode

    init() {
        rEquation = RMConstant(1)
        gEquation = RMConstant(1)
        bEquation = RMConstant(1)
        aEquation = RMConstant(1)
    }

    func setColor(r: Float, g: Float, b: Float, a: Float) {
        rEquation = RMConstant(r)
        gEquation = RMConstant(g)
        bEquation = RMConstant(b)
        aEquation = RMConstant(a)
    }

    func setColor(r: RMNode, g: RMNode, b: RMNode, a: RMNode) {
        rEquation = r
        gEquation = g
        bEquation = b
        aEquation = a
    }

    func evaluate(_ sceneProps: SceneProps) -> simd_float4 {
        let r = rEquation.evaluate(sceneProps)
        let g = gEquation.evaluate(sceneProps)
        let b = bEquation.evaluate(sceneProps)
        let a = aEquation.evaluate(sceneProps)

        return simd_float4(r, g, b, a)
    }
}
