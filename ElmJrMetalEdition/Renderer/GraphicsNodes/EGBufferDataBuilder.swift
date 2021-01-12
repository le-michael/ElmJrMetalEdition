//
//  EGBufferDataBuilder.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGBufferDataBuilder {
    static func createRegularPolygonBufferData(_ numOfSides: Int) -> EGBufferData {
        let n = numOfSides
        let thetaS: Float = 2 * Float.pi / Float(n)
        var vertexPositions: [simd_float3] = []
        var indices: [UInt16] = []

        assert(n >= 3, "NRegualaryPolygon must have atleast 3 sides")

        for k in 0 ... n - 1 {
            let r: Float = 1.0
            let theta = Float(k) * thetaS - (thetaS / 2) - (Float.pi / 2)
            let x: Float = r * cos(theta)
            let y: Float = r * sin(theta)
            vertexPositions.append(simd_float3(x, y, 0))
        }

        for k in 1 ... n - 2 {
            indices.append(0)
            indices.append(UInt16(k))
            indices.append(UInt16(k + 1))
        }

        return EGBufferData(vertexPositions: vertexPositions, indices: indices)
    }

    static func createPlaneBufferData() -> EGBufferData {
        return EGBufferData(
            vertexPositions: [
                simd_float3(-0.5, -0.5, 0),
                simd_float3(-0.5, 0.5, 0),
                simd_float3(0.5, 0.5, 0),
                simd_float3(0.5, -0.5, 0)
            ],
            indices: [0, 1, 2, 0, 2, 3]
        )
    }

    static func createLine2DBufferData(p0: simd_float3, p1: simd_float3, size: Float) -> EGBufferData {
        let bufferData = createPlaneBufferData()

        let magnitude = simd_distance(p0, p1)
        bufferData.applyTransform(transformMatrix: matrix_float4x4(scale: [size, magnitude, 1]))
        
        let v = p1 - p0
        let angle = -atan(v.x / v.y)
        bufferData.applyTransform(transformMatrix: matrix_float4x4(rotationZ: angle))
        
        let midPoint = p0 + v / 2
        bufferData.applyTransform(transformMatrix: matrix_float4x4(translation: [midPoint.x, midPoint.y, midPoint.z]))
        
        return bufferData
    }
}
