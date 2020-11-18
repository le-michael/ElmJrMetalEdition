//
//  Types.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit
import simd

struct Vertex {
    let Position: simd_float3
    var Color: simd_float4
}

struct ModelConstants {
    var modelViewMatrix = matrix_identity_float4x4
}

struct SceneProps {
    var projectionMatrix: matrix_float4x4
    var viewMatrix: matrix_float4x4
}
