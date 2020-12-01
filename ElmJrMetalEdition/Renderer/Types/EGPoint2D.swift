//
//  EGPoint2D.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-30.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGPoint2D {
    var xEquation: EGMathNode
    var yEquation: EGMathNode
    
    init(pos: simd_float2) {
        xEquation = EGConstant(pos.x)
        yEquation = EGConstant(pos.y)
    }
    
    init(x: EGMathNode, y: EGMathNode) {
        xEquation = x
        yEquation = y
    }
    
    func evaluate(_ sceneProps: EGSceneProps) -> simd_float2 {
        let x = xEquation.evaluate(sceneProps)
        let y = yEquation.evaluate(sceneProps)
        
        return simd_float2(x, y)
    }
}
