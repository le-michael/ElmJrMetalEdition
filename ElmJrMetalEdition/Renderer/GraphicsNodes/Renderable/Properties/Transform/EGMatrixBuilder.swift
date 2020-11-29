//
//  EGMatrixBuilder.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import GLKit
import simd

class EGMatrixBuilder {
    static func createTranslationMatrix(x: Float, y: Float, z: Float) -> matrix_float4x4 {
        return matrix_float4x4(columns: (
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(x, y, z, 1)
        ))
    }

    static func createZRotationMatrix(radians angle: Float) -> matrix_float4x4 {
        return matrix_float4x4([
            simd_float4(cos(angle), sin(angle), 0, 0),
            simd_float4(-sin(angle), cos(angle), 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(0, 0, 0, 1)
        ])
    }

    static func createZRotationMatrix(degrees deg: Float) -> matrix_float4x4 {
        let angle = GLKMathDegreesToRadians(deg)
        return createZRotationMatrix(radians: angle)
    }

    static func createScaleMatrix(x: Float, y: Float, z: Float) -> matrix_float4x4 {
        return matrix_float4x4([
            simd_float4(x, 0, 0, 0),
            simd_float4(0, y, 0, 0),
            simd_float4(0, 0, z, 0),
            simd_float4(0, 0, 0, 1)
        ])
    }

    static func createProjectionMatrix(fovRadians fov: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = farZ / (nearZ - farZ)
        return matrix_float4x4(columns: (
            simd_float4(x, 0, 0, 0),
            simd_float4(0, y, 0, 0),
            simd_float4(0, 0, z, -1),
            simd_float4(0, 0, z * nearZ, 0)
        ))
    }

    static func createProjectionMatrix(fovDegrees deg: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let fov = GLKMathDegreesToRadians(deg)
        return createProjectionMatrix(fovRadians: fov, aspect: aspect, nearZ: nearZ, farZ: farZ)
    }
}
