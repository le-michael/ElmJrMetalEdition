//
//  EGVertexUniforms.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-21.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGVertexUniforms {
    struct Primitive {
        var modelViewMatrix = matrix_identity_float4x4
        var color = simd_float4(1, 1, 1, 1)
        var modelMatrix = matrix_identity_float4x4
        var viewMatrix = matrix_identity_float4x4
        var projectionMatrix = matrix_identity_float4x4
        var normalMatrix = matrix_identity_float3x3
        
        // Delete this debug
        var cameraPosition = simd_float3(0, 0 , 0)
    }

    struct Bezier {
        var modelViewMatrix = matrix_identity_float4x4
        var color = simd_float4(1, 1, 1, 1)
        var p0 = simd_float2(0, 0)
        var p1 = simd_float2(0, 0)
        var p2 = simd_float2(0, 0)
        var p3 = simd_float2(0, 0)
    }
}
