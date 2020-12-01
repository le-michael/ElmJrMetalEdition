//
//  EGRendererTypes.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit
import simd

class EGBufferData {
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

class EGMesh {
    var vertices: [EGVertex]
    var indices: [UInt16]

    init(_ bufferData: EGBufferData) {
        self.indices = bufferData.indices
        self.vertices = bufferData.vertexPositions.map {
            EGVertex(position: $0)
        }
    }
}

struct EGVertex {
    let position: simd_float3
}

struct EGModelConstants {
    var modelViewMatrix = matrix_identity_float4x4
    var color = simd_float4(1, 1, 1, 1)
}

class EGBezierMesh {
    var vertices: [EGBezierVertex]
    var indices: [UInt16]

    init(_ bufferData: EGBufferData) {
        self.indices = bufferData.indices
        self.vertices = bufferData.vertexPositions.enumerated().map { ind, pos in
            let dt = 1.0 / (Float(bufferData.vertexPositions.count) - 1)
            let time = Float(ind) * dt
            return EGBezierVertex(
                position: pos,
                time: time
            )
        }
    }
}

struct EGBezierVertex {
    let position: simd_float3
    let time: Float
}

struct EGBezierModelConstants {
    var modelViewMatrix = matrix_identity_float4x4
    var color = simd_float4(1, 1, 1, 1)
    var p0 = simd_float2(0, 0)
    var p1 = simd_float2(0, 0)
    var p2 = simd_float2(0, 0)
    var p3 = simd_float2(0, 0)
}

struct EGSceneProps {
    var projectionMatrix: matrix_float4x4
    var viewMatrix: matrix_float4x4
    var time: Float
}
