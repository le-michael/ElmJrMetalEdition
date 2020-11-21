//
//  RendererTypes.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit
import simd

class BufferData {
    var vertexPositions: [simd_float3]
    var indices: [UInt16]

    init(vertexPositions: [simd_float3], indices: [UInt16]) {
        self.vertexPositions = vertexPositions
        self.indices = indices
    }

    func applyTransform(transformMatrix: matrix_float4x4) {
        let newVertexPositions: [simd_float3] = self.vertexPositions.map {
            var tempPos = simd_float4($0.x, $0.y, $0.z, 1)
            tempPos = transformMatrix * tempPos
            return simd_float3(tempPos.x, tempPos.y, tempPos.z)
        }
        self.vertexPositions = newVertexPositions
    }
}

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
    var time: Float
}

struct Mesh {
    var vertices: [Vertex]
    var indices: [UInt16]
}
