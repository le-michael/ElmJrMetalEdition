//
//  TranslationMatrix.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class TranslationMatrix {
    var xEquation: RMNode = RMConstant(0)
    var yEquation: RMNode = RMConstant(0)
    var zEquation: RMNode = RMConstant(0)

    init() {}

    func evaluate(_ sceneProps: SceneProps) -> matrix_float4x4 {
        let x = xEquation.evaluate(sceneProps)
        let y = yEquation.evaluate(sceneProps)
        let z = zEquation.evaluate(sceneProps)

        return createTranslationMatrix(x: x, y: y, z: z)
    }
}
