//
//  ScaleMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class ScaleMatrix {
    var xEquation: RMNode = RMConstant(1)
    var yEquation: RMNode = RMConstant(1)
    var zEquation: RMNode = RMConstant(1)
    
    func setScale(x: Float, y: Float, z: Float) {
        xEquation = RMConstant(x)
        yEquation = RMConstant(y)
        zEquation = RMConstant(z)
    }

    func setScale(x: RMNode, y: RMNode, z: RMNode) {
        xEquation = x
        yEquation = y
        zEquation = z
    }

    func evaluate(_ sceneProps: SceneProps) -> matrix_float4x4 {
        let x = xEquation.evaluate(sceneProps)
        let y = yEquation.evaluate(sceneProps)
        let z = zEquation.evaluate(sceneProps)

        return createScaleMatrix(x: x, y: y, z: z)
    }
}
