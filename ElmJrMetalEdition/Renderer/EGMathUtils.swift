//
//  EGMathUtils.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-12.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import simd

extension Float {
    var degreesToRadians: Float {
        (self / 180) * Float.pi
    }
    
    var radiansToDegrees: Float {
        (self / Float.pi ) * 180
    }
}

extension matrix_float4x4 {
    init(translation t: simd_float3) {
        self.init()
        columns = (
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [t.x, t.y, t.z, 1]
        )
    }

    init(scale s: simd_float3) {
        self.init()
        columns = (
            [s.x, 0, 0, 0],
            [0, s.y, 0, 0],
            [0, 0, s.z, 0],
            [0, 0, 0, 1]
        )
    }

    init(rotationX rad: Float) {
        self.init()
        columns = (
            [1, 0, 0, 0],
            [0, cos(rad), sin(rad), 0],
            [0, -sin(rad), cos(rad), 0],
            [0, 0, 0, 1]
        )
    }

    init(rotationY rad: Float) {
        self.init()
        columns = (
            [cos(rad), 0, -sin(rad), 0],
            [0, 1, 0, 0],
            [sin(rad), 0, cos(rad), 0],
            [0, 0, 0, 1]
        )
    }

    init(rotationZ rad: Float) {
        self.init()
        columns = (
            [cos(rad), sin(rad), 0, 0],
            [-sin(rad), cos(rad), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }

    init(rotation r: simd_float3) {
        self.init()
        let rotationX = matrix_float4x4(rotationX: r.x)
        let rotationY = matrix_float4x4(rotationY: r.y)
        let rotationZ = matrix_float4x4(rotationZ: r.z)
        self = rotationX * rotationY * rotationZ
    }

    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = far / (near - far)
        self.init()
        columns = (
            [x, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, z, -1],
            [0, 0, z * near, 0]
        )
    }
}
