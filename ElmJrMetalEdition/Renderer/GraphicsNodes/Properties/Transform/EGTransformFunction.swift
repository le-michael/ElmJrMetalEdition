//
//  EGTransformFunction.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-12.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import simd

class EGTransformFunction {
    var equations: (x: EGMathNode, y: EGMathNode, z:EGMathNode)
    var matrixFunction: (simd_float3) -> matrix_float4x4

    init(defaultValues: simd_float3, matrixFunction: @escaping (simd_float3) -> matrix_float4x4) {
        self.equations = (EGConstant(defaultValues.x), EGConstant(defaultValues.y), EGConstant(defaultValues.z))
        self.matrixFunction = matrixFunction
    }

    func usesTime() -> Bool {
        return equations.x.usesTime()
            || equations.y.usesTime()
            || equations.z.usesTime()
    }

    func set(x: Float, y: Float, z: Float) {
        equations = (EGConstant(x), EGConstant(y), EGConstant(z))
    }

    func set(x: EGMathNode, y: EGMathNode, z: EGMathNode) {
        equations = (x, y, z)
    }

    func evaluate(_ sceneProps: EGSceneProps) -> matrix_float4x4 {
        let x = equations.x.evaluate(sceneProps)
        let y = equations.y.evaluate(sceneProps)
        let z = equations.z.evaluate(sceneProps)
        return matrixFunction([x, y, z])
    }
}
