//
//  EGBezierModelConstants.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

struct EGBezierModelConstants {
    var modelViewMatrix = matrix_identity_float4x4
    var color = simd_float4(1, 1, 1, 1)
    var p0 = simd_float2(0, 0)
    var p1 = simd_float2(0, 0)
    var p2 = simd_float2(0, 0)
    var p3 = simd_float2(0, 0)
}
