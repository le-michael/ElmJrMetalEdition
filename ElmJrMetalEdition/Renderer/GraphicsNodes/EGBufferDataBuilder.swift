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

    static func createCubeBufferData() -> EGBufferData {
        return EGBufferData(
            vertexPositions: [
                simd_float3(-1, -1, 1),
                simd_float3(-1, -1, -1),
                simd_float3(1, -1, -1),
                simd_float3(1, -1, 1),
                simd_float3(-1, 1, 1),
                simd_float3(-1, 1, -1),
                simd_float3(1, 1, -1),
                simd_float3(1, 1, 1)
            ],
            indices: [
                0, 1, 2, 0, 2, 3, // Bottom
                4, 5, 6, 4, 6, 7, // Top
                0, 4, 7, 0, 7, 3, // Front
                2, 6, 5, 2, 5, 1, // Back
                3, 7, 6, 3, 6, 2, // Right
                1, 5, 4, 1, 4, 0 // Left
            ]
        )
    }

    // Reference: http://www.songho.ca/opengl/gl_sphere.html
    static func createIsosphereBufferData() -> EGBufferData {
        let radius: Float = 1

        func computeBaseVertices() -> [simd_float3] {
            let hAngle = Float.pi / 180 * 72
            let vAngle: Float = atanf(1 / 2)

            var vertcies = [simd_float3](repeating: simd_float3(0, 0, 0), count: 12)

            // North Pole
            vertcies[0] = simd_float3(0, 0, radius)

            var hAngle1 = -Float.pi / 2 - hAngle / 2
            var hAngle2 = -Float.pi / 2

            for i in 1 ... 5 {
                let i1: Int = i
                let i2: Int = i + 5

                let z: Float = radius * sinf(vAngle)
                let xy: Float = radius * cosf(vAngle)

                vertcies[i1] = simd_float3(
                    xy * cosf(hAngle1),
                    xy * sinf(hAngle1),
                    z
                )

                vertcies[i2] = simd_float3(
                    xy * cosf(hAngle2),
                    xy * sinf(hAngle2),
                    -z
                )

                hAngle1 += hAngle
                hAngle2 += hAngle
            }

            // South Pole
            vertcies[11] = simd_float3(0, 0, -radius)

            return vertcies
        }

        let tempVertices: [simd_float3] = computeBaseVertices()
        var vertices: [simd_float3] = []
        var indices: [UInt16] = []

        let v0: simd_float3 = tempVertices[0]
        let v11: simd_float3 = tempVertices[11]

        var index: UInt16 = 0

        for i in 1 ... 5 {
            let v1: simd_float3 = tempVertices[i]
            let v2: simd_float3 = i < 5 ? tempVertices[i + 1] : tempVertices[3]
            let v3: simd_float3 = tempVertices[i + 5]
            let v4: simd_float3 = i + 5 < 10 ? tempVertices[i + 6] : tempVertices[6]

            // First row
            vertices.append(contentsOf: [v0, v1, v2])
            print("First Row: \(v0) \(v1) \(v2)")
            // indices.append(contentsOf: [index, index + 1, index + 2])

            // Second row
            vertices.append(contentsOf: [v1, v3, v2])
            print("Second Row: \(v1) \(v3) \(v2)")
            // indices.append(contentsOf: [index + 3, index + 4, index + 5])

            vertices.append(contentsOf: [v2, v3, v4])
            print("Second Row: \(v2) \(v3) \(v4)")
            // indices.append(contentsOf: [index + 6, index + 7, index + 8])

            // Thrid Row
            vertices.append(contentsOf: [v3, v11, v4])
            print("Third Row: \(v3) \(v11) \(v4)")
            // indices.append(contentsOf: [index + 9, index + 10, index + 11])

            // Debug: Draw line indices
            indices.append(contentsOf: [
                index, index + 1,
                index + 3, index + 4,
                index + 3, index + 5,
                index + 4, index + 5,
                index + 6, index + 7,
                index + 6, index + 8,
                index + 7, index +
                index + 9, index + 10,
                index + 9, index + 11,
                index + 10, index + 11
            ])

            index += 12
            print("Faces: \(indices.count / 3)")
        }

        return EGBufferData(vertexPositions: vertices, indices: indices)
    }
}
