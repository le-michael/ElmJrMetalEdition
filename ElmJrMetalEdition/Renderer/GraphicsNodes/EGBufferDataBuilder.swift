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
        bufferData.applyTransform(transformMatrix: EGMatrixBuilder.createScaleMatrix(x: size, y: magnitude, z: 1))

        let v = p1 - p0
        let angle = -atan(v.x / v.y)
        bufferData.applyTransform(transformMatrix: EGMatrixBuilder.createZRotationMatrix(radians: angle))

        let midPoint = p0 + v / 2
        bufferData.applyTransform(transformMatrix: EGMatrixBuilder.createTranslationMatrix(x: midPoint.x, y: midPoint.y, z: midPoint.z))

        return bufferData
    }

    static func createCurvedPolygonBufferData(p0: simd_float2, p1: simd_float2, p2: simd_float2, p3: simd_float2) -> EGBufferData {
        var vertexPositions: [simd_float3] = []
        var indices: [UInt16] = []

        let numPoints: Int = 30
        let dt: Float = 1 / (Float(numPoints) - 1)

        for i in 0 ..< numPoints {
            let t = Float(i) * dt

            let cx: Float = 3.0 * (p1.x - p0.x)
            let bx: Float = 3.0 * (p2.x - p1.x) - cx
            let ax: Float = p3.x - p0.x - cx - bx
            
            let cy: Float = 3.0 * (p1.y - p0.y)
            let by: Float = 3.0 * (p2.y - p1.y) - cy
            let ay: Float = p3.y - p0.y - cy - by
            
            let tSquared: Float = t * t
            let tCubed: Float = tSquared * t
            
            let x: Float = (ax * tCubed) + (bx * tSquared) + (cx * t) + p0.x
            let y: Float = (ay * tCubed) + (by * tSquared) + (cy * t) + p0.y
            
            vertexPositions.append(simd_float3(x, y, 1))
        }

        for k in 1 ... numPoints - 2 {
            indices.append(0)
            indices.append(UInt16(k))
            indices.append(UInt16(k + 1))
        }
        
        return EGBufferData(vertexPositions: vertexPositions, indices: indices)
    }
}
