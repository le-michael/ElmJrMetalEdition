//
//  EGVertex.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGVertex {
    struct Primitive {
        let position: simd_float3
    }
    
    struct Bezier {
        let position: simd_float3
        let time: Float
    }
}
