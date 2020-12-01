//
//  EGBufferData.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

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
