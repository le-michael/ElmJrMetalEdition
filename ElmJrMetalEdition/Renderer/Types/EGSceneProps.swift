//
//  EGSceneProps.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGSceneProps {
    var projectionMatrix: matrix_float4x4 = matrix_identity_float4x4
    var viewMatrix: matrix_float4x4 = matrix_identity_float4x4
    var time: Float = 0
    var lights = [Light]()
    var cameraPosition: simd_float3 = [0, 0, 0]
    var parentTransform: matrix_float4x4 = matrix_identity_float4x4
}
